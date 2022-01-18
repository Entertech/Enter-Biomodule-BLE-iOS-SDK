//
//  ConnectService.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 11/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

public class ConnectService: BLEService {
}

extension ConnectService: Writable {
    public typealias WriteType = EnterCharacteristic.Connect.Write
}

extension ConnectService: Notifiable {
    public typealias NotifyType = EnterCharacteristic.Connect.Notify
}

extension ConnectService: ServiceTypable {
    public var serviceType: ServiceType {
        return .connect
    }
}
