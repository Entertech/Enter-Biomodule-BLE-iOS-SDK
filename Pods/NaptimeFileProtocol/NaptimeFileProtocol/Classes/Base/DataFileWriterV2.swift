//
//  DataFileWriterV2.swift
//  NaptimeFileProtocol
//
//  Created by HyanCat on 25/12/2017.
//

import Foundation

/// V2 的写数据类
open class DataFileWriterV2: DataFileWriter {

    public override init() {
        super.init()
        protocolVersion = "2.0"
    }

    @available(*, unavailable, message: "使用 write(fragment:) 分片写入")
    open override func writeData(_ data: Data) throws {
        try super.writeData(data)
    }

    /// 写入一个分片数据
    ///
    /// - Parameter fragment: 分片数据
    /// - Throws: 写入异常
    open func write(fragment: FragmentData) throws {
        let data = fragment.dump()
        try super.writeData(data)
    }

}
