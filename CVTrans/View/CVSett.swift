//
//  CVSett.swift
//  CVTrans
//
//  Created by 小洋粉 on 2019/9/13.
//  Copyright © 2019 小洋粉. All rights reserved.
//

import Cocoa
import HotKey
import AVFoundation

class CVSett: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setGKey()
        setGKeyName()
        version.stringValue = "当前版本：" + Config.version
        CVApi.update()   // 检查更新
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(listnerUpdate(_:)),
            name: NSNotification.Name(rawValue: "Update"),
            object: nil)
        // 鼠标三击右键禁用鼠标双击/划词翻译功能
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(switchMouseTranslationMode(_:)),
            name: NSNotification.Name(rawValue: "isMouseTranslationMode"),
            object: nil)
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(listnerUserName(_:)),
//            name: NSNotification.Name(rawValue: "userName"),
//            object: nil)
      
        // 启动登陆web服务，等待接收消息
//        webServer.login()
        // 初始化用户登陆信息
//        loginUserName.title = WebServer.initLoginInfo()
//        if loginUserName.title != "登陆" {
//            loginUserName.image = NSImage(named:NSImage.Name("github"))
//        }
        // 初始化 鼠标双击翻译
        if Storage.fileExists("doubleClick.json", in: .documents) {
            let userInfo = Storage.retrieve("doubleClick.json", from: .documents, as: [String:Bool].self)
            if userInfo["doubleClick"]! == true {
                doubleClick.state = .on
                Config.doubleClick = true
            } else {
                doubleClick.state = .off
                Config.doubleClick = false
            }
        }
        // 初始化 鼠标双击翻译时朗读
        if Storage.fileExists("doubleClickSpeak.json", in: .documents) {
            let userInfo = Storage.retrieve("doubleClickSpeak.json", from: .documents, as: [String:Bool].self)
            if userInfo["doubleClickSpeak"]! == true {
                doubleClickSpeak.state = .on
                Config.doubleClickSpeak = true
            } else {
                doubleClickSpeak.state = .off
                Config.doubleClickSpeak = false
            }
        }
        // 初始化 鼠标划词翻译
        if Storage.fileExists("slitherTranslation.json", in: .documents) {
            let userInfo = Storage.retrieve("slitherTranslation.json", from: .documents, as: [String:Bool].self)
            if userInfo["slitherTranslation"]! == true {
                slitherTranslation.state = .on
                Config.slitherTranslation = true
            } else {
                slitherTranslation.state = .off
                Config.slitherTranslation = false
            }
        }
        // 初始化 鼠标划词翻译时朗读
        if Storage.fileExists("slitherTranslationSpeak.json", in: .documents) {
            let userInfo = Storage.retrieve("slitherTranslationSpeak.json", from: .documents, as: [String:Bool].self)
            if userInfo["slitherTranslationSpeak"]! == true {
                slitherTranslationSpeak.state = .on
                Config.slitherTranslationSpeak = true
            } else {
                slitherTranslationSpeak.state = .off
                Config.slitherTranslationSpeak = false
            }
        }
        // 初始化 单击或双击ctrl+c翻译 功能
        if Storage.fileExists("oneOrTow.json", in: .documents) {
            let userInfo = Storage.retrieve("oneOrTow.json", from: .documents, as: [String:String].self)
            if userInfo["oneOrTow"] == "on" {
                oneOrTow.state = .on
                Config.times = 2
            } else {
                oneOrTow.state = .off
                Config.times = 1
            }
        }
        // 初始化 翻译同时朗读 功能
        if Storage.fileExists("readingAloud.json", in: .documents) {
            let userInfo = Storage.retrieve("readingAloud.json", from: .documents, as: [String:Bool].self)
            if userInfo["readingAloud"]! == true {
                readingAloud.state = .on
                Config.isSpeak = true
            } else {
                readingAloud.state = .off
                Config.isSpeak = false
            }
        }
        // 初始化 开机启动 功能
        if Storage.fileExists("startUpWithLogin.json", in: .documents) {
            let userInfo = Storage.retrieve("startUpWithLogin.json", from: .documents, as: [String:Bool].self)
            if userInfo["startUpWithLogin"]! == true {
                startUpWithLogin.state = .on
            } else {
                startUpWithLogin.state = .off
            }
        }
    }
    override func viewWillDisappear() {
        listenPopUp = false
        listenScreenShot = false
        listenOneKeyB = false
        listenOneKeyG = false
        setGKeyName()
    }
