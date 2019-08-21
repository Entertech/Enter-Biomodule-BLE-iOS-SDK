//
//  BLEType.swift
//  EnterBioModuleBLE
//
//  Created by Enter on 2019/8/14.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import Foundation

/// BLE connect State
///
/// - disconnected: 断开或未连接
/// - searching: 搜索中
/// - connecting: 连接中
/// - connected: 连接成功
public enum BLEConnectionState {
    case disconnected
    case searching
    case connecting
    case connected(BLEWearState)
}

extension BLEConnectionState {
    /// is BLE Connected
    public var isConnected: Bool {
        switch self {
        case .connecting, .searching, .disconnected:
            return false
        case .connected(_):
            return true
        }
    }
}

extension BLEConnectionState {
    public var isBusy: Bool {
        switch self {
        case .disconnected:
            return false
        case .searching, .connecting, .connected(_):
            return true
        }
    }
}

extension BLEConnectionState: Equatable {
    public static func == (lhs: BLEConnectionState, rhs: BLEConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.disconnected, .disconnected), (.searching, .searching), (.connecting, .connecting):
            return true
        case (let .connected(wear1), let .connected(wear2)):
            return wear1.rawValue == wear2.rawValue
        default:
            return false
        }
    }
}

/// 佩戴状态
///
/// - allWrong: 全部不正常
/// - referenceWrong: 参考电极不正常
/// - activeWrong: 活动电极不正常
/// - normal: 佩戴正常

//TODO: - 完善佩戴数值信息
public enum BLEWearState: UInt8 {
    case allWrong = 0x18
    case referenceWrong = 0x10
    case activeWrong = 0x08
    case normal = 0x00
}

extension BLEWearState {
    /// 是否佩戴正常
    public var isOK: Bool {
        return self == .normal
    }
}

/// DFU 各阶段状态
///
/// - none: 无状态
/// - prepared: 设备准备
/// - upgrading: 正在升级（含进度）
/// - succeeded: 升级成功
/// - failed: 升级失败
public enum DFUState {
    case none
    case prepared
    case upgrading(progress: UInt8)
    case succeeded
    case failed
}

/// 电量信息
public struct Battery {
    /// 当前电压（伏特）
    public let voltage: Float
    /// 遗留电量（小时），仅供参考
    public let remain: Int
    /// 电量百分比值 [0, 100]
    public let percentage: Float
}

/// 基本设备信息
public struct BLEDeviceInfo {
    /// 设备名称
    public internal (set) var name: String = ""
    /// 设备硬件版本
    public internal (set) var hardware: String = ""
    /// 设备固件版本
    public internal (set) var firmware: String = ""
    /// 设备 mac 地址
    public internal (set) var mac: String = ""
}
