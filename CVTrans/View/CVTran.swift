//
//  CVTran.swift
//  CVTrans
//
//  Created by 小洋粉 on 2019/9/12.
//  Copyright © 2019 小洋粉. All rights reserved.
//

import Cocoa

class CVTran: NSViewController {
    
    @IBOutlet weak var cvword: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(
            self, selector: #selector(listnerFunction(_:)),
            name: NSNotification.Name(rawValue: "setCvword"),
            object: nil)
        cvword.stringValue = Config.strStore
    }
}

// MARK: NotificationCenter
extension CVTran {
    @objc func listnerFunction(_ notification: NSNotification) {
        if let data = notification.userInfo?["data"] as? String {
            self.cvword.stringValue = data
        }
    }

}
