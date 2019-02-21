//
//  DataFileWriter.swift
//  NaptimeFileProtocol
//
//  Created by HyanCat on 16/8/24.
//  Copyright © 2016年 EnterTech. All rights reserved.
//

import Foundation

open class DataFileWriter: DataFileWritable {

    public internal (set) var protocolVersion: String = "1.0"
    public let headerLength: Byte = 32
    open var fileType: Byte = 0
    open var dataVersion: String = "1.0.0.0"
    open private (set) var dataLength: UInt64 = 0
    open private (set) var checksum: UInt16 = 0
    open private (set) var timestamp: Timestamp = unix_time()
    open private (set) var data: Data = Data()

    private var fileURL: URL?
    private var tempURL: URL?
    private var fileHandler: FileHandle?

    /// 标记文件是否打开，Filehandle 没有提供检查文件是否打开或关闭的方法
    private var isOpen: Bool = false

    public init() {}

    open func createFile(_ fileURL: URL) throws {
        self.fileURL = fileURL
        let tempPath = fileURL.path //NSTemporaryDirectory() + fileURL.lastPathComponent
        self.tempURL = fileURL   //URL(fileURLWithPath: tempPath)
        #if swift(>=4.0)
            FileManager.default.createFile(atPath: tempPath, contents: nil, attributes: [.protectionKey: FileProtectionType.none])
        #else
            FileManager.default.createFile(atPath: tempPath, contents: nil, attributes: [FileAttributeKey.protectionKey.rawValue: FileProtectionType.none])
        #endif
        try self.fileHandler = FileHandle(forWritingTo: self.tempURL!)
        self.isOpen = true

        // 写入 header，占位
        let header = self.mergeHeader()
        self.fileHandler?.write(header)
    }

    open func writeData(_ data: Data) throws {
        // 保证文件是打开状态，否则不写入数据，避免多线程情况下关闭文件后写入数据抛出异常
        guard self.isOpen else {
            return
        }

        self.fileHandler?.write(data)
        self.fileHandler?.synchronizeFile()

        dataLength = dataLength + UInt64(data.count)
        for item in data.allBytes {
            checksum = UInt16((UInt32(checksum) + UInt32(item)) % (256*256))
        }
        // TODO: 是否需要记录完整的 data，占用内存
//        self.data.append(data)
    }

    open func close() throws {
        // 更新 header
        let header = self.mergeHeader()
        self.fileHandler?.seek(toFileOffset: 0)
        self.fileHandler?.write(header)
        self.fileHandler?.closeFile()
        self.isOpen = false
        // 移动到最终位置
        //try FileManager.default.copyItem(at: self.tempURL!, to: self.fileURL!)
    }

    private func mergeHeader() -> Data {
        var header = [Byte]()
        header.append(contentsOf: self.convertProtocolVersion())
        header.append(Byte(headerLength))
        header.append(Byte(fileType))
        header.append(contentsOf: self.convertDataVersion())
        header.append(contentsOf: self.convertDataLength())
        header.append(contentsOf: self.convertChecksum())
        header.append(contentsOf: self.convertTimestamp())
        header.append(contentsOf: Bytes(repeating: 0, count: 12)) // 保留位
        return Data(bytes: header)
    }

    // MARK: - 转换文件头属性

    private func convertProtocolVersion() -> Bytes {
        return protocolVersion.components(separatedBy: ".").map { (item) -> Byte in
            return Byte(item) ?? 0
        }
    }

    private func convertDataVersion() -> Bytes {
        return dataVersion.components(separatedBy: ".").map({ (item) -> Byte in
            return Byte(item) ?? 0
        })
    }

    private func convertDataLength() -> Bytes {
        var dataLengthBytes = Bytes()
        var length = dataLength
        repeat {
            dataLengthBytes.insert(UInt8(length%256), at: 0)
            length = length / 256
        } while dataLengthBytes.count < 6

        return dataLengthBytes
    }

    private func convertChecksum() -> Bytes {
        return [Byte(checksum/256), Byte(checksum%256)]
    }

    private func convertTimestamp() -> Bytes {
        var timestampBytes = Bytes()
        var time = timestamp
        repeat {
            timestampBytes.insert(UInt8(time%256), at: 0)
            time = time / 256
        } while timestampBytes.count < 4

        return timestampBytes
    }
}
