//
//  Persistence.swift
//  BLETool
//
//  Created by Anonymous on 2018/1/24.
//  Copyright © 2018年 EnterTech. All rights reserved.
//

import Foundation


class Persistence {
    static let shared = Persistence()

    private init() {}

    var dfuPacketName: String?
    var dfuPacketURL: URL?
}
