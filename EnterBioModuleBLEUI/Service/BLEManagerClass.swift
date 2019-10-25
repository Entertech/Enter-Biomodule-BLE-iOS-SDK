//
//  BLEConnectionService.swift
//  EnterBioModuleBLEUI
//
//  Created by Enter on 2019/10/22.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import UIKit
import CoreBluetooth
import iOSDFULibrary
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

///// DFU 各阶段状态
/////
///// - none: 无状态
///// - prepared: 设备准备
///// - upgrading: 正在升级（含进度）
///// - succeeded: 升级成功
///// - failed: 升级失败
public enum DFUState {
    case none
    case prepared
    case upgrading(progress: UInt8)
    case succeeded
    case failed
}

// Device Firmware Upgrade
class DFU: DFUServiceDelegate, DFUProgressDelegate {

    var fileURL: URL!

    private let peripheral: CBPeripheral
    private let manager: CBCentralManager

    init(peripheral: CBPeripheral, manager: CBCentralManager) {
        self.peripheral = peripheral
        self.manager = manager
    }

    private (set) var state: DFUState = .none {
        didSet {
            //NotificationName.dfuStateChanged.emit([NotificationKey.dfuStateKey.rawValue: state])
            NotificationCenter.default.post(name: ExtensionService.bleStateChanged, object: nil, userInfo: ["dfuStateKey":state])
        }
    }

    func fire() {
        let initiator = DFUServiceInitiator(centralManager: manager, target: peripheral)
        initiator.delegate = self
        initiator.progressDelegate = self
        initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
        let firmware = DFUFirmware(urlToZipFile: fileURL, type: .application)

        _ = initiator.with(firmware: firmware!).start()
    }

    func dfuStateDidChange(to state: iOSDFULibrary.DFUState) {
        print("dfu state: \(state.description())")
        switch state {
        case .connecting:
            self.state = .prepared
        case .starting:
            self.state = .prepared
        case .enablingDfuMode:
            self.state = .prepared
        case .uploading:
            self.state = .prepared
        case .validating:
            self.state = .prepared
        case .disconnecting:
            break
        case .completed:
            self.state = .succeeded
        case .aborted:
            self.state = .failed
        }
    }

    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        self.state = .failed
    }

    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        self.state = .upgrading(progress: UInt8(progress))
    }
}
