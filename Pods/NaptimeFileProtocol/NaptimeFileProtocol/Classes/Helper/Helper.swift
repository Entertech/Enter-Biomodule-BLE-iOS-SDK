//
//  Helper.swift
//  NaptimeFileProtocol
//
//  Created by HyanCat on 16/8/24.
//  Copyright © 2016年 entertech. All rights reserved.
//

import Foundation

// MARK: - Array 数组扩展
extension Array {

    /**
     连接数组的所有元素为字符串

     - parameter joinString: 连接字符串

     - returns: 连接后完整字符串
     */
    func componentsJoinedByString(_ joinString: String) -> String {
        return self.map {
            return String(describing: $0)
        }.joined(separator: joinString)
    }

    /**
     分隔数组为等量的子数组

     - parameter subSize: 子数组的 size

     - returns: 分割后的数组
     */
    func splitBy(_ subSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: subSize).map { startIndex in
            let endIndex = startIndex.advanced(by: subSize)
            return Array(self[startIndex ..< endIndex])
        }
    }
}

// MARK: - NSData 扩展
extension Data {

    /// 获取完整数据的 range
    var fullRange: NSRange {
        return NSMakeRange(0, self.count)
    }

    /// 获取所有的字节
    var allBytes: Bytes {
        return try! self.bytesInRange(self.fullRange)
    }

    /**
     获取在某个范围内的字节序列

     - parameter range: NSRange 范围

     - throws: 如果 range 超出范围，可能抛出 `OutOfRangeError`

     - returns: 返回 range 范围内的字节序列
     */
    func bytesInRange(_ range: NSRange) throws -> [Byte] {
        if range.location + range.length > self.count {
            throw DataFileOutOfRangeError()
        }
        var thisBytes: [Byte] = [Byte](repeating: 0, count: range.length)
        (self as NSData).getBytes(&thisBytes, range: range)
        return thisBytes
    }

    /**
     获取指定位置的字节

     - parameter index: 位置索引

     - throws: 如果 index 超出范围，可能会抛出 `OutOfRangeError`

     - returns: 返回 index 位置的字节
     */
    func byteAtIndex(_ index: Int) throws -> Byte {
        if index >= self.count {
            throw DataFileOutOfRangeError()
        }
        var thisBytes: [Byte] = [0]
        (self as NSData).getBytes(&thisBytes, range: NSMakeRange(index, 1))
        return thisBytes[0]
    }
}

func unix_time() -> Timestamp {
    return Timestamp(Date().timeIntervalSince1970)
}
