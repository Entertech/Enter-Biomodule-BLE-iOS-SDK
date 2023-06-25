//
//  Language.swift
//  EnterBioModuleBLEUI
//
//  Created by Enter on 2021/1/29.
//  Copyright © 2021 EnterTech. All rights reserved.
//

import Foundation

/// 多语言定义
/// 采用国际统一标准
///
/// - zh_CN: 简体中文
/// - en: 英文
enum Language: String {
    case zh_CN = "zh_CN"
    case en = "en"
    case de = "de"
    case ja = "ja"
}

// MARK: - 多语言的一些设定和操作扩展
extension Language {

    /// 默认语言
    static var `default`: Language = .zh_CN

    /// 当前语言
    static var current: Language = .zh_CN {
        didSet {
            _refresh(current)
        }
    }

    /// 本地化的数据字典
    private static var _strings: [String: String] = [String: String]()

    static func initLocale() {
        self.current = self.detectLanguage()
    }

    /// 初始化的语言加载
    static func load() {
        _refresh()
    }

    /// 获取当前语言的某个定义的字符串值，找不到则返回 default 或 key
    ///
    /// - Parameter key: 定义的资源的 Key
    /// - Parameter default: 找不到的情况下的默认值
    /// - Returns: key 对应的本地化结果
    static func value(for key: String, default: String?) -> String {
        if let value = _strings[key] {
            return value
        } else {
            // 找不到则返回 default 或 key
            return `default` ?? key
        }
    }

    /// 刷新多语言资源
    ///
    /// - Parameter language: 语言类别，默认为 Language.default 类
    private static func _refresh(_ language: Language = .default) {
        guard let fileName = Bundle.main.path(forResource: language.rawValue, ofType: "strings") else {return}
        let dic = NSDictionary(contentsOfFile: fileName)
        self._strings = dic as! [String: String]
    }
}

extension Language {
    static var isChinese: Bool {
        return Language.current == .zh_CN
    }
}

/// 快捷的函数式获取本地化的资源结果
///
/// - Parameter key: 定义的资源的 Key
/// - Parameter default: 找不到的情况下的默认值
/// - Returns: key 对应的本地化结果
func lang(_ key: String, default: String? = nil) -> String {
    return Language.value(for: key, default: `default`)
}


extension Language {
    fileprivate static func isSystemChineseSimple() -> Bool {
        if let currentLanguage = Locale.preferredLanguages.first {
            return currentLanguage.hasPrefix("zh-Hans")
        }
        return false
    }

    fileprivate static func isSystemChineseTradition() -> Bool {
        if let currentLanguage = Locale.preferredLanguages.first {
            return currentLanguage.hasPrefix("zh-Hant")
        }
        return false
    }
}

extension Language {
    fileprivate static func detectLanguage() -> Language {
        if isSystemChineseSimple() {
            return Language.zh_CN
        }
        if let currentLanguage = Locale.preferredLanguages.first,
            let country = currentLanguage.split(separator: Character("-")).first,
            let lang = Language(rawValue: String(country)) {
            return lang
        }
        return .en
    }
}
