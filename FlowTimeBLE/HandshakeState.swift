//
//  HandshakeState.swift
//  FlowTimeBLE
//
//  Created by HyanCat on 10/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

enum HandshakeState: RawRepresentable {

    case success
    case error(HandshakeState.Error)

    enum Error: Swift.Error {
        case invalidUserID
        case deviceBounded
        case notReceivedID
        case handshakeData
        case timestamp
    }

    var rawValue: [UInt8] {
        switch self {
        case .success:
            return [0x04, 0x00, 0x00, 0x00, 0x00]
        case .error(.invalidUserID):
            return [0x04, 0x00, 0x00, 0x00, 0x01]
        case .error(.deviceBounded):
            return [0x04, 0x00, 0x00, 0x00, 0x02]
        case .error(.notReceivedID):
            return [0x04, 0x00, 0x00, 0x00, 0x03]
        case .error(.handshakeData):
            return [0x04, 0x00, 0x00, 0x00, 0x04]
        case .error(.timestamp):
            return [0x04, 0x00, 0x00, 0x00, 0x05]
        }
    }

    init?(rawValue: [UInt8]) {
        guard rawValue.count == 5 else { return nil }
        guard rawValue[0] == 0x04 else { return nil }
        guard rawValue[1] == 0x00 else { return nil }
        guard rawValue[2] == 0x00 else { return nil }
        guard rawValue[3] == 0x00 else { return nil }
        switch rawValue[4] {
        case 0x00:
            self = .success
        case 0x01:
            self = .error(.invalidUserID)
        case 0x02:
            self = .error(.deviceBounded)
        case 0x03:
            self = .error(.notReceivedID)
        case 0x04:
            self = .error(.handshakeData)
        case 0x05:
            self = .error(.timestamp)
        default:
            return nil
        }
    }
}