//    let webServer = WebServer()
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var popUp: NSButton!       // ⌥空格键 (弹出窗口)
    @IBOutlet weak var screenShot: NSButton!  // ⌘⌥T (截屏翻译)
    @IBOutlet weak var oneKeyB: NSButton!     // ⌘B (一键百度)
    @IBOutlet weak var oneKeyG: NSButton!     // ⌘G (一键谷歌)
    

//    @IBOutlet weak var loginUserName: NSButton!            // 登陆按钮

    @IBOutlet weak var version: NSTextField!               // 版本信息

    @IBOutlet weak var startUpWithLogin: NSButton!         // 开机启动

    @IBOutlet weak var doubleClick: NSButton!              // 鼠标双击翻译
    @IBOutlet weak var doubleClickSpeak: NSButton!         // 鼠标双击翻译是朗读
    @IBOutlet weak var slitherTranslation: NSButton!       // 鼠标划词翻译
    @IBOutlet weak var slitherTranslationSpeak: NSButton!  // 鼠标划词翻译时朗读
    @IBOutlet weak var oneOrTow: NSButton!                 // 双击ctrl+c翻译
    @IBOutlet weak var readingAloud: NSButton!             // 朗读 readingAloud

    // 禁用双击划词翻译 DisableDoubleClickSlitherTranslation
    @IBOutlet weak var disableDoubleClickSlitherTranslation: NSButton!

    var updateURL: String = ""
    
    var listenPopUp = false {
        didSet {
            if listenPopUp {
                DispatchQueue.main.async { [weak self] in
                    self?.popUp.highlight(true)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.popUp.highlight(false)
                }
            }
        }
    }
    var listenScreenShot = false {
        didSet {
            if listenScreenShot {
                DispatchQueue.main.async { [weak self] in
                    self?.screenShot.highlight(true)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.screenShot.highlight(false)
                }
            }
        }
    }
    
    var listenOneKeyB = false {
        didSet {
            if listenOneKeyB {
                DispatchQueue.main.async { [weak self] in
                    self?.oneKeyB.highlight(true)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.oneKeyB.highlight(false)
                }
            }
        }
    }
    
    var listenOneKeyG = false {
        didSet {
            if listenOneKeyG {
                DispatchQueue.main.async { [weak self] in
                    self?.oneKeyG.highlight(true)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.oneKeyG.highlight(false)
                }
            }
        }
    }
}
// MARK: NotificationCenter
extension CVSett {
    @objc func listnerUpdate(_ notification: NSNotification) {
        if let updateURL = notification.userInfo?["updateURL"] as? String {
            self.version.isHidden = true
            self.updateURL = updateURL
        }
    }
    // 切换鼠标翻译模式
    @objc func switchMouseTranslationMode(_ notification: NSNotification) {
        if notification.userInfo?["isMouseTranslationMode"] as? Bool ?? false {
            _switchMouseTranslationMode(state: true)
        } else {
            _switchMouseTranslationMode(state: false)
        }
    }
//    @objc func listnerUserName(_ notification: NSNotification) {
//        if let userName = notification.userInfo?["userName"] as? String {
//            self.loginUserName.title = userName
//        }
//    }
}

