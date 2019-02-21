//
//  ReportFileReader.swift
//  NaptimeFileProtocol
//
//  Created by Anonymous on 2018/11/7.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation



public class ReportFileReader: DataFileReader {
    public var fragments = [ReportDataFragment]()

    public override func loadFile(_ fileURL: URL) throws {
        do {
            try super.loadFile(fileURL)
            self.fragments = self.parse(self.data)
        } catch {
            throw error
        }
    }

    fileprivate func parse(_ data: Data) -> [ReportDataFragment] {
        var fragments = [ReportDataFragment]()
        var reportBodyData = data

        while reportBodyData.count > 16 {
            let header = self.data.prefix(16)
            let fragment = ReportDataFragment(header: header.allBytes)

            if let fragmentBodyData = self.serialize(reportBodyData.subdata(in: Range(16..<reportBodyData.count))) {
                fragment.reportData = fragmentBodyData
                fragment.data = fragmentBodyData.data()
            } else {
                break
            }
            fragments.append(fragment)

            reportBodyData.removeFirst(Int(fragment.length))
        }

        return fragments
    }

    fileprivate func serialize(_ data: Data) -> ReportData? {
        let bytes = data.allBytes
        var digitalBeginIndex: Int = 0
        for index in bytes.indices {
            if (bytes[index] == 0xf1 || bytes[index] == 0xf2),
                index % ScalarTypeLength == 0 {
                digitalBeginIndex = index
                break
            }
        }
        if digitalBeginIndex == 0 { return nil} 
        // 注意这里如果使用 data.startIndex 会有问题的，这里的 startIndex 是 16
        let scalarData = data.subdata(in: Range(Data.Index(0)...digitalBeginIndex-1))
        let scalars = convertScalarWith(data: scalarData)
        let digitalData = data.subdata(in: Range(digitalBeginIndex..<data.count))
        let digitals = convertDigitalWith(data: digitalData)
        if scalars.count == 0, digitals.count == 0 { return nil }
        return ReportData(scalars: scalars, digitals: digitals)
    }

    // 解析标量数据
    fileprivate func convertScalarWith(data: Data) -> [Scalar] {
        let bytes = data.allBytes
        let scalars: [Scalar] = stride(from: bytes.startIndex, to: data.endIndex, by: ScalarTypeLength).map{ startIndex in
            let type = ScalarType(rawValue: bytes[startIndex]) ?? ScalarType.retained
            let value = UInt24((bytes[startIndex + 1],
                                bytes[startIndex + 2],
                                bytes[startIndex + 3])).int32Value()
            let scalar = Scalar(type: type, value: value)

            return scalar
        }

        return scalars
    }

    // 解析绘图数据数组
    fileprivate func convertDigitalWith(data: Data) -> [Digital] {
        var digitals = [Digital]()
        var bytes = data.allBytes
        var tempData = data
        var startIndex = 0
        while (tempData.count >  4) {
            var type = DigitalType.retained
            switch tempData.first!  {
            case 0xf1:
                type = DigitalType.napCurve
            case 0xf2:
                type = DigitalType.napState
            case 0xf3:
                type = DigitalType.sleepNosie
            case 0xf4:
                type = DigitalType.sleepDayDream
            case 0xf5:
                type = DigitalType.sleepSnore
            default:
                break
            }
            startIndex += 4
            let length = UInt24((bytes[1], bytes[2], bytes[3])).int32Value()
            let bodyDatas = data.subdata(in:Range(startIndex..<(startIndex+Int(length))))
            let digital = Digital(type: type, length: length, data: bodyDatas)
            digitals.append(digital)
            startIndex += (Int(length))
            if startIndex >= data.count { break }
            tempData = data.subdata(in: Range(startIndex..<data.count))
            bytes = tempData.allBytes
        }
        return digitals
    }
}
