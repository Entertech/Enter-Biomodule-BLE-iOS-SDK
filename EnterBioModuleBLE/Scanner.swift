//
//  BLEScanner.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 01/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxBluetoothKit
import RxSwift
import PromiseKit

extension DispatchQueue {
    static let ble: DispatchQueue = DispatchQueue(label: "cn.entertech.EnterBioModuleBLE.BLE")
}

public final class Scanner {

    var manager: CentralManager
    private let _disposeBag = DisposeBag()

    private var _observer: Observable<Peripheral>?
    private var _disposable: Disposable?

    private var _usingPeripheral: Peripheral?

    public init() {
        manager = CentralManager(queue: .ble,
                                 options: [CBCentralManagerOptionShowPowerAlertKey: true as AnyObject,
                                           CBCentralManagerOptionRestoreIdentifierKey: "naptime.ble.id" as AnyObject])
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

    public func stop() {
        _disposable?.dispose()
        self.manager.centralManager.stopScan()
    }

    public func use(peripheral: Peripheral) {
        _usingPeripheral = peripheral
    }
}
