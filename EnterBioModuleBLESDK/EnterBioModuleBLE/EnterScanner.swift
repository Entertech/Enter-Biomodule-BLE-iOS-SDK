//
//  BLEScanner.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 01/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift
import PromiseKit

extension DispatchQueue {
    static let ble: DispatchQueue = DispatchQueue(label: "cn.entertech.EnterBioModuleBLE.BLE")
}

public final class EnterScanner {

    public var manager: CentralManager
    private let _disposeBag = DisposeBag()

    private var _observer: Observable<Peripheral>?
    private var _disposable: Disposable?

    private var _usingPeripheral: Peripheral?
    private var _bleId = 0

    public init() {
        manager = CentralManager(queue: .ble,
                                 options: [CBCentralManagerOptionShowPowerAlertKey: true as AnyObject,
                                           CBCentralManagerOptionRestoreIdentifierKey: "entertech.ble.\(_bleId)" as AnyObject])
    }

    public func scan() -> Observable<ScannedPeripheral> {

        return Observable<ScannedPeripheral>.create { [unowned self] (observer) -> Disposable in

            let disposable = self.manager.scanForPeripherals(withServices: [CBUUID(string: UUID_BLE_DEVICE)])
                .subscribe(onNext: {
                    observer.onNext($0)
                }, onError: {
                    observer.onError($0)
                }, onCompleted: {
                    observer.onCompleted()
                })
            disposable.disposed(by: self._disposeBag)
            self._disposable = Disposables.create {
                disposable.dispose()
            }
            return self._disposable!
        }
    }
    
    public func scan(uuid: String) -> Observable<ScannedPeripheral> {

        return Observable<ScannedPeripheral>.create { [unowned self] (observer) -> Disposable in

            let disposable = self.manager.scanForPeripherals(withServices: [CBUUID(string: uuid)])
                .subscribe(onNext: {
                    observer.onNext($0)
                }, onError: {
                    observer.onError($0)
                }, onCompleted: {
                    observer.onCompleted()
                })
            disposable.disposed(by: self._disposeBag)
            self._disposable = Disposables.create {
                disposable.dispose()
            }
            return self._disposable!
        }
    }

    public func stop() {
        _disposable?.dispose()
        self.manager.manager.stopScan()
    }
    
    public func reCreateManager() {
        _disposable?.dispose()
        _bleId += 1
        self.manager = CentralManager(queue: .ble,
        options: [CBCentralManagerOptionShowPowerAlertKey: true as AnyObject,
                  CBCentralManagerOptionRestoreIdentifierKey: "entertech.ble.\(_bleId)" as AnyObject])
    }

    public func use(peripheral: Peripheral) {
        _usingPeripheral = peripheral
    }
}
