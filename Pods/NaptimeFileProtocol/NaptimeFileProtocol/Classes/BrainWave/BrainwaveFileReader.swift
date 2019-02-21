//
//  BrainWaveFileReader.swift
//  NaptimeFileProtocol
//
//  Created by HyanCat on 16/8/24.
//  Copyright © 2016年 entertech. All rights reserved.
//

import Foundation

/// 脑波文件读取器
open class BrainwaveFileReader<ValueType: BrainwaveValueType>: DataFileReader {

    /// 序列化后的数据，BrainWaveData 的数组
    open var serializedData: [BrainwaveData<ValueType>] = []

    open override func loadFile(_ fileURL: URL) throws {
        try super.loadFile(fileURL)
        self.serializedData = self.serialize(self.data as Data)
    }

    /**
     脑波数据序列化

     - parameter data: 脑波文件的数据

     - returns: BrainWaveData 数组
     */
    private func serialize(_ data: Data) -> [BrainwaveData<ValueType>] {
        var brainwaveDataArray: [BrainwaveData<ValueType>] = []
        let buffers = data.allBytes
        let byteCount = Int(ValueType.bitCount.byteCount)
        let splitedArray = buffers.splitBy(byteCount)
        for item in splitedArray {
            guard item.count == byteCount else {
                continue
            }
            let brainwaveData = BrainwaveData(value: ValueType(bytes: item))
            brainwaveDataArray.append(brainwaveData)
        }
        return brainwaveDataArray
    }
}

open class BrainwaveFileReaderV2<ValueType: BrainwaveValueType>: DataFileReader {
    open override func loadFile(_ fileURL: URL) throws {
        try super.loadFile(fileURL)

        // 暂时不需要实现
    }
}
