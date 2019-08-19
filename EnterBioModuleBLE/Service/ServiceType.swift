//
//  ServiceType.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 13/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

public protocol ServiceTypable {
    var serviceType: ServiceType { get }
}

public enum ServiceType: String {
    case connect    = "0000FF10-1212-ABCD-1523-785FEABCD123"
    case command    = "0000FF20-1212-ABCD-1523-785FEABCD123"
    case eeg        = "0000FF30-1212-ABCD-1523-785FEABCD123"
    case dfu        = "0000FF40-1212-ABCD-1523-785FEABCD123"
    case heart      = "0000FF50-1212-ABCD-1523-785FEABCD123"
    case deviceInfo = "180A"
    case battery    = "180F"
}
