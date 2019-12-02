//
//  CommandService.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift
import PromiseKit

public class CommandService: BLEService {
    
}

extension CommandService: Writable {

    public typealias WriteType = Characteristic.Command.Write

}

extension CommandService: Notifiable {

    public typealias NotifyType = Characteristic.Command.Notify

}

extension CommandService: ServiceTypable {
    public var serviceType: ServiceType {
        return .command
    }
}
