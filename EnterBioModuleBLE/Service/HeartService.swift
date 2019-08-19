//
//  HeartService.swift
//  EnterBioModuleBLE
//
//  Created by Anonymous on 2019/2/19.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import Foundation

public class HeartService: BLEService {
    
}

extension HeartService: Notifiable {
    public typealias NotifyType = Characteristic.Heart.Notify
}
