//
//  AnalyzedFileWriter.swift
//  NaptimeFileProtocol
//
//  Created by HyanCat on 16/8/24.
//  Copyright © 2016年 entertech. All rights reserved.
//

import Foundation

/// 分析后文件写工具
open class AnalyzedFileWriter: DataFileWriter {

    public override init() {
        super.init()
        fileType = 2
    }

    @available(*, unavailable, message: "使用 writeAnalyzingData(_:) 写入")
    open override func writeData(_ data: Data) throws {
        try super.writeData(data)
    }

    open func writeAnalyzingData(_ analyzingData: AnalyzingData) throws {
        try super.writeData(analyzingData.data)
    }
}

open class AnalyzedFileWriterV2: DataFileWriterV2 {

    public override init() {
        super.init()
        fileType = 2
    }

}
