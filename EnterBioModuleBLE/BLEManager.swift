//
//  BLEManager.swift
//  EnterBioModuleBLE
//
//  Created by Enter on 2019/8/14.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import Foundation
import PromiseKit
import RxBluetoothKit
import RxSwift


public protocol BLEStateDelegate: class {
    func bleConnectionStateChanged(state: BLEConnectionState, bleManager: BLEManager)
    func bleBatteryReceived(battery: Battery, bleManager: BLEManager)
    
}

public protocol BLEBioModuleDataSource: class {
    func bleBrainwaveDataReceived(data: Data, bleManager: BLEManager)
    func bleHeartRateDataReceived(data: Data, bleManager: BLEManager)
}

extension BLEStateDelegate {
    public func bleConnectionStateChanged(state: BLEConnectionState, bleManager: BLEManager) {
        return
    }
    public func bleBatteryReceived(battery: Battery, bleManager: BLEManager) {
        return
    }

}

extension  BLEBioModuleDataSource {
    public func bleBrainwaveDataReceived(data: Data, bleManager: BLEManager) {
        return
    }
    public func bleHeartRateDataReceived(data: Data, bleManager: BLEManager) {
        return
    }
}


public class BLEManager {
    
    struct Observers {
        var eeg: Disposable?
        /// 设备连接状态监听
        var connection: Disposable?
        /// 设备电量监听
        var battery: Disposable?
        /// 设备佩戴状态监听
        var wearing: Disposable?
        /// 心率
        var heart: Disposable?
    }
    
    private var observers: Observers = Observers()
    
    public weak var delegate: BLEStateDelegate?
    public weak var dataSource: BLEBioModuleDataSource?
    
    
    /// init method
    ///
    /// - Parameter
    public required init() {
    }
    
    /// connection
    public private(set) var state: BLEConnectionState = .disconnected {
        didSet {
            delegate?.bleConnectionStateChanged(state: self.state, bleManager: self)
        }
    }
    
    /// device
    public private(set) var deviceInfo: BLEDeviceInfo = BLEDeviceInfo(name: "Flowtime",
                                                                       hardware: "0.0.0",
                                                                       firmware: "0.0.0",
                                                                       mac: "00.00.00.00.00.00")
    ///battery
    public private(set) var battery: Battery? = nil {
        didSet {
            guard let battery = self.battery else {
                return
            }
            delegate?.bleBatteryReceived(battery: battery, bleManager: self)
        }
    }
    
    /// scanner
    private var scanner = Scanner()
    /// connector
    public var connector: Connector?
    private var disposalbe: Disposable?
    
    // MARK: - connect logic
    /// Scan peripheral with 3 second and connect
    ///
    /// - Parameters:
    ///   - completion: 完成回调
    public func scanAndConnect(completion: Connector.ConnectResultBlock?) throws {
        if self.state.isBusy {
            throw BLEError.busy
        }
        searchPeripheral()
            .then { [unowned self] in
                self.connect(peripheral: $0.peripheral)
            }.done {
                completion?(true)
            }.catch { _ in
                completion?(false)
        }
    }
    
