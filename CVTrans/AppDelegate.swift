//
//  AppDelegate.swift
//  CVTrans
//
//  Created by 小洋粉 on 2019/9/12.
//  Copyright © 2019 小洋粉. All rights reserved.
//  哈哈

import Cocoa
import Alamofire
import HotKey
import ClipboardManager

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ClipboardManagerDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)    // 状态栏按钮
    let popover = NSPopover()                     // 弹窗
    var eventMonitor: EventMonitor?
    let clipboardManager = ClipboardManager()     // 剪切板
    let cvApi = CVApi()    // http 网络请求
    var count = 0         // 双击cmd+c
    var oneOrTow = 1      // 双击cmd+c
    var timer: Timer!     // 双击cmd+c
    let synth = NSSpeechSynthesizer()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("CVLogo"))
            button.imagePosition = NSControl.ImagePosition.imageRight
            button.action = #selector(togglePopover(_:))
        }
        // 注册弹窗实例
        popover.contentViewController = CVPopover.freshController()

        // 全局点击事件监听 隐藏弹窗、双击翻译、划词翻译
        eventMonitor = GlobleEvent()
        eventMonitor?.start()
        // 初始化全局快捷键
        initGKey()
        // 剪切板
        clipboardManager.delegate = self as ClipboardManagerDelegate
        writeToPasteboard()   // 解决开机时剪切板为空的bug
        
        // 初始化 单击或双击ctrl+c翻译功能、
        // 初始化 鼠标双击翻译功能 、
        // 初始化 鼠标划词翻译功能、
        // 初始化 翻译同时朗读 功能
        initUserConfig()
        
        // 全局未捕获异常
        NSSetUncaughtExceptionHandler { exception in
            print(exception)
            print(exception.callStackSymbols)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    public var hotKeyPopUp: HotKey? {
        didSet {
            guard let hotKeyPopUp = hotKeyPopUp else {
                return
            }
            hotKeyPopUp.keyDownHandler = {
                self.togglePopoverr()
            }
        }
    }
    
    public var hotKeyScreenShot: HotKey? {
        didSet {
            guard let hotKeyScreenShot = hotKeyScreenShot else {
                return
            }
            hotKeyScreenShot.keyDownHandler = {
                let imgPath: String = Screenshot.captureRegion("\(NSTemporaryDirectory())captureRegion.png").path
                if (FileManager.default.fileExists(atPath: imgPath)) {
                    
                    let fileUrl = URL(fileURLWithPath: imgPath)
                    let fileData = try! Data(contentsOf: fileUrl)
                    let base64 = fileData.base64EncodedString(options: .endLineWithLineFeed)
                    
                    let parameters: Parameters = [
                        "image": base64,
                        "from": Config.fromTo[Config.from]!,
                        "to": Config.fromTo[Config.to]!]
                    self.cvApi.requestImage(parameters:parameters, popover: self.popover, statusItem: self.statusItem)
                }
            }
        }
    }
    
    
    public var hotKeyOneKeyB: HotKey? {
        didSet {
            guard let hotKeyOneKeyB = hotKeyOneKeyB  else {
                return
            }
            hotKeyOneKeyB.keyDownHandler = {
                let str: String = self.commandCStr()!
                let appStoreURL =  "https://www.baidu.com/s?ie=UTF-8&wd=\(str)"
                let url = URL(string: appStoreURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://www.baidu.com")!
                NSWorkspace.shared.open(url)
            }
        }
    }
    public var hotKeyOneKeyG: HotKey? {
        didSet {     // 属性观察者，新值被存储后调用
            guard let hotKeyOneKeyG = hotKeyOneKeyG  else {
                return
            }
            hotKeyOneKeyG.keyDownHandler = {
                let str: String = self.commandCStr()!
                let appStoreURL =  "https://www.google.com/search?q=\(str)"
                let url = URL(string: appStoreURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://www.goolge.com")!
                NSWorkspace.shared.open(url)
            }
        }
    }
}

// 全局事件监听
extension AppDelegate {
    func GlobleEvent() -> EventMonitor {
       return EventMonitor(mask: [.leftMouseDown, .rightMouseDown, .leftMouseUp]){ [weak self] event in
            // 隐藏弹窗
            if let strongSelf = self, strongSelf.popover.isShown {
                if Config.isfly == false {  // 判断是否置顶
                    strongSelf.closePopover(sender: event)
                }
            }
        // 鼠标三击切换鼠标翻译模式
        if let strongSelf = self, event?.clickCount == 2, event?.pressure == 1, event?.type == NSEvent.EventType.rightMouseDown {
            if Config.isTranslationMode {
                Config.isTranslationMode = false
                if !strongSelf.popover.isShown {
                    strongSelf.statusItem.button?.title = "已关闭鼠标双击/划词翻译"
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "isMouseTranslationMode"),
                                                object: nil,
                                                userInfo: ["isMouseTranslationMode": false])
            } else {
                Config.isTranslationMode = true
                if !strongSelf.popover.isShown {
                    strongSelf.statusItem.button?.title = "已开启鼠标双击/划词翻译"
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "isMouseTranslationMode"),
                                                              object: nil,
                                                              userInfo: ["isMouseTranslationMode": true])
            }
        }

            if Config.isTranslationMode {
                // 双击翻译
                if let strongSelf = self, (event?.clickCount != 1),(event?.clickCount == 2),(event?.pressure == 0) {
                    if Config.doubleClick == true {
                        let str = strongSelf.commandCStr()
                        if Config.doubleClickSpeak == true {
                            strongSelf.speak(str: str ?? "")
                        }
                    }
                }
                // 划词翻译
                if let strongSelf = self, (event!.type == NSEvent.EventType.leftMouseUp), (event?.clickCount != 1), (event?.clickCount != 2){
                    if Config.slitherTranslation == true {
                        let str = strongSelf.commandCStr()
                        if Config.slitherTranslationSpeak == true {
                            strongSelf.speak(str: str ?? "")
                        }
                    }
                }
            }
        }
    }
}