// MARK: Actions
extension CVSett{
//    // 登陆
//    @IBAction func loginUserName(_ sender: Any) {
//        let appStoreURL =  "https://github.com/login/oauth/authorize?client_id=" + Config.githubClientID + "&scope=user:email"
//        let url = URL(string: appStoreURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! )!
//        NSWorkspace.shared.open(url)
//    }
    // 禁用双击划词翻译 DisableDoubleClickSlitherTranslation
    @IBAction func disableDoubleClickSlitherTranslationAction(_ sender: NSButton) {
        if sender.state == .on {
            _switchMouseTranslationMode(state: true)
        } else {
            _switchMouseTranslationMode(state: false)
        }
    }
    // 鼠标三击右键禁用鼠标双击/划词翻译功能 (外部鼠标三击要调用、内部按钮要调用）
    func _switchMouseTranslationMode(state:Bool) {
        if state == true {
            Config.isTranslationMode = true
            doubleClick.isEnabled = true
            doubleClickSpeak.isEnabled = true
            slitherTranslation.isEnabled = true
            slitherTranslationSpeak.isEnabled = true
            disableDoubleClickSlitherTranslation.title = "禁用鼠标[双击 划词]翻译"
            disableDoubleClickSlitherTranslation.state = .on
        } else {
            Config.isTranslationMode = false
            doubleClick.isEnabled = false
            doubleClickSpeak.isEnabled = false
            slitherTranslation.isEnabled = false
            slitherTranslationSpeak.isEnabled = false
            disableDoubleClickSlitherTranslation.title = "开启鼠标[双击 划词]翻译"
            disableDoubleClickSlitherTranslation.state = .off
        }
    }
    
    // 鼠标双击翻译时朗读
    @IBAction func doubleClickSpeakAction(_ sender: NSButton) {
        if sender.state == .on {
            Config.doubleClickSpeak = true
            Storage.store(["doubleClickSpeak":true], to: .documents, as: "doubleClickSpeak.json")
        } else {
            Config.doubleClickSpeak = false
            Storage.store(["doubleClickSpeak":false], to: .documents, as: "doubleClickSpeak.json")
        }
    }

    // 鼠标双击翻译
    @IBAction func doubleClickAction(_ sender: NSButton) {
        if sender.state == .on {
            Config.doubleClick = true
            Storage.store(["doubleClick":true], to: .documents, as: "doubleClick.json")
        } else {
            Config.doubleClick = false
            Storage.store(["doubleClick":false], to: .documents, as: "doubleClick.json")
        }
    }
    
    // 鼠标划词翻译时朗读
    @IBAction func slitherTranslationSpeakAction(_ sender: NSButton) {
        if sender.state == .on {
            Config.slitherTranslationSpeak = true
            Storage.store(["slitherTranslationSpeak":true], to: .documents, as: "slitherTranslationSpeak.json")
        } else {
            Config.slitherTranslationSpeak = false
            Storage.store(["slitherTranslationSpeak":false], to: .documents, as: "slitherTranslationSpeak.json")
        }
    }
    // 划词翻译
    @IBAction func slitherTranslationAction(_ sender: NSButton) {
        if sender.state == .on {
            Config.slitherTranslation = true
            Storage.store(["slitherTranslation":true], to: .documents, as: "slitherTranslation.json")
        } else {
            Config.slitherTranslation = false
            Storage.store(["slitherTranslation":false], to: .documents, as: "slitherTranslation.json")
        }
    }
    // 双击ctrl+c翻译
    @IBAction func oneOrTow(_ sender: NSButton) {
        if sender.state == .on {
            Config.times = 2
            Storage.store(["oneOrTow":"on"], to: .documents, as: "oneOrTow.json")
        } else {
            Config.times = 1
            Storage.store(["oneOrTow":"off"], to: .documents, as: "oneOrTow.json")
        }
    }
    // 翻译同时朗读
    @IBAction func isSpeack(_ sender: NSButton) {
        if sender.state == .on {
            Config.isSpeak = true
            Storage.store(["readingAloud":true], to: .documents, as: "readingAloud.json")
        } else {
            Config.isSpeak = false
            Storage.store(["readingAloud":false], to: .documents, as: "readingAloud.json")
        }
    }
    // 开机启动
    @IBAction func startWithLogin(_ sender: NSButton) {
        if sender.state == .on {
            Config.startWithLogin = true
            CVLaunch.startupAppWhenLogin(startup: true)
            Storage.store(["startUpWithLogin":true], to: .documents, as: "startUpWithLogin.json")
        } else {
            Config.startWithLogin = false
            CVLaunch.startupAppWhenLogin(startup: false)
            Storage.store(["startUpWithLogin":false], to: .documents, as: "startUpWithLogin.json")
        }
    }

