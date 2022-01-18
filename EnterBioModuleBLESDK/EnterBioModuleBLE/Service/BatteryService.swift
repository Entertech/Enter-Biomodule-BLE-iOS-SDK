//
//  BatteryService.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import PromiseKit
import RxSwift

public class BatteryService: BLEService {
}

extension BatteryService: Readable {
    public typealias ReadType = EnterCharacteristic.Battery
}

extension BatteryService: Notifiable {
    public typealias NotifyType = EnterCharacteristic.Battery
}

extension BatteryService: ServiceTypable {
    public var serviceType: ServiceType {
        return .battery
    }
}
