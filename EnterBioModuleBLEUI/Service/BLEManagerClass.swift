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
    /// 需要升级的版本号
    public var firmwareVersion:String?
    /// 升级的沙盒路径
    public var firmwareURL:URL?
    /// 升级版本更新日志
    public var firmwareUpdateLog:String = ""
    
    /// 主色调
    public var mainColor: UIColor? = UIColor.colorFromInt(r: 0, g: 100, b: 255, alpha: 1)
    
    /// 圆角
    public var cornerRadius: CGFloat? = 8
    
}


