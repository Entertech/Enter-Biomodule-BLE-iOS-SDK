//
//  EEGFileManager.swift
//  EnterBioModuleBLE
//
//  Created by NyanCat on 28/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import Files
//import NaptimeFileProtocol

extension Date {
    var toFileName: String {
        let fileFormatter = DateFormatter()
        fileFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return fileFormatter.string(from: self)
    }
}

extension DispatchQueue {
    static let file = DispatchQueue(label: "cn.entertech.EnterBioModuleBLE.file")
}

extension FileManager {
    var dataDirectory: URL {
        let document = FileSystem(using: .default).documentFolder!
        try! document.createSubfolderIfNeeded(withName: "data")
        return URL(fileURLWithPath: try! document.subfolder(named: "data").path)
    }

    func fileURL(fileName: String) -> URL {
        return dataDirectory.appendingPathComponent("\(fileName).raw")
    }
}

class EEGFileManager {
    static let shared = EEGFileManager()
    private init() {}

    private var fileHandler: FileHandle?
    private var fileName: String?
    func create() {
        DispatchQueue.file.async {
            let dataURL = FileManager.default.dataDirectory
            self.fileName = Date().stringWith(formateString: "yyyy-MM-dd HH:mm:ss")
            let filePath = dataURL.path + "/\(self.fileName!).txt"
            if self.fileHandler == nil {
                while !FileManager.default.fileExists(atPath: filePath) {
                    FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
                }
                self.fileHandler = try? FileHandle(forWritingTo: URL(fileURLWithPath: filePath))
            }
        }
    }

    func write(_ data: Data) {
        DispatchQueue.file.async {
            self.fileHandler?.seekToEndOfFile()
            self.fileHandler?.write(data)
            self.fileHandler?.synchronizeFile()
        }
    }

    func close() {
        DispatchQueue.file.async {
            self.fileHandler?.closeFile()
            self.reset()
        }
    }

    private func reset() {
        fileHandler = nil
        fileName = nil
    }
}


//class EEGFileManager {
//
//    static let shared = EEGFileManager()
//
//    private init() {}
//
//    private var _writer:  BrainwaveFileWriter<BrainwaveValue24>?
//
//    private (set) var fileName: String?
//
//    func create() {
//
//        DispatchQueue.file.async { [unowned self] in
//
//            let fileName = Date().toFileName
//            let fileURL = FileManager.default.fileURL(fileName: fileName)
//            self.fileName = fileName
//
//            self._writer = BrainwaveFileWriter<BrainwaveValue24>()
//            self._writer?.dataVersion = "3.0.0.0"
//            try? self._writer?.createFile(fileURL)
//        }
//    }
//
//    func save(data: Data) {
//        DispatchQueue.file.async { [unowned self] in
//            let allBytes = data.copiedBytes
//            allBytes.splitBy(3).forEach({ bytes in
//                let brainwaveData = BrainwaveData(value: BrainwaveValue24(bytes: bytes))
//                try? self._writer?.writeBrainwave(brainwaveData)
//            })
//        }
//    }
//
//    func close() {
//        DispatchQueue.file.async { [unowned self] in
//            try? self._writer?.close()
//            self._writer = nil
//            self.fileName = nil
//        }
//    }
//}

extension Array {
    func splitBy(_ subSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: subSize).map { startIndex in
            let endIndex = Swift.min(startIndex.advanced(by: subSize), self.count)
            return Array(self[startIndex ..< endIndex])
        }
    }
}
