//
//  GCDBlocks.swift
//  EnterBioModuleBLE
//
//  Created by Enter on 2019/8/14.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import Foundation

public func delay(seconds: TimeInterval, block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds, execute: block)
}
