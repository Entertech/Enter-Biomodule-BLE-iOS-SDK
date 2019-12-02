//
//  Connector.swift
//  EnterBioModuleBLE
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

    private func assignService(_ service: RxBluetoothKit.Service) {
        guard let `type` = EnterBioModuleBLE.ServiceType(rawValue: service.uuid.uuidString) else { return }
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
