//
//  ReportDataFragment.swift
//  NaptimeFileProtocol
//
//  Created by Anonymous on 2018/11/8.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

public class ReportDataFragment: FragmentData {
    public var reportData: ReportData?

    public override func write(data: Data) {
        super.write(data: data)
    }

    public func write(reportData: ReportData) {
        self.reportData = reportData
        super.write(data: reportData.data())
    }
}
