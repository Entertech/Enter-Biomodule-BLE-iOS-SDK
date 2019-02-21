//
//  ReportData.swift
//  NaptimeFileProtocol
//
//  Created by Anonymous on 2018/11/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

let ScalarTypeLength = 4

/// ReportData 由标量数据（scalars）和绘图数组组成 (digitals)
public class ReportData {
    public let scalars: [Scalar]
    public let digitals: [Digital]

    public init(scalars: [Scalar], digitals: [Digital]) {
        self.scalars = scalars
        self.digitals = digitals
    }

    public func data() -> Data {
        var datas = Data()
        // 标量数据
        for scalar in scalars {
            datas.append(scalar.data())
        }

        // 数据数据
        for digital in digitals {
            datas.append(digital.data())
        }

        return datas
    }
}

/// 标量数据: 有 1 个字节和 3 个字节的 value 组成
public struct Scalar {
    public let type: ScalarType
    public let value: UInt32
    
    public init(type: ScalarType, value: UInt32) {
            self.type = type
            self.value = value
    }

    public func data() -> Data {
        var bts = [UInt8]()
        bts.append(type.rawValue)
        let elements = Mirror(reflecting: value.toInt24().bytes)
        for b in elements.children.map({ $0.value }) {
            bts.append(b as! UInt8)
        }
        return Data(bytes: bts)
    }
}

/// 数组数据: 绘制报表的曲线数据类型：由 1 个字节的 type 和 3 个字节的 length 再加 bodyDatas 组成
public struct Digital {
    public let type: DigitalType
    public let length: UInt32
    public let bodyDatas: Data

    public init(type: DigitalType, length: UInt32, data: Data) {
        self.type      = type
        self.length    = length
        self.bodyDatas = data
    }

    public func data() -> Data {
        var data = Data()
        data.append(contentsOf: [type.rawValue])
        data.append(length.toInt24().data())
        data.append(self.bodyDatas)
        return data
    }
}

/// 标量类型
///
/// - retained: 保留
/// - score: 体验分数
/// - sleeped: 入睡点
/// - wakeup: 唤醒点
/// - soberLevel: 清醒纵坐标 （数组下标）
/// - blurryLevel: 迷糊纵坐标（数组下标）
/// - sleepedLeved: 入睡纵坐标（数组下标）
/// - intervalTime: 数组数据时间间隔（单位：毫秒）
public enum ScalarType: Byte {
    case retained     = 0x00
    case score        = 0x01
    case sleeped      = 0x02
    case wakeup       = 0x03
    case soberLevel   = 0x04
    case blurryLevel  = 0x05
    case sleepedLeved = 0x06
    case intervalTime = 0x07
    case wearQuality  = 0x08
    case sleepLatency = 0x09
    case clockPoint   = 0x0a
}


/// 绘制图标数据类型
///
/// - retained: 保留
/// - napCurve: 小睡曲线
/// - napState: 小睡状态
public enum DigitalType: Byte {
    case retained      = 0x00
    case napCurve      = 0xf1
    case napState      = 0xf2
    case sleepNosie    = 0xf3
    case sleepDayDream = 0xf4
    case sleepSnore    = 0xf5
}

public struct UInt24 {
    var bytes: (UInt8, UInt8, UInt8)
    init(_ bytes: (UInt8, UInt8, UInt8)) {
        self.bytes = bytes
    }

    public func int32Value() -> UInt32 {
        return (UInt32(self.bytes.0) << 16 + UInt32(self.bytes.1) << 8 + UInt32(self.bytes.2))
    }

    public func data() -> Data {
        var bts = [UInt8]()
        let elements = Mirror(reflecting: self.bytes)
        for b in elements.children.map({ $0.value }) {
            bts.append(b as! UInt8)
        }
        return Data(bytes: bts)
    }
}


extension UInt32 {
    func toInt24() -> UInt24 {
        let v0 = ((255 << 16) & self) >> 16
        let v1 = ((255 << 8) & self) >> 8
        let v2 = 255 & self 
        return UInt24((UInt8(v0), UInt8(v1), UInt8(v2)))
    }
}