    // 退出
    @IBAction func quit(_ sender: Any) {
        NSApplication.shared.terminate(sender)
    }
}

extension CVSett {
    // When the set shortcut button is pressed start listening for the new shortcut
    @IBAction func registPopUp(_ sender: Any) {
        listenPopUp = true
        listenScreenShot = false
        listenOneKeyB = false
        listenOneKeyG = false
        setGKeyName()
        popUp.title = "键入新快捷键(弹出窗口)"
        view.window?.makeFirstResponder(nil)
    }
    @IBAction func registScreenShot(_ sender: Any) {
        listenScreenShot = true
        listenPopUp = false
        listenOneKeyB = false
        listenOneKeyG = false
        setGKeyName()
        screenShot.title = "键入新快捷键(截屏翻译)"
        view.window?.makeFirstResponder(nil)
    }
    @IBAction func registOneKeyB(_ sender: Any) {
        listenOneKeyB = true
        listenPopUp = false
        listenScreenShot = false
        listenOneKeyG = false
        setGKeyName()
        oneKeyB.title = "键入新快捷键(一键百度)"
        view.window?.makeFirstResponder(nil)
    }
    @IBAction func registOneKeyG(_ sender: Any) {
        listenOneKeyG = true
        listenPopUp = false
        listenScreenShot = false
        listenOneKeyB = false
        setGKeyName()
        oneKeyG.title = "键入新快捷键(一键谷歌)"
        view.window?.makeFirstResponder(nil)
    }
    // When a shortcut has been pressed by the user, turn off listening so the window stops listening for keybinds
    // Put the shortcut into a JSON friendly struct and save it to storage
    // Update the shortcut button to show the new keybind
    // Make the clear button enabled to users can remove the shortcut
    // Finally, tell AppDelegate to start listening for the new keybind
    func updateGlobalShortcut(_ event : NSEvent,storeJSON:String) {
        if let characters = event.charactersIgnoringModifiers {
            let newGlobalKeybind = GlobalKeybindPreferences.init(
                function: event.modifierFlags.contains(.function),
                control: event.modifierFlags.contains(.control),
                command: event.modifierFlags.contains(.command),
                shift: event.modifierFlags.contains(.shift),
                option: event.modifierFlags.contains(.option),
                capsLock: event.modifierFlags.contains(.capsLock),
                carbonFlags: event.modifierFlags.carbonFlags,
                characters: characters,
                keyCode: UInt32(event.keyCode)
            )
            
            
            if storeJSON == "globalKeybindP.json" {
                self.listenPopUp = false
                Storage.store(newGlobalKeybind, to: .documents, as: storeJSON)
                popUp.title = newGlobalKeybind.description + "  （弹出窗口)"
                appDelegate.hotKeyPopUp = HotKey(keyCombo: KeyCombo(carbonKeyCode: UInt32(event.keyCode), carbonModifiers: event.modifierFlags.carbonFlags))
            }
            if storeJSON == "globalKeybindS.json" {
                self.listenScreenShot = false
                Storage.store(newGlobalKeybind, to: .documents, as: storeJSON)
                screenShot.title = newGlobalKeybind.description + "  (截屏翻译)"
                appDelegate.hotKeyScreenShot = HotKey(keyCombo: KeyCombo(carbonKeyCode: UInt32(event.keyCode), carbonModifiers: event.modifierFlags.carbonFlags))
            }
            if storeJSON == "globalKeybindB.json" {
                self.listenOneKeyB = false
                Storage.store(newGlobalKeybind, to: .documents, as: storeJSON)
                oneKeyB.title = newGlobalKeybind.description + "  (一键百度)"
                appDelegate.hotKeyOneKeyB = HotKey(keyCombo: KeyCombo(carbonKeyCode: UInt32(event.keyCode), carbonModifiers: event.modifierFlags.carbonFlags))
            }
            if storeJSON == "globalKeybindG.json" {
                self.listenOneKeyG = false
                Storage.store(newGlobalKeybind, to: .documents, as: storeJSON)
                oneKeyG.title = newGlobalKeybind.description + "  (一键谷歌)"
                appDelegate.hotKeyOneKeyG = HotKey(keyCombo: KeyCombo(carbonKeyCode: UInt32(event.keyCode), carbonModifiers: event.modifierFlags.carbonFlags))
            }
        }
    }
    
