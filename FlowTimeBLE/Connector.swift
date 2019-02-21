//
//  Connector.swift
//  FlowTimeBLE
//
//  Created by HyanCat on 03/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxBluetoothKit
import RxSwift
import PromiseKit

public protocol DisposeHolder {
    var disposeBag: DisposeBag { get }
}

extension RxBluetoothKit.Service: Hashable {
    public var hashValue: Int {
        return self.uuid.hash
    }
}

public final class Connector: DisposeHolder {

    public typealias ConnectResultBlock = ((Bool) -> Void)
    public let peripheral: Peripheral

    public private(set) var connectService: ConnectService?
    public private(set) var commandService: CommandService?
    public private(set) var eegService: EEGService?
    public private(set) var batteryService:  BatteryService?
    public private(set) var dfuService: DFUService?
    public private(set) var deviceInfoService: DeviceInfoService?
    public private(set) var heartService: HeartService?

    public var allServices: [BLEService] {
        return ([connectService, commandService, eegService, batteryService, dfuService, deviceInfoService] as [BLEService?]).filter { $0 != nil } as! [BLEService]
    }

    private(set) var mac: Data?

    private (set) public var disposeBag: DisposeBag = DisposeBag()
    private var _disposable: Disposable?

    public init(peripheral: Peripheral) {
        self.peripheral = peripheral
    }

    public func tryConnect() -> Promise<Void> {
        let promise = Promise<Void> { [weak self] seal in
            print("time: \(Date())")
            _disposable = peripheral.establishConnection()
                .subscribe(onNext: { p in
                    _ = p.discoverServices(nil)
                        .flatMap { ss -> Single<[RxBluetoothKit.Characteristic]> in
                            ss.forEach { s in
                                print("uuid: \(s.uuid.uuidString)")
                                guard let `self` = self else { return }
                                self.assignService(s)
                            }
                            return Single<[RxBluetoothKit.Characteristic]>.create(subscribe: { event -> Disposable in
                                var disposes: [Disposable] = []
                                var allCS: [RxBluetoothKit.Characteristic] = []
                                ss.enumerated().forEach { (offset, element) in
                                    disposes.append(
                                        element.discoverCharacteristics(nil)
                                            .subscribe(onSuccess: { cs in
                                                allCS.append(contentsOf: cs)
                                                if offset == ss.count - 1 {
                                                    event(.success(allCS))
                                                }
                                            }, onError: { e in
                                                event(.error(e))
                                            })
                                    )
                                }
                                return Disposables.create {
                                    disposes.forEach {
                                        $0.dispose()
                                    }
                                }
                            })
                        }.subscribe(onSuccess: { cs in
                            print("cs: \(cs)")
                            seal.fulfill(())
                        }, onError: { e in
                            seal.reject(e)
                        })
                }, onError: { e in
                    seal.reject(e)
                }, onCompleted: {
                    //
                }, onDisposed: nil)
        }
        return promise
    }

    public func cancel() {
        _disposable?.dispose()
    }

    private var _stateListener: Disposable?
    private var _handshakeListener: Disposable?

    public func handshake(userID: UInt32 = 0) -> Promise<Void> {

        let promise = Promise<Void> { [weak self] seal in
            guard let `self` = self else {
                seal.reject(BLEError.connectFail)
                return
            }
            guard let connectService = self.connectService, let deviceInfoService = self.deviceInfoService else {
                seal.reject(BLEError.connectFail)
                return
            }

            let disposeListener = { [weak self] in
                self?._stateListener?.dispose()
                self?._handshakeListener?.dispose()
            }
            // 监听状态
            _stateListener = connectService.notify(characteristic: .state).subscribe(onNext: { bytes in
                print("state: \(bytes)")
                guard let state = HandshakeState(rawValue: bytes) else { return }

                switch state {
                case .success:
                    seal.fulfill(())
                case .error(let err):
                    seal.reject(err)
                }
                disposeListener()
            }, onError: { error in
                print("state error: \(error)")
                seal.reject(error)
                disposeListener()
            })
            _stateListener?.disposed(by: disposeBag)

            Thread.sleep(forTimeInterval: 0.1)
            // 监听 第二步握手
            _handshakeListener = connectService.notify(characteristic: .handshake).subscribe(onNext: { data in
                print("2------------ \(data)")
                var secondCommand = data
                let random = secondCommand.last!
                secondCommand.removeFirst()
                secondCommand.removeLast()
                let newRandom = UInt8(arc4random_uniform(255))
                secondCommand[0] = secondCommand[0] ^ random ^ newRandom
                secondCommand[1] = secondCommand[1] ^ random ^ newRandom
                secondCommand[2] = secondCommand[2] ^ random ^ newRandom
                secondCommand.insert(0x03, at: 0)
                secondCommand.append(newRandom)
                print("3------------ \(secondCommand)")
                // 发送 第三步握手
                connectService.write(data: Data(bytes: secondCommand), to: .handshake)
                    .catch { error in
                    seal.reject(error)
                }
            }, onError: { error in
                print("握手 error: \(error)")
                seal.reject(error)
                disposeListener()
            })
            _handshakeListener?.disposed(by: disposeBag)

            // 开始握手
            Thread.sleep(forTimeInterval: 0.1)
            // 读取 mac 地址
            deviceInfoService.read(characteristic: .mac)
                .then { data -> Promise<Void> in
                    self.mac = data
                    print("-------mac: \(data)")
                    // 发送 user id
                    let bytes = [0x00, userID >> 24, userID >> 16, userID >> 8, userID].map { $0 & 0xFF }.map { UInt8($0) }
                    return connectService.write(data: Data(bytes: bytes), to: .userID)
                }
                .then { () -> (Promise<Void>) in
                    // 发送 第一步握手
                    let date = Date()
                    let hour = UInt8(date.stringWith(formateString: "HH"))
                    let minute = UInt8(date.stringWith(formateString: "mm"))
                    let second = UInt8(date.stringWith(formateString: "ss"))
                    let random = UInt8(arc4random_uniform(255))
                    print("1------------ \([0x01 ,hour! ,minute! ,second! ,random])")
                    return connectService.write(data: Data(bytes: [0x01 ,hour! ,minute! ,second! ,random]), to: .handshake)
                }.catch { error in
                    print("握手 error: \(error)")
            }
        }
        return promise
    }

    private func assignService(_ service: RxBluetoothKit.Service) {
        guard let `type` = FlowTimeBLE.ServiceType(rawValue: service.uuid.uuidString) else { return }
        switch `type` {
        case .command:
            self.commandService = CommandService(rxService: service)
        case .connect:
            self.connectService = ConnectService(rxService: service)
        case .battery:
            self.batteryService = BatteryService(rxService: service)
        case .eeg:
            self.eegService = EEGService(rxService: service)
        case .dfu:
            self.dfuService = DFUService(rxService: service)
        case .deviceInfo:
            self.deviceInfoService = DeviceInfoService(rxService: service)
        case .heart:
            self.heartService = HeartService(rxService: service)
        }
    }
}

extension Date {
    public func stringWith(formateString: String)-> String {
        let dateFormate = DateFormatter()
        dateFormate.locale = Locale(identifier: "zh_CN")
        dateFormate.dateFormat = formateString
        return dateFormate.string(from: self)
    }
}
