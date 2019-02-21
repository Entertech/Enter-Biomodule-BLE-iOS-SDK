//
//  BrainWaveData.swift
//  Pods
//
//  Created by HyanCat on 16/8/25.
//
//

import Foundation

/// 位数
public enum BitCount: Byte {
    public typealias RawValue = Byte

    case bit16 = 16
    case bit24 = 24

    /// 字节数
    public var byteCount: Byte {
        return self.rawValue/8
    }
}

/// 脑波值类型定义
public protocol BrainwaveValueType {
    static var bitCount: BitCount { get }

    var bytes: [Byte] { get }

    init(bytes: [Byte])
}

/**
 * 脑波数据结构
 */
public struct BrainwaveData<ValueType: BrainwaveValueType> {
    public let value: ValueType

    public init(value: ValueType) {
        self.value = value
    }
}

public struct BrainwaveValue16: BrainwaveValueType {
    public static var bitCount: BitCount {
        return .bit16
    }

    public var bytes: [Byte]

    public init(bytes: [Byte]) {
        self.bytes = bytes
        if bytes.count != type(of: self).bitCount.byteCount {
            fatalError("脑波数据位数不对")
        }
    }
}

public struct BrainwaveValue24: BrainwaveValueType {
    public static var bitCount: BitCount {
        return .bit24
    }

    public var bytes: [Byte]

    public init(bytes: [Byte]) {
        self.bytes = bytes
        if bytes.count != type(of: self).bitCount.byteCount {
            fatalError("脑波数据位数不对")
        }
    }
}

extension BrainwaveData {
    public var data: Data {
        return Data(bytes: self.value.bytes)
    }
}

