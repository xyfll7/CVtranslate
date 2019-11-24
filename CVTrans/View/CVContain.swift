//
//  CVContain.swift
//  CVTrans
//
//  Created by 小洋粉 on 2019/9/12.
//  Copyright © 2019 小洋粉. All rights reserved.
//

import Cocoa

class CVContain: NSView {

    override func addSubview(_ view: NSView) {
        super.addSubview(view)
        // Drawing code here.
        view.frame = bounds
    }
    
}
