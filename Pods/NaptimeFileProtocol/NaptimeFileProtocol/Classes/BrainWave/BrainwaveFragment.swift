//
//  BrainwaveFragment.swift
//  NaptimeFileProtocol
//
//  Created by HyanCat on 26/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

/// 脑波片数据
open class BrainwaveFragment<ValueType: BrainwaveValueType>: FragmentData {

    /// 此片中的脑波数据序列
    public private (set) var brainwaves: [BrainwaveData<ValueType>] = []

    @available(*, unavailable, message: "使用 write(brainwave:) 写入")
    open override func write(data: Data) {
        super.write(data: data)
    }

    /// 写入脑波数据
    ///
    /// - Parameter brainwave: 脑波数据
    open func write(brainwave: BrainwaveData<ValueType>) {
        brainwaves.append(brainwave)
        // TODO: 可考虑缓存一定数据后再写入文件
        super.write(data: brainwave.data)
    }
}
