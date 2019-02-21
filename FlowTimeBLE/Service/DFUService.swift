//
//  DFUService.swift
//  FlowTimeBLE
//
//  Created by HyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

public class DFUService: BLEService {
}

extension DFUService: ServiceTypable {
    public var serviceType: ServiceType {
        return .dfu
    }
}
