//
//  BLEConnectionService.swift
//  EnterBioModuleBLEUI
//
//  Created by Enter on 2019/10/22.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import UIKit
import EnterBioModuleBLE

internal class BLEManagerClass {
    static let shared = BLEManagerClass()
    private init() {}
    var bleList: [BLEManager] = []

    public var firmwareVersion:String?

    public var firmwareURL:URL?

    public var firmwareUpdateLog:String = ""
    
    /// theme color
    public var mainColor: UIColor? = UIColor.colorFromInt(r: 0, g: 100, b: 255, alpha: 1)
    
    public var cornerRadius: CGFloat? = 8
    
}


