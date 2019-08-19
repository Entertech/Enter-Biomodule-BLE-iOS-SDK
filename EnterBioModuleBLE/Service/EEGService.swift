//
//  EEGService.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import RxSwift

public class EEGService: BLEService {
}

extension EEGService: Notifiable {

    public typealias NotifyType = Characteristic.EEG

}

extension EEGService: ServiceTypable {
    public var serviceType: ServiceType {
        return .eeg
    }
}