    // If the shortcut is cleared, clear the UI and tell AppDelegate to stop listening to the previous keybind.
    func unregistPopUp(_ sender: Any?) {
        appDelegate.hotKeyPopUp = nil
        Storage.remove("globalKeybindP.json", from: .documents)
    }
    func unregistScreenShot(_ sender: Any?) {
        appDelegate.hotKeyScreenShot = nil
        Storage.remove("globalKeybindS.json", from: .documents)
    }
    func unregistOneKeyB(_ sender: Any?) {
        appDelegate.hotKeyOneKeyB = nil
        
        Storage.remove("globalKeybindB.json", from: .documents)
    }
    func unregistOneKeyG(_ sender: Any?) {
        appDelegate.hotKeyOneKeyG = nil
        
        Storage.remove("globalKeybindG.json", from: .documents)
    }
    
    func setGKey() {
        // 监听当前页面 .keyDown 事件
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            if self.listenPopUp {
                self.unregistPopUp(nil)
                self.updateGlobalShortcut($0,storeJSON: "globalKeybindP.json")
            }
            if self.listenScreenShot {
                self.unregistScreenShot(nil)
                self.updateGlobalShortcut($0,storeJSON: "globalKeybindS.json")
            }
            if self.listenOneKeyB {
                self.unregistOneKeyB(nil)
                self.updateGlobalShortcut($0,storeJSON: "globalKeybindB.json")
            }
            if self.listenOneKeyG {
                self.unregistOneKeyG(nil)
                self.updateGlobalShortcut($0,storeJSON: "globalKeybindG.json")
            }
            return nil
        }
    }
    
    func setGKeyName() {
        // 检查本地存储快捷键
        if Storage.fileExists("globalKeybindP.json", in: .documents) {
            let globalKeybinds =
                Storage.retrieve("globalKeybindP.json", from: .documents, as: GlobalKeybindPreferences.self)
            popUp.title = globalKeybinds.description + "  (弹出窗口)"
        } else {
            popUp.title = "⌥空格键 (弹出窗口)"
        }
        if Storage.fileExists("globalKeybindS.json", in: .documents) {
            let globalKeybinds =
                Storage.retrieve("globalKeybindS.json", from: .documents, as: GlobalKeybindPreferences.self)
            screenShot.title = globalKeybinds.description + "  (截屏翻译)"
        } else {
            screenShot.title = "⌘H (截屏翻译)"
        }
        if Storage.fileExists("globalKeybindB.json", in: .documents) {
            let globalKeybinds =
                Storage.retrieve("globalKeybindB.json", from: .documents, as: GlobalKeybindPreferences.self)
            oneKeyB.title = globalKeybinds.description + "  (一键百度)"
        } else {
            oneKeyB.title = "⌘B (一键百度)"
        }
        if Storage.fileExists("globalKeybindG.json", in: .documents) {
            let globalKeybinds =
                Storage.retrieve("globalKeybindG.json", from: .documents, as: GlobalKeybindPreferences.self)
            oneKeyG.title = globalKeybinds.description + "  (一键谷歌)"
        } else {
            oneKeyG.title = "⌘G (一键谷歌)"
        }
    }
    
}

