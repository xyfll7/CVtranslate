//
//  Status.swift
//  CVTrans
//
//  Created by 小洋粉 on 2019/9/12.
//  Copyright © 2019 小洋粉. All rights reserved.
//

public class Config {
    // 全局共享状态
    private static var _fromTo = [
        "自动检测":"auto",
        "中文":"zh",
        "英语":"en",
        "粤语":"yue",
        "文言文":"wyw",
        "日语":"jp",
        "韩语":"kor",
        "法语":"fra",
        "西班牙语":"spa",
        "泰语":"th",
        "阿拉伯语":"ara",
        "俄语":"ru",
        "葡萄牙语":"pt",
        "德语":"de",
        "意大利语":"it",
        "希腊语":"el",
        "荷兰语":"nl",
        "波兰语":"pl",
        "保加利亚语":"bul",
        "爱沙尼亚语":"est",
        "丹麦语":"dan",
        "芬兰语":"fin",
        "捷克语":"cs",
        "罗马尼亚语 ":"rom",
        "斯洛文尼亚语":"slo",
        "瑞典语":"swe",
        "匈牙利语":"hu",
        "繁体中文":"cht",
        "越南语":"vie"
    ]
    private static var _from = "自动检测"
    private static var _to = "中文"
    private static var _isSpeak = false    // 朗读
    private static var _strstore = ""
    private static var _isFly: Bool = false     // 弹窗自动隐藏
    private static var _times: Int = 1        // 双击cmd+c翻译
    private static var _startWithLogin = true   // 开机启动
    private static var _doubleClick = false               // 双击翻译
    private static var _doubleClickSpeak = false          // 双击翻译时朗读
    private static var _slitherTranslation = false        // 划词翻译
    private static var _slitherTranslationSpeak = false   // 划词翻译时朗读
    private static var _isTranslationMode = true          // 鼠标三击切换翻译模式
    private static var _version: String = "1.1"  // 软件版本号
    private static var _githubClientID = "9303a0abde2ad0b090f5"
}
extension Config {
    // githubClientID
    public static var githubClientID: String {
        get {
            return _githubClientID
        }
    }
    // 鼠标三击切换翻译模式
    public static var isTranslationMode: Bool {
        get {
            return _isTranslationMode
        }
        set {
            _isTranslationMode = newValue
        }
    }
    // 双击翻译
    public static var doubleClick: Bool {
        get {
            return _doubleClick
        }
        set {
            _doubleClick = newValue
        }
    }
    // 双击翻译时朗读
    public static var doubleClickSpeak: Bool {
        get {
            return _doubleClickSpeak
        }
        set {
            _doubleClickSpeak = newValue
        }
    }
    // 划词翻译
    public static var slitherTranslation: Bool {
        get {
            return _slitherTranslation
        }
        set {
            _slitherTranslation = newValue
        }
    }
    // 划词翻译时朗读
    public static var slitherTranslationSpeak: Bool {
        get {
            return _slitherTranslationSpeak
        }
        set {
            _slitherTranslationSpeak = newValue
        }
    }
    // startWithLogin
    public static var startWithLogin: Bool {
        get {
            return _startWithLogin
        }
        set {
            _startWithLogin = newValue
        }
    }
    // version
    public static var version: String {
        get {
            return _version
        }
    }
    // fromTo
    public static var fromTo: [String:String] {
        get {
            return _fromTo
        }
    }
    public static var from: String {
        get {
            return _from
        }
        set {
            _from = newValue
        }
    }
    public static var to: String {
        get {
            return _to
        }
        set {
            _to = newValue
        }
    }
    // isSpeack
    public static var isSpeak: Bool {
        get {
            return _isSpeak
        }
        set {
            _isSpeak = newValue
        }
    }
    // strstore
    public static var strStore: String {
        get {
            return _strstore
        }
        set {
            _strstore = newValue
        }
    }

    // fly
    public static var isfly: Bool {
        get {
            return _isFly
        }
        set {
            _isFly = newValue
        }
    }
    
    // times
    public static var times: Int {
        get {
            return _times
        }
        set {
            _times = newValue
        }
    }
}