    public func disconnect() {
        reset()
    }
    
    
    /// Scan peripheral
    ///
    /// - Returns: peripheral which closer
    private func searchPeripheral() -> Promise<ScannedPeripheral> {
        let promise = Promise<ScannedPeripheral> { [weak self] seal in
            guard let `self` = self else { return }
            self.state = .searching
            self.disposalbe?.dispose()
            self.disposalbe = scanner.scan()
                .buffer(timeSpan: 3.0, count: 10, scheduler: MainScheduler.asyncInstance)
                .subscribe(onNext: { (peripherals) in
                    self.state = .connecting
                    let min = peripherals.min(by: { (temp, next) -> Bool in
                        return temp.rssi.intValue > next.rssi.intValue
                    })
                    if let scaned = min {
                        seal.fulfill(scaned)
                        self.disposalbe?.dispose()
                    } else {
                        self.state = .disconnected
                        seal.reject(BLEError.timeout)
                        self.disposalbe?.dispose()
                    }
                }, onError: { (error) in
                    self.state = .disconnected
                    seal.reject(error)
                    self.disposalbe?.dispose()
                })
        }
        return promise
    }
    
    
    /// Connect BLE and start all service
    ///
    /// - Parameter peripheral: scaned peripheral
    /// - Returns: Promise
    private func connect(peripheral: Peripheral) -> Promise<Void> {
        state = .connecting
        connector = Connector(peripheral: peripheral)
        let promise = Promise<Void> { seal in
            connector!.tryConnect()
                .done {
                    self.readBattery()
                    self.readDeviceInfo()
                    self.state = .connected(.allWrong)
                    self.listenConnection()
                    self.listenWear()
                    self.listenBattery()
                    seal.fulfill(())
                }.catch { (error) in
                    self.state = .disconnected
                    seal.reject(error)
            }
        }
        return promise
    }
    
    
    /// Peripheral listener
    private func listenConnection() {
        observers.connection = connector?.peripheral.observeConnection()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isConnected in
                guard let `self` = self else { return }
                self.state = isConnected ? .connected(.allWrong) : .disconnected
                if !isConnected {
                    self.reset()
                }
                }, onError: {
                    error in
                    self.reset()
            })
    }
    
    private func unlistenConnection() {
        observers.connection?.dispose()
        observers.connection = nil
    }
    
    /// This service tell us if the device is wore
    private func listenWear() {
        observers.wearing = connector?.eegService?.notify(characteristic: .contact)
            .subscribe(onNext: { [unowned self] in
                guard let value = $0.first, let wearState = BLEWearState(rawValue: value), self.state.isConnected else { return }
                self.state = .connected(wearState)
            })
    }
    
    private func unlistenWear() {
        observers.wearing?.dispose()
        observers.wearing = nil
    }
    
    
    /// Read device's battery
    private func readBattery() {
        delay(seconds: 0.1) { [weak self] in
            self?.connector?.batteryService?.read(characteristic: .battery)
                .done { [weak self] in
                    guard let value = $0.copiedBytes.first else { return }
                    self?.battery = self?.battery(from: value)
                }.catch { _ in
                    //
            }
        }
    }
    
    /// Battery listenner
    private func listenBattery() {
        delay(seconds: 0.2) { [weak self] in
            self?.observers.battery = self?.connector?.batteryService?.notify(characteristic: .battery)
                .subscribe(onNext: { [weak self] in
                    guard let value = $0.first else { return }
                    self?.battery = self?.battery(from: value)
                })
        }
    }
    
    private func unlistenBattery() {
        observers.battery?.dispose()
        observers.battery = nil
        self.battery = nil
    }
    
    ///
    private func readDeviceInfo() {
        connector?.deviceInfoService?.read(characteristic: .hardwareRevision).done { [weak self] in
            self?.deviceInfo.hardware = String(data: $0, encoding: .utf8) ?? ""
            }.catch { _ in }
        connector?.deviceInfoService?.read(characteristic: .firmwareRevision).done { [weak self] in
            self?.deviceInfo.firmware = String(data: $0, encoding: .utf8) ?? ""
            }.catch { _ in }
        connector?.deviceInfoService?.read(characteristic: .mac).done { [weak self] data -> Void in
            let mac = data.copiedBytes.reversed().map { String(format: "%02X", $0) }.joined(separator: ":")
            self?.deviceInfo.mac = mac
            }.catch { _ in }
        self.deviceInfo.name = connector?.peripheral.peripheral.name ?? ""
    }
    
    
    /// Algorithm of how to alculate battery
    private func battery(from value: UInt8) -> Battery {
        let voltage = Float(value)/100 + 3.1
        
        let a1: Float = 99.84
        let b1: Float = 4.244
        let c1: Float = 0.3781
        let a2: Float = 21.38
        let b2: Float = 3.953
        let c2: Float = 0.1685
        let a3: Float = 15.21
        let b3: Float = 3.813
        let c3: Float = 0.09208
        
        let q = a1 * exp(-pow((voltage-b1)/c1, 2)) + a2 * exp(-pow((voltage-b2)/c2, 2)) + a3 * exp(-pow((voltage-b3)/c3, 2))
        let remain = (4.52 * q) / 60
        let percentage = max(min(q, 100), 0)
        return Battery(voltage: voltage, remain: Int(remain), percentage: percentage)
    }
    
    /// Reset service
    private func reset() {
        unlistenWear()
        unlistenBattery()
        unlistenConnection()
        connector?.cancel()
        connector = nil
        state = .disconnected
        deviceInfo = BLEDeviceInfo()
    }
    
    
    //MARK: - EEG Service
    
    
    /// Start EEG Service
    public func startEEG() {
        observers.eeg = connector?.eegService?
            .notify(characteristic: .data)
            .subscribe(onNext: { [weak self] bytes in
                autoreleasepool {
                    self?.handleBrainData(bytes: bytes)
                }
                }, onError: {
                    print("eeg notify error: \($0)")
            })
        // 开始指令
        
        _ = connector?.commandService?.write(data: Data([0x05]), to: .send)
        
        // 默认开启脱落检测
        delay(seconds: 0.2, block: {
            _ = self.connector?.commandService?.write(data: Data([0x07]), to: .send)
        })
    }
    
    /// Brain data buffer
    private var _eegBuffer: [UInt8] = []
    private let _eegBufferSize: Int = 600
    private let _eegLock = NSLock()
    
    /// Send brain data to delegate
    ///
    /// - Parameter bytes: brain data
    private func handleBrainData(bytes: [UInt8]) {
        _eegLock.lock()
        _eegBuffer.append(contentsOf: bytes)
        if _eegBuffer.count < _eegBufferSize {
            _eegLock.unlock()
            return
        }
        let data = Data(_eegBuffer)
        _eegBuffer.removeAll()
        _eegLock.unlock()
        dataSource?.bleBrainwaveDataReceived(data: data, bleManager: self)
    }
    
    /// stop EEG
    public func stopEEG() {
        // 结束指令
        _ = connector?.commandService?.write(data: Data([0x06]), to: .send)
        // 结束脑波监听
        observers.eeg?.dispose()
        observers.eeg = nil
        _eegLock.lock()
        _eegBuffer.removeAll()
        _eegLock.unlock()
    }
    
    // MARK: - Heart Rate Service
    /// Heart Rate buffer
    private var _hrBuffer: [UInt8] = []
    private let _hrBufferSize: Int = 2
    private let _hrLock = NSLock()
    /// start heart rate and start notify
    public func startHeartRate() {
        observers.heart = self.connector?.heartService?
            .notify(characteristic: .data)
            .subscribe(onNext: { [weak self] bytes in
                autoreleasepool {
                    self?.handleHeartRateData(bytes: bytes)
                }
                }, onError: {
                    print("eeg notify error: \($0)")
            })
        _ = self.connector?.commandService?.write(data: Data([0x05]), to: .send)
    }
    
    /// stop heart rate
    public func stopHeartRate() {
        
        _ = self.connector?.commandService?.write(data: Data([0x06]), to: .send)
        
        observers.heart?.dispose()
        observers.heart = nil
        _hrLock.lock()
        _hrBuffer.removeAll()
        _hrLock.unlock()
    }
    
    
    /// Send data to delegate
    ///
    /// - Parameter bytes: heart rate data
    private func handleHeartRateData(bytes: [UInt8]) {
        _hrLock.lock()
        _hrBuffer.append(contentsOf: bytes)
        if _hrBuffer.count < _hrBufferSize {
            _hrLock.unlock()
            return
        }
        let data = Data(_hrBuffer)
        _hrBuffer.removeAll()
        _hrLock.unlock()
        dataSource?.bleHeartRateDataReceived(data: data, bleManager: self)
    }
    
//    // MARK: - DFU
//    private lazy var dfu: DFU = {
//        return DFU(peripheral: self.connector!.peripheral.peripheral, manager: self.connector!.peripheral.manager.centralManager)
//    }()
//    
//    /// DFU 方法
//    ///
//    /// - Parameter fileURL: 固件文件 URL，必须是本地 URL
//    /// - Throws: 如果设备未连接会抛出错误
//    public func dfu(fileURL: URL) throws {
//        guard self.connector?.peripheral != nil else { throw BLEError.invalid(message: "设备未连接") }
//        
//        dfu.fileURL = fileURL
//        dfu.fire()
//    }
//    
}
