//
//  BrainWaveFileWriter.swift
//  NaptimeFileProtocol
//
//  Created by HyanCat on 16/8/24.
//  Copyright © 2016年 entertech. All rights reserved.
//

import Foundation

/// 脑波文件写工具
open class BrainwaveFileWriter<ValueType: BrainwaveValueType>: DataFileWriter {

    public override init() {
        super.init()
        fileType = 1
    }

    @available(*, unavailable, message: "使用 writeBrainwave(_:) 写入")
    open override func writeData(_ data: Data) throws {
        try super.writeData(data)
    }

    open func writeBrainwave<ValueType>(_ brainwave: BrainwaveData<ValueType>) throws {
        let bytes = brainwave.value.bytes
        let data = Data(bytes: bytes)
        try super.writeData(data)
    }
}

/// 分片脑波文件写工具
open class BrainwaveFileWriterV2<ValueType: BrainwaveValueType>: DataFileWriterV2 {

    public override init() {
        super.init()
        fileType = 1
    }

}
