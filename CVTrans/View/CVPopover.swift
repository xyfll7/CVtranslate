//
//  CVPopover.swift
//  CVTrans
//
//  Created by 小洋粉 on 2019/9/12.
//  Copyright © 2019 小洋粉. All rights reserved.
//

import Cocoa

class CVPopover: NSViewController {
    
    @IBOutlet weak var to: NSPopUpButton!
    @IBOutlet weak var from: NSPopUpButton!
    @IBOutlet weak var flyState: NSButton!     // 获取按钮开关状态
    @IBOutlet weak var cVContain: CVContain!   // 翻译/设置界面 容器
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        addChild(CVTran())
        addChild(CVSett())
        cVContain.addSubview(children[0].view)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(listnerFunction(_:)),
            name: NSNotification.Name(rawValue: "setTranView"),
            object: nil)
        
        from.addItems(withTitles: ["中文","英语"])
        from.addItems(withTitles: ["粤语","文言文","日语","韩语","法语","西班牙语","泰语","阿拉伯语","俄语","葡萄牙语","德语","意大利语","希腊语","荷兰语","波兰语","保加利亚语","爱沙尼亚语","丹麦语","芬兰语","捷克语","罗马尼亚语","斯洛文尼亚语","瑞典语","匈牙利语","繁体中文","越南语"])
        to.addItems(withTitles: ["英语"])
        to.addItems(withTitles: ["粤语","文言文","日语","韩语","法语","西班牙语","泰语","阿拉伯语","俄语","葡萄牙语","德语","意大利语","希腊语","荷兰语","波兰语","保加利亚语","爱沙尼亚语","丹麦语","芬兰语","捷克语","罗马尼亚语","斯洛文尼亚语","瑞典语","匈牙利语","繁体中文","越南语"])
    }
    
}

// MARK: NotificationCenter
extension CVPopover {
    // 重新打开以后跳转到 翻译页面
    @objc func listnerFunction(_ notification: NSNotification) {
        if flyState.state == .on {
            flyState.state = .off
            transition(from: children[1], to: children[0], options: .allowUserInteraction, completionHandler: nil)
        }
    }
}

// MARK Action
extension CVPopover {
    // 翻译语言切换
    @IBAction func from(_ sender: NSPopUpButton) {
        Config.from = sender.selectedItem!.title
    }
    @IBAction func to(_ sender: NSPopUpButton) {
        Config.to = sender.selectedItem!.title
    }
    // 翻译/视图界面切换
    @IBAction func toggleView(_ sender: NSButton) {
        if sender.state == .on {
            transition(from: children[0], to: children[1], options: .allowUserInteraction, completionHandler: nil)
        } else {
            transition(from: children[1], to: children[0], options: .allowUserInteraction, completionHandler: nil)
        }
    }
    // 置顶状态切换
    @IBAction func toggleFly(_ sender: NSButton) {
        if sender.state == .on {
            Config.isfly = true
        } else {
            Config.isfly = false
        }
    }
}

extension CVPopover {
    // MARK: Storyboard instantiation
    static func freshController() -> CVPopover {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("CVPopover")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? CVPopover else {
            fatalError("Why cant i find CVPopover? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
