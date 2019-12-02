//
//  Instruction.swift
//  EnterBioModuleBLE
//
//  Created by Anonymous on 2019/2/19.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import Foundation

public enum Instruction {
    public enum EEG: UInt8 {
        case start = 0x01
        case stop  = 0x02
    }

    public enum Heart: UInt8 {
        case start = 0x03
        case stop  = 0x04
    }

    public enum EEGMixHeart: UInt8 {
        case start = 0x05
        case stop  = 0x06
    }
}
