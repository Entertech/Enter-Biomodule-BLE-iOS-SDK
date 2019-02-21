//
//  FragmentData.swift
//  NaptimeFileProtocol
//
//  Created by HyanCat on 25/12/2017.
//

import Foundation

/// 分片数据
open class FragmentData {
    /// 片长度
    open var length: UInt = 0
    /// UNIX 时间戳
    open var timestamp: Timestamp = unix_time()
    /// 校验数据
    public private (set) var checksum: UInt16 = 0
    /// 状态标记位
    open var flag: Flag = .normal
    /// 数据内容
    public internal (set) var data: Data = Data()

    /// 分片数据的状态标记位
    ///
    /// - normal: 正常分片
    /// - timeout: 超时分片
    /// - interrupt: 中断分片
    /// - end: 结束分片
    public enum Flag: UInt8 {
        case normal = 0x00
        case timeout = 0x01
        case interrupt = 0x02
        case end = 0xFF
    }

    /// 初始化一个分片数据
    public init() {}

    /// 写入数据
    ///
    /// - Parameter data: 待写入的数据
    public func write(data: Data) {
        self.data.append(data)
        checksum = data.reduce(checksum) { (r, item) -> UInt16 in
            return UInt16((UInt32(r) + UInt32(item)) % 256)
        }
        length += UInt(data.count)
    }
}

extension FragmentData {
    /// 转出完整的数据
    ///
    /// - Returns: 完整的数据
    public func dump() -> Data {
        var header = Data()
        header.append(contentsOf: convert(value: length, length: 4))
        header.append(contentsOf: convert(value: timestamp, length: 4))
        header.append(contentsOf: convert(value: UInt(checksum), length: 2))
        header.append(flag.rawValue)
        header.append(contentsOf: [UInt8](repeating: 0x00, count: 5))

        return header + data
    }

    private func convert(value: UInt, length: Int) -> Bytes {
        var dataLengthBytes = Bytes()
        var left = value
        repeat {
            dataLengthBytes.insert(UInt8(left%256), at: 0)
            left = left / 256
        } while dataLengthBytes.count < length

        return dataLengthBytes
    }
}

extension FragmentData {
    /// 通过原始的片头和片数据体来构造片数据对象
    ///
    /// - Parameters:
    ///   - header: 片头数据
    ///   - body: 片数据体，可以暂时为 nil
    convenience init(header: Bytes, body: Data? = nil) {
        self.init()

        guard header.count == 16 else { return }

        length = convertBytesToValue(bytes: Bytes(header[0..<4]))
        timestamp = convertBytesToValue(bytes: Bytes(header[4..<8]))
        checksum = UInt16(convertBytesToValue(bytes: Bytes(header[8..<10])))
        flag = Flag(rawValue: header[10]) ?? .normal
        if let body = body {
            data = body
        }
    }

    private func convertBytesToValue(bytes: Bytes) -> UInt {
        return bytes.reduce(0) { (r, b) -> UInt in
            return (r<<8) + UInt(b)
        }
    }
}
