//
//  Common.swift
//  EnterBioModuleBLE
//
//  Created by NyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol UUIDType {
    var uuid: String { get }
}

let UUID_BLE_DEVICE = "0000FF10-1212-ABCD-1523-785FEABCD123"

enum ServiceUUID: String, UUIDType {
    case generic = ""

    var uuid: String {
        return self.rawValue
    }
}
