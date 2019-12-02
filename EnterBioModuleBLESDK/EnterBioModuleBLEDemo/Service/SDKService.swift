//
//  SDKService.swift
//  BLETool
//
//  Created by Enter on 2019/8/26.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import UIKit
import EnterBioModuleBLE

public class SDKService: NSObject {
    public static let shared = SDKService()
    public let bleManager = BLEManager()
    private override init() {}
    
}
