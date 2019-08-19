//
//  GCD.swift
//  EnterBioModuleBLE
//
//  Created by NyanCat on 25/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

typealias DispatchBlock = () -> Void

func dispatch_to_main(_ block: @escaping DispatchBlock) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async {
            block()
        }
    }
}
