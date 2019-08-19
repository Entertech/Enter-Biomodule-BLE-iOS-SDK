//
//  DataPool.swift
//  EnterBioModuleBLE
//
//  Created by NyanCat on 28/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static let pool = DispatchQueue(label: "cn.entertech.EnterBioModuleBLE.pool")
}

class DataPool {

    private var _data = [UInt8]()

    var isEmpty: Bool {
        return _data.count == 0
    }

    var isAvailable: Bool {
        return _data.count > 0
    }

    func push(data: Data) {
        DispatchQueue.pool.sync {
            _data.append(contentsOf: data.copiedBytes)
        }
    }

    func pop(length: Int) -> Data {
        var subdata: Data = Data()
        DispatchQueue.pool.sync {
            let count = min(length, _data.count)
            subdata = Data(bytes: _data[0..<count])
            _data.removeFirst(count)
        }
        return subdata
    }

    func dry() {
        DispatchQueue.pool.sync {
            _data.removeAll()
        }
    }

}
