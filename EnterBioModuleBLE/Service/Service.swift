//
//  Service.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 01/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import RxSwift
import RxBluetoothKit
import PromiseKit
import CoreBluetooth

// MARK: - Basic Protocol

public typealias Bytes = [UInt8]

public protocol Service {
    init(rxService: RxBluetoothKit.Service)
}

public class BLEService: NSObject, Service {

    public let rxService: RxBluetoothKit.Service

    public required init(rxService: RxBluetoothKit.Service) {
        self.rxService = rxService
    }
}

// MARK: - Capability Protocol

public protocol Readable: Service {
    associatedtype ReadType: CharacteristicReadType
    func read(characteristic: ReadType) -> Promise<Data>
}

public protocol Writable: Service {
    associatedtype WriteType: CharacteristicWriteType
    func write(data: Data, to characteristic: WriteType) -> Promise<Void>
}

public protocol Notifiable: Service {
    associatedtype NotifyType: CharacteristicNotifyType
    func notify(characteristic: NotifyType) -> Observable<Bytes>
}

// MARK: - ability

public extension Readable where Self: BLEService {
    public func read(characteristic: ReadType) -> Promise<Data> {
        let promise = Promise<Data> {[weak self] seal in
            guard let `self` = self else { return }
            _ = self.rxService.characteristics?.first(where: { $0.uuid == characteristic.uuid })?.readValue().subscribe(onSuccess: {
                if let data = $0.value {
                    seal.fulfill(data)
                }
            }, onError: { error in
                _ = seal.reject(error)
            })
        }
        return promise
    }
}

public extension Writable where Self: BLEService {
    public func write(data: Data, to characteristic: WriteType) -> Promise<Void> {
        let promise = Promise<Void> { seal in
            _ = self.rxService.characteristics?.first(where: { $0.uuid == characteristic.uuid })?
                .writeValue(data, type: .withResponse)
                .subscribe(onSuccess: { _ in
                    seal.fulfill(())
                }, onError: { error in
                    seal.reject(error)
                })
        }
        return promise
    }
}

public extension Notifiable where Self: BLEService {
    public func notify(characteristic: NotifyType) -> Observable<Bytes> {
        if let char =
            self.rxService.characteristics?.first(where: { $0.uuid == characteristic.uuid }) {
            return char.observeValueUpdateAndSetNotification().map {
                $0.value!.copiedBytes
            }
        }
        return Observable.error(BluetoothError.characteristicsDiscoveryFailed(self.rxService, nil))
    }
}

public extension Data {
    var copiedBytes: [UInt8] {
        var bytes = [UInt8](repeating: 0, count: self.count)
        self.copyBytes(to: &bytes, count: self.count)
        return bytes
    }
}
