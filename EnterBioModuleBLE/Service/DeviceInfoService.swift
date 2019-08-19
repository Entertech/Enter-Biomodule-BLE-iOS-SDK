//
//  DeviceInfoService.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import PromiseKit

public class DeviceInfoService: BLEService {
}

extension DeviceInfoService: Readable {

    public typealias ReadType = Characteristic.DeviceInfo

}

extension DeviceInfoService: ServiceTypable {
    public var serviceType: ServiceType {
        return .deviceInfo
    }
}
