//
//  AnalyzedFragment.swift
//  NaptimeFileProtocol
//
//  Created by HyanCat on 26/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

/// 分析后的片数据
open class AnalyzedFragment: FragmentData {

    public internal (set) var analyzedDatas: [NeuNetProcessData] = []

    @available(*, unavailable, message: "使用 write(analyzingData:) 写入")
    open override func write(data: Data) {
        super.write(data: data)
    }

    /// 写入分析后数据
    ///
    /// - Parameter analyzingData: 分析后数据
    open func write(analyzingData: NeuNetProcessData) {
        analyzedDatas.append(analyzingData)
        // TODO: 可考虑缓存一定数据后再写入文件
        super.write(data: analyzingData.data)
    }
}