// 剪切板翻译
extension AppDelegate {
    // 模拟command+c 并获取剪切板内容
    func commandCStr() -> String? {
        // 模拟command+c按键
        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        let spcd = CGEvent(keyboardEventSource: src, virtualKey: 0x08, keyDown: true)
        spcd?.flags = CGEventFlags.maskCommand
        spcd?.post(tap: CGEventTapLocation.cghidEventTap)
        
        // 0.3秒后获取剪切板内容
        Thread.sleep(forTimeInterval: 0.3)
        let str = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string) ?? ""
        return str
    }
    // 剪切板事件
    func clipboardDidChange(item: ClipboardItem) {

        if let item = item.content.pasteboardItem,
            item.types.contains(.string) {
            count += 1
            // 双击cmd+c 翻译 、鼠标双击翻译、 划词翻译
            if count == Config.times || Config.doubleClick || Config.slitherTranslation {
                let data = item.data(forType: .string)
                let str = String(data: data!, encoding: .utf8)!.titlecased()
                if !popover.isShown {
                    self.statusItem.button?.title = str
                }
               
                // 判断字符串是否为中文，如果是则将翻译目标设置为英文
                let checker = NSSpellChecker.shared
                checker.automaticallyIdentifiesLanguages = true
                checker.requestChecking(of: str, range: NSRange(location: 0,length: str.count), types: NSTextCheckingResult.CheckingType.orthography.rawValue, options: nil, inSpellDocumentWithTag: 0){num,results,orthography,count in
                    self.transe(str: str,language: orthography.dominantLanguage)
                }
                self.count = 0
            } else {
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updataSecond), userInfo: nil, repeats: false)
            }
        }
    }
    
    //  翻译参数配置
    func transe(str: String, language: String) {
        var parameters: Parameters
        if language == "zh-Hans" && Config.to == "中文" {
            parameters = [
                "word": str,
                "from": Config.fromTo[Config.from]!,
                "to": Config.fromTo["英语"]!]
        } else {
            parameters = [
                "word": str,
                "from": Config.fromTo[Config.from]!,
                "to": Config.fromTo[Config.to]!]
        }
        self.cvApi.request(parameters:parameters,
                           popover: self.popover,
                           statusItem: self.statusItem)
        if Config.isSpeak {
            self.speak(str: str)
        }
    }
    
    // 朗读英文
    func speak(str:String) {
        synth.stopSpeaking()
        synth.startSpeaking(str)
    }
    
    // 计时器销毁 双击ctrl+c翻译功能工具
    @objc func updataSecond() {
        count = 0
        if timer != nil {
            timer!.invalidate() //销毁timer
            timer = nil
        }
    }
    
    // 解决开机首次启动剪切板为空的bug
    func writeToPasteboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(" ", forType: NSPasteboard.PasteboardType.string)
    }
}

