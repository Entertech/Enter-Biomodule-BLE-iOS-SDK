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
import FixedDFUService
import CoreBluetooth


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
    
    private var lastState: BLEConnectionState = .connecting
    /// connection state
    public private(set) var state: BLEConnectionState = .disconnected {
        didSet {
            guard lastState != self.state else {return}
            lastState = self.state
            delegate?.bleConnectionStateChanged(state: self.state, bleManager: self)
            var value = 0
            switch state {
            case .disconnected:
                value = 0
            case .searching:
                value = 1
            case .connecting:
                value = 2
            case .connected(_):
                value = 3
            }
            NotificationCenter.default.post(name: NSNotification.Name("BLEConnectionStateNotify"), object: nil, userInfo: ["value":value])
        }
    }
    
    /// device info
    public private(set) var deviceInfo: BLEDeviceInfo = BLEDeviceInfo(name: "Flowtime",
                                                                       hardware: "0.0.0",
                                                                       firmware: "0.0.0",
                                                                       mac: "00.00.00.00.00.00")
    ///battery
    public private(set) var battery: Battery? = nil {
        willSet {
            DLog("batter send \(newValue?.percentage ?? 0)")
            guard let battery = newValue else {
                return
            }
            delegate?.bleBatteryReceived(battery: battery, bleManager: self)
            NotificationCenter.default.post(name: NSNotification.Name("BatteryNotify"), object: nil, userInfo: ["value":battery])
            
        }
    }
    
    /// scanner
    private var scanner = Scanner()
    /// connector
    public var connector: Connector?
    private var disposalbe: Disposable?
    private var bleQueue = DispatchQueue(label: "com.entertech.EnterBioModuleBLE.listener")
    
    // MARK: - connect logic
    /// Scan peripheral with 3 second and connect
    ///
    /// - Parameters:
    ///   - completion: complete block
    public func scanAndConnect(_ mac:String? = nil, completion: Connector.ConnectResultBlock?) throws {
        if self.state.isBusy {
            throw BLEError.busy
        }
        if let mac = mac  {
            searchPeripheral(for: mac)
                .then { [unowned self] in
                self.connect(peripherals: $0, mac: mac)
            }.done{
                completion?(true)
            }.catch { _ in
                completion?(false)
            }
        } else {
            searchPeripheral()
                .then { [unowned self] in
                    self.connect(peripheral: $0.peripheral)
                }.done {
                    completion?(true)
                }.catch { _ in
                    completion?(false)
                }
        }
        
    }
    
    public func disconnect() {
        reset()
    }
    
    
    /// Scan peripheral
    ///
    /// - Returns: peripheral which closer
    private func searchPeripheral(for mac:String) -> Promise<[ScannedPeripheral]> {
        let promise = Promise<[ScannedPeripheral]> { [weak self] seal in
            guard let `self` = self else { return }
            self.state = .searching
            self.disposalbe?.dispose()
            self.disposalbe = scanner.scan()
                .buffer(timeSpan: 3.0, count: 10, scheduler: MainScheduler.asyncInstance)
                .subscribe(onNext: { (peripherals) in
                    self.state = .connecting
                    
                    if peripherals.count > 0 {
                        seal.fulfill(peripherals)
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
    private func connect(peripherals: [ScannedPeripheral], mac: String) -> Promise<Void> {
        state = .connecting
        let group = DispatchGroup.init()
        
        for e in peripherals {
            var sameAndConnect: (Bool, Bool) = (false, false) //0,是否读取到信息 1,是否连接
            self.connector?.cancel()
            self.connector = Connector(peripheral: e.peripheral)
            self.connector!.tryConnect().done(on: DispatchQueue.init(label: "connect")) {
                self.connector!.deviceInfoService?.read(characteristic: .mac).done(on:DispatchQueue.init(label: "connect")) { data -> Void in
                let macRead = data.copiedBytes.reversed().map { String(format: "%02X", $0) }.joined(separator: ":")
                    if macRead == mac {
                        sameAndConnect = (true, true)
                    } else  {
                        sameAndConnect = (false, true)
                    }
                }.catch { _ in
                    sameAndConnect = (false, true)
                }
            }.catch { (_) in
            }
            
            group.enter()
            DispatchQueue.global().async {
                var sleepCount = 0
                while (!sameAndConnect.1) {//如果没有连接成功，则循环
                    Thread.sleep(forTimeInterval: 0.2)
                    sleepCount += 1
                    if sleepCount > 10 {
                        break
                    }
                }
                group.leave()
                
            }
            group.wait()
            if sameAndConnect.0 {
                let promise = Promise<Void> {[unowned self] seal in
                    self.readBattery()
                    self.readDeviceInfo()
                    self.state = .connected(0x0f)
                    self.listenConnection()
                    self.listenWear()
                    self.listenBattery()
                    seal.fulfill(())
 
                }
                
                return promise
            } else {
                disconnect()
            }

        }
        let promise = Promise<Void> { seal in
            seal.fulfill(())
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
                    self.state = .connected(0x0f)
                    self.listenBattery()
                    self.listenConnection()
                    self.listenWear()
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
        DLog("start listen connection")
        observers.connection = connector?.peripheral.observeConnection()
            .observeOn(ConcurrentDispatchQueueScheduler.init(queue: bleQueue))
            .subscribe(onNext: { [weak self] isConnected in
                guard let `self` = self else { return }
                DLog("listening connection")
                self.state = isConnected ? .connected(0x0f) : .disconnected
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
    
    // https://shimo.im/docs/80f5ce5b32ee49eb/read
    /************************************************/
    /**********四个电极从左至右分别对应的未接触数据为***********/
    /*******0x08,  0x10,  0x40, 0x20***********************/
    /*******如第1,2个未接触为 xxoo = 0x18***************/
    /// This service tell us if the device is wore
    private func listenWear() {
        observers.wearing = connector?.eegService?.notify(characteristic: .contact).observeOn(ConcurrentDispatchQueueScheduler.init(queue: bleQueue))
            .subscribe(onNext: { [unowned self] in
                guard let value = $0.first, self.state.isConnected else { return }
                // 因为数据不是从左到右显示,为了方便理解数据,这里除以8,以二进制1111进行表示
                // 比如xoox转化为 1001 , 实际返回数据为5
                var wearState: UInt8 = 0
                let temp = value / 8
                wearState = temp >> 2 & 1 == 1 ? 1 : 0
                wearState = temp >> 3 & 1 == 1 ? wearState | 2 : wearState
                wearState = temp >> 1 & 1 == 1 ? wearState | 4 : wearState
                wearState = temp & 1 == 1 ? wearState | 8 : wearState
                self.state = .connected(wearState)
            })
    }
    
    private func unlistenWear() {
        observers.wearing?.dispose()
        observers.wearing = nil
    }
    
    
    /// Read device's battery
    private func readBattery() {
        DLog("start read battery")
        self.connector?.batteryService?.read(characteristic: .battery)
            .done { [weak self] in
                DLog("end read battery")
                guard let value = $0.copiedBytes.first else { return }
                self?.battery = self?.battery(from: value)
        }.catch { _ in
            //
        }
    }
    
    /// Battery listenner
    private func listenBattery() {
        DLog("start listen battery")

        self.observers.battery = self.connector?.batteryService?.notify(characteristic: .battery).delay(RxTimeInterval.milliseconds(100), scheduler: ConcurrentDispatchQueueScheduler.init(queue: self.bleQueue))
                .subscribe(onNext: { [weak self] in
                    guard let self = self else {return}
                    DLog("listening battery")
                    guard let value = $0.first else { return }
                    self.battery = self.battery(from: value)
                })
        
    }
    
    private func unlistenBattery() {
        observers.battery?.dispose()
        observers.battery = nil
        self.battery = nil
    }
    
    ///
    private func readDeviceInfo() {
        DLog("start read info")
        connector?.deviceInfoService?.read(characteristic: .hardwareRevision).done { [weak self] in
            DLog("End read hardware")
            self?.deviceInfo.hardware = String(data: $0, encoding: .utf8) ?? ""
            }.catch { _ in }
        connector?.deviceInfoService?.read(characteristic: .firmwareRevision).done { [weak self] in
            DLog("End read firmware")
            self?.deviceInfo.firmware = String(data: $0, encoding: .utf8) ?? ""
            }.catch { _ in }
        connector?.deviceInfoService?.read(characteristic: .mac).done { [weak self] data -> Void in
            DLog("End read mac")
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
        scanner.reCreateManager()
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
        
    }
    
    public func checkDevice() {
        _ = self.connector?.commandService?.write(data: Data([0x79]), to: .send)
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
    
    public func isBluetoothOpenAndAllow() -> Bool {
        var isOpenAndAllow = false
        switch scanner.manager.state {
        
        case .unknown:
            isOpenAndAllow = true
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            break
        case .poweredOn:
            isOpenAndAllow = true
 
        }
        return isOpenAndAllow
    }
    
    // MARK: - DFU
    private lazy var dfu: DFU = {
        return DFU(peripheral: self.connector!.peripheral.peripheral, manager: self.connector!.peripheral.manager.manager)
    }()
    
    /// DFU 方法
    ///
    /// - Parameter fileURL: 固件文件 URL，必须是本地 URL
    /// - Throws: 如果设备未连接会抛出错误
    public func dfu(fileURL: URL) throws {
        guard self.connector?.peripheral != nil else { throw BLEError.invalid(message: "设备未连接") }
        
        dfu.fileURL = fileURL
        dfu.fire()
    }
    
}




// Device Firmware Upgrade
public class DFU: DFUServiceDelegate, DFUProgressDelegate {

    public var fileURL: URL!

    private let peripheral: CBPeripheral
    private let manager: CBCentralManager

    public init(peripheral: CBPeripheral, manager: CBCentralManager) {
        self.peripheral = peripheral
        self.manager = manager
    }

    private (set) var state: DFUState = .none {
        didSet {
            //NotificationName.dfuStateChanged.emit([NotificationKey.dfuStateKey.rawValue: state])
            NotificationCenter.default.post(name: ExtensionService.bleStateChanged, object: nil, userInfo: ["dfuStateKey":state])
        }
    }

    public func fire() {
        let initiator = DFUServiceInitiator(centralManager: manager, target: peripheral)
        initiator.delegate = self
        initiator.progressDelegate = self
        initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
        let firmware = DFUFirmware(urlToZipFile: fileURL, type: .application)

        _ = initiator.with(firmware: firmware!).start()
    }

    public func dfuStateDidChange(to state: FixedDFUService.DFUState) {
        print("dfu state: \(state.description())")
        switch state {
        case .connecting:
            self.state = .prepared
        case .starting:
            self.state = .prepared
        case .enablingDfuMode:
            self.state = .prepared
        case .uploading:
            self.state = .prepared
        case .validating:
            self.state = .prepared
        case .disconnecting:
            break
        case .completed:
            self.state = .succeeded
        case .aborted:
            self.state = .failed
        }
    }

    public func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        self.state = .failed
    }

    public func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        self.state = .upgrading(progress: UInt8(progress))
    }
}

class ExtensionService: NSObject {
    
    static let bleStateChanged = NSNotification.Name(rawValue: "dfuStateChanged")

}
