//
//  ReportFileWriter.swift
//  NaptimeFileProtocol
//
//  Created by Anonymous on 2018/11/7.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

public class ReportFileWriter: DataFileWriterV2 {

    public override init() {
        super.init()
        fileType = 3
    }

    public func writeReportData(_ fragement: ReportDataFragment) throws {
        try super.write(fragment: fragement)
    }

//    @available(*, unavailable, message: "使用 writeAnalyzingData(_:) 写入")
//    open func write(reportData: ReportData) throws {
//    }
}
