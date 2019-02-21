//
//  AnalyzedFileReader.swift
//  NaptimeFileProtocol
//
//  Created by HyanCat on 16/8/24.
//  Copyright © 2016年 entertech. All rights reserved.
//

import Foundation

/// 分析后文件读取器
open class AnalyzedFileReader: DataFileReader {

    /// 序列化后的数据，AnalyzingData 的数组
    open var serializedData: [AnalyzingData] = []

    open override func loadFile(_ fileURL: URL) throws {
        try super.loadFile(fileURL)
        self.serializedData = _serialize(analyzed: self.data)
    }
}

/// V2 分析后文件读取器
open class AnalyzedFileReaderV2: DataFileReader {

    /// 解析后的所有片数据
    open var fragments: [AnalyzedFragment] = []

    open override func loadFile(_ fileURL: URL) throws {
        try super.loadFile(fileURL)

        fragments = parse(data: self.data)

    }

    /// 解析分析后数据体
    ///
    /// - Parameter data: 分析后数据体
    /// - Returns: 解析后的所有分片数据
    private func parse(data: Data) -> [AnalyzedFragment] {
        var fragments: [AnalyzedFragment] = []
        var leftData = data

        while leftData.count >= 16 {
            // 先取 header
            let header = leftData.prefix(16).allBytes
            // 去掉 header
            leftData = leftData.dropFirst(16)
            // 构造片数据
            let fragment = AnalyzedFragment(header: header)
            // 保证要有正确长度的 body
            guard leftData.count >= Int(fragment.length) else { break }
            // 取片数据的 body
            fragment.data = leftData.prefix(Int(fragment.length))
            fragment.analyzedDatas = _serializeV2(fragment.data)
            // 此片解析完成
            fragments.append(fragment)
            leftData = leftData.dropFirst(Int(fragment.length))
        }

        return fragments
    }
}

/// 分析后数据序列化 Protocol V1
///
/// - Parameter data: 分析后文件的数据
/// - Returns: AnalyzingData 序列
private func _serialize(analyzed data: Data) -> [AnalyzingData] {

    var analyzingDataArray: [AnalyzingData] = []
    let buffers = data.allBytes
    let splitedArray = buffers.splitBy(8)
    for item in splitedArray {
        guard item.count == 8 else {
            continue
        }
        let analyzingData = AnalyzingData(dataQuality: item[0],
                                          soundControl: item[1],
                                          awakeStatus: item[2],
                                          sleepStatusMove: item[3],
                                          restStatusMove: item[4],
                                          wearStatus: item[5])
        analyzingDataArray.append(analyzingData)
    }
    return analyzingDataArray
}


/// 分析后文件序列化 protocol V2
///
/// - Parameter fragmentBodyData: 分片数据中的数据体
/// - Returns: NeuNetProcessData 序列
private func _serializeV2(_ fragmentBodyData: Data) -> [NeuNetProcessData] {
    var processDataArray = [NeuNetProcessData]()
    let allBytes = fragmentBodyData.allBytes
    let analyzedData = allBytes.splitBy(8)
    for item in analyzedData {
        let processData = NeuNetProcessData(mlpDegree: item[0],
                                            napDegree: item[1],
                                            sleepState: item[2],
                                            dataQuality: item[3],
                                            soundControl: item[4])

        processDataArray.append(processData)
    }
    return processDataArray
}
