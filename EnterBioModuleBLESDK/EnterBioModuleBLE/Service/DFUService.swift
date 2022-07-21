//
//  DFUService.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import CoreBluetooth
//import iOSDFULibrary

//public protocol DFUStateDelegate: class {
//    func dfuStateChanged(state: DFUState)
//}

public class DFUService: BLEService {
}

extension DFUService: ServiceTypable {
    public var serviceType: ServiceType {
        return .dfu
    }
}

