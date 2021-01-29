//
//  BLEConnectViewController.swift
//  EnterBioModuleBLEUI
//
//  Created by Enter on 2019/10/9.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import UIKit
import EnterBioModuleBLE

public class BLEConnectViewController: UINavigationController, UIGestureRecognizerDelegate {
    
    /// 需要升级的版本号
    public var firmwareVersion:String = "" {
        didSet {
            BLEManagerClass.shared.firmwareVersion = self.firmwareVersion
        }
    }
    /// 升级的沙盒路径,  xxx/xxx/xx.zip
    public var firmwareURL:URL? = nil {
        didSet {
            BLEManagerClass.shared.firmwareURL = self.firmwareURL
        }
    }
    /// 升级版本更新日志
    public var firmwareUpdateLog:String = "" {
        didSet {
            BLEManagerClass.shared.firmwareUpdateLog = self.firmwareUpdateLog
        }
    }
    /// 圆角角度
    public var cornerRadius: CGFloat = 8 {
        didSet {
            BLEManagerClass.shared.cornerRadius = self.cornerRadius
        }
        
    }
    /// 主色调
    public var mainColor: UIColor = UIColor.colorFromInt(r: 0, g: 100, b: 255, alpha: 1) {
        didSet  {
            BLEManagerClass.shared.mainColor = self.mainColor
        }
    }
    
    /// 是否通过mac地址连接
    public var isConnectByMac:Bool{
        get {
            return UserDefaults.standard.bool(forKey: "isConnectByMac")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isConnectByMac")
        }
    }
    
    /// 初始化
    /// - Parameter bleManager: 需要连接的BLEManager实例
    public init(bleManager: BLEManager) {
        super.init(nibName: nil, bundle: nil)
        Language.initLocale()
        let manager = bleManager
        let isAuth = manager.isBluetoothOpenAndAllow()
        if !isAuth {
            let tipVC = BLETipViewController()
            setViewControllers([tipVC], animated: true)
        } else {
            BLEManagerClass.shared.bleList.removeAll()
            BLEManagerClass.shared.bleList.append(bleManager)
            if manager.state.isConnected {
                let bleView = BLEStateViewController(index: 0, cornerRadius, mainColor)
                setViewControllers([bleView], animated: true)
            } else {
                let deviceConnectionVC = BLEConnectTipViewController(index: 0)
                setViewControllers([deviceConnectionVC], animated: true)
            }

        }
        self.interactivePopGestureRecognizer?.delegate = self
        self.modalPresentationStyle = .fullScreen
    }
    
    /// 初始化
    /// - Parameter bleManager: 需要连接的BLEManager实例数组，最大为4个
    public init(bleManagers: [BLEManager]) {
        super.init(nibName: nil, bundle: nil)
        Language.initLocale()
        let manager = BLEManager()
        let isAuth = manager.isBluetoothOpenAndAllow()
        if !isAuth {
            let tipVC = BLETipViewController()
            setViewControllers([tipVC], animated: true)
        } else {
            BLEManagerClass.shared.bleList.removeAll()
            let deviceConnectionVC = DeviceConnectionViewController(bleArray: bleManagers)
            setViewControllers([deviceConnectionVC], animated: true)
        }
        self.interactivePopGestureRecognizer?.delegate = self
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}