// 全局快捷键
extension AppDelegate {
    // 初始化全局快捷键
    func initGKey() {
        if Storage.fileExists("globalKeybindP.json", in: .documents) {
            let globalKeybinds = Storage.retrieve("globalKeybindP.json", from: .documents, as: GlobalKeybindPreferences.self)
            hotKeyPopUp = HotKey(keyCombo: KeyCombo(carbonKeyCode: globalKeybinds.keyCode, carbonModifiers: globalKeybinds.carbonFlags))
        } else {
            hotKeyPopUp = HotKey(keyCombo: KeyCombo(carbonKeyCode: 49, carbonModifiers: 2048))
        }
        if Storage.fileExists("globalKeybindS.json", in: .documents) {
            let globalKeybinds = Storage.retrieve("globalKeybindS.json", from: .documents, as: GlobalKeybindPreferences.self)
            hotKeyScreenShot = HotKey(keyCombo: KeyCombo(carbonKeyCode: globalKeybinds.keyCode, carbonModifiers: globalKeybinds.carbonFlags))
        } else {
            hotKeyScreenShot = HotKey(keyCombo: KeyCombo(carbonKeyCode: 4, carbonModifiers: 256))
        }
        if Storage.fileExists("globalKeybindB.json", in: .documents) {
            let globalKeybinds = Storage.retrieve("globalKeybindB.json", from: .documents, as: GlobalKeybindPreferences.self)
            hotKeyOneKeyB = HotKey(keyCombo: KeyCombo(carbonKeyCode: globalKeybinds.keyCode, carbonModifiers: globalKeybinds.carbonFlags))
        } else {
            hotKeyOneKeyB = HotKey(keyCombo: KeyCombo(carbonKeyCode: 11, carbonModifiers: 256))
        }
        if Storage.fileExists("globalKeybindG.json", in: .documents) {
            let globalKeybinds = Storage.retrieve("globalKeybindG.json", from: .documents, as: GlobalKeybindPreferences.self)
            hotKeyOneKeyG = HotKey(keyCombo: KeyCombo(carbonKeyCode: globalKeybinds.keyCode, carbonModifiers: globalKeybinds.carbonFlags))
        } else {
            hotKeyOneKeyG = HotKey(keyCombo: KeyCombo(carbonKeyCode: 5, carbonModifiers: 256))
        }
    }
}

extension AppDelegate {
    
    func initUserConfig() {
        // 初始化 鼠标双击翻译功能
        if Storage.fileExists("doubleClick.json", in: .documents) {
            let userInfo = Storage.retrieve("doubleClick.json", from: .documents, as: [String:Bool].self)
            if userInfo["doubleClick"] == true {
                Config.doubleClick = true
            } else {
                Config.doubleClick = false
            }
        }
        // 初始化 鼠标双击翻译时朗读
        if Storage.fileExists("doubleClickSpeak.json", in: .documents) {
            let userInfo = Storage.retrieve("doubleClickSpeak.json", from: .documents, as: [String:Bool].self)
            if userInfo["doubleClickSpeak"] == true {
                Config.doubleClickSpeak = true
            } else {
                Config.doubleClickSpeak = false
            }
        }
        // 初始化 鼠标划词翻译
        if Storage.fileExists("slitherTranslation.json", in: .documents) {
            let userInfo = Storage.retrieve("slitherTranslation.json", from: .documents, as: [String:Bool].self)
            if userInfo["slitherTranslation"]! == true {
                Config.slitherTranslation = true
            } else {
                Config.slitherTranslation = false
            }
        }
        // 初始化 鼠标划词翻译时朗读
        if Storage.fileExists("slitherTranslationSpeak.json", in: .documents) {
            let userInfo = Storage.retrieve("slitherTranslationSpeak.json", from: .documents, as: [String:Bool].self)
            if userInfo["slitherTranslationSpeak"]! == true {
                Config.slitherTranslationSpeak = true
            } else {
                Config.slitherTranslationSpeak = false
            }
        }
        // 初始化单击或双击ctrl+c翻译功能
        if Storage.fileExists("oneOrTow.json", in: .documents) {
            let userInfo = Storage.retrieve("oneOrTow.json", from: .documents, as: [String:String].self)
            if userInfo["oneOrTow"] == "on" {
                Config.times = 2
            } else {
                Config.times = 1
            }
        }
        // 初始化 翻译同时朗读 功能
        if Storage.fileExists("readingAloud.json", in: .documents) {
            let userInfo = Storage.retrieve("readingAloud.json", from: .documents, as: [String:Bool].self)
            if userInfo["readingAloud"]! {
                Config.isSpeak = true
            } else {
                Config.isSpeak = false
            }
        }
    }
}

// 弹窗方法
extension AppDelegate {
    // 切换弹窗
    func togglePopoverr() {
        if popover.isShown {
            closePopover(sender: nil)
        } else {
            statusItem.button?.title = ""
            showPopover(sender: nil)
        }
    }
    // 切换弹窗
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            statusItem.button?.title = ""
            showPopover(sender: sender)
        }
    }
    // 打开弹窗
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
//        eventMonitor?.start()
    }
    // 关闭弹窗
    func closePopover(sender: Any?) {
        let data:[String: String] = ["data": "setTranView"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setTranView"), object: nil, userInfo: data)
        popover.performClose(sender)
//        eventMonitor?.stop()
    }
}

