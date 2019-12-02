//
//  Errors.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 03/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

//protocol BLEError: Error {}

enum BLEError: Error {
    case scanFail
    case connectFail
    case busy
    case timeout
    case invalid(message: String)
}
