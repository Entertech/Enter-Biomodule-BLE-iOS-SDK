//
//  AnalyzingData.swift
//  Pods
//
//  Created by HyanCat on 16/8/25.
//
//

import Foundation

/**
 * 非神经网络版本分析中数据结构
 */
public struct AnalyzingData: CustomStringConvertible {
    /// 数据质量
    public let dataQuality: Byte
    /// 音量控制
    public let soundControl: Byte
    /// 唤醒信号
    public let awakeStatus: Byte
    /// 睡眠状态
    public let sleepStatusMove: Byte
    /// 实时放松度
    public let restStatusMove: Byte
    /// 佩戴状态
    public let wearStatus: Byte

    public init(dataQuality: Byte, soundControl: Byte, awakeStatus: Byte, sleepStatusMove: Byte, restStatusMove: Byte, wearStatus: Byte) {
        self.dataQuality = dataQuality
        self.soundControl = soundControl
        self.awakeStatus = awakeStatus
        self.sleepStatusMove = sleepStatusMove
        self.restStatusMove = restStatusMove
        self.wearStatus = wearStatus
    }

    public var description: String {
        return "[\(dataQuality), \(soundControl), \(awakeStatus), \(sleepStatusMove), \(restStatusMove), \(wearStatus)]"
    }
}

extension AnalyzingData {
    public var data: Data {
        let bytes: Bytes = [dataQuality,
                            soundControl,
                            awakeStatus,
                            sleepStatusMove,
                            restStatusMove,
                            wearStatus,
                            0,
                            0]
        return Data(bytes: bytes)
    }
}


/// 神经网络版本分析中的数据
public struct NeuNetProcessData: CustomStringConvertible {
    /// 神经网络数值
    public let mlpDegree: UInt8
    /// 放松度
    public let napDegree: UInt8
    /// 实时睡眠状态
    public let sleepState: UInt8
    /// 实时数据质量
    public let dataQuality: UInt8
    /// 声音控制信号
    public let soundControl: UInt8

    public init (mlpDegree: UInt8,
                 napDegree: UInt8,
                 sleepState: UInt8,
                 dataQuality: UInt8,
                 soundControl: UInt8) {
        self.mlpDegree = mlpDegree
        self.napDegree = napDegree
        self.sleepState = sleepState
        self.dataQuality = dataQuality
        self.soundControl = soundControl
    }

    public var description: String {
        return """
        mlpDegree: \(self.mlpDegree)
        napDegree: \(self.napDegree)
        sleepState: \(self.sleepState)
        dataQuality: \(self.dataQuality)
        soundControl: \(self.soundControl)
        """
    }
}

extension NeuNetProcessData {
    public var data: Data {
        let data = [self.mlpDegree,
                    self.napDegree,
                    self.sleepState,
                    self.dataQuality,
                    self.soundControl,
                    0,
                    0,
                    0]

        return Data(bytes: data)
    }

}
