//
//  DataFileReader.swift
//  NaptimeFileProtocol
//
//  Created by HyanCat on 16/8/24.
//  Copyright © 2016年 EnterTech. All rights reserved.
//

import Foundation

/// 数据文件读取器
open class DataFileReader: DataFileReadable {

    open var protocolVersion: String {
        return _protocolVersion
    }
    open var headerLength: Byte {
        return _headerLength
    }
    open var fileType: Byte {
        return _fileType
    }
    open var dataVersion: String {
        return _dataVersion
    }
    open var dataLength: UInt64 {
        return _dataLength
    }
    open var checksum: UInt16 {
        return _checksum
    }
    open var timestamp: Timestamp {
        return _timestamp
    }
    open var data: Data {
        return _data
    }

    private var _protocolVersion: String!
    private var _headerLength: Byte!
    private var _fileType: Byte!
    private var _dataVersion: String!
    private var _dataLength: UInt64!
    private var _checksum: UInt16!
    private var _timestamp: UInt!
    private var _data: Data!

    public init() {}

    open func loadFile(_ fileURL: URL) throws {
        if let fileData = try? Data(contentsOf: fileURL) {

            self.parseProtocolVersion(fileData)
            self.parseHeaderLength(fileData)

            let headerData = fileData.subdata(in: 0 ..< Int(_headerLength))
            _data = fileData.subdata(in: Int(_headerLength) ..< fileData.count)

            self.parseFileType(headerData)
            self.parseDataVersion(headerData)
            self.parseDataLength(headerData)
            self.parseChecksum(headerData)
            self.parseTimestamp(headerData)
        } else {
            throw DataFileError()
        }
    }

    // MARK: - 解析文件头字段

    private func parseProtocolVersion(_ data: Data) {
        do {
            var protocolVersionBytes = try data.bytesInRange(NSMakeRange(0, 2))
            _protocolVersion = String(protocolVersionBytes[0]) + "." + String(protocolVersionBytes[1])
        } catch {}
    }

    private func parseHeaderLength(_ data: Data) {
        do {
            _headerLength = try data.byteAtIndex(2)
        } catch {}
    }

    private func parseFileType(_ data: Data) {
        do {
            _fileType = try data.byteAtIndex(3)
        } catch {}
    }

    private func parseDataVersion(_ data: Data) {
        do {
            let versionBytes = try data.bytesInRange(NSMakeRange(4, 4))
            _dataVersion = versionBytes.componentsJoinedByString(".")
        } catch {}
    }

    private func parseDataLength(_ data: Data) {
        do {
            let dataLengthBytes = try data.bytesInRange(NSMakeRange(8, 6))
            var length: UInt64 = 0
            for item in dataLengthBytes {
                length = length << 8 + UInt64(item)
            }
            _dataLength = length
        } catch {}
    }

    private func parseChecksum(_ data: Data) {
        do {
            let checksumBytes = try data.bytesInRange(NSMakeRange(14, 2))
            _checksum = UInt16(checksumBytes[0]) << 8 + UInt16(checksumBytes[1])
        } catch {}
    }

    private func parseTimestamp(_ data: Data) {
        do {
            let timestampBytes = try data.bytesInRange(NSMakeRange(16, 4))
            var time: Timestamp = 0
            for item in timestampBytes {
                time = time << 8 + UInt(item)
            }
            _timestamp = time
        } catch {}
    }
}
