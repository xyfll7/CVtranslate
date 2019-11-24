//
//  Screenshot.swift
//  CVTrans
//
//  Created by 小洋粉 on 2019/9/15.
//  Copyright © 2019 小洋粉. All rights reserved.
//

import Cocoa

class Screenshot {
    public static func captureRegion(_ destination: String) -> URL {
        return captureRegion(URL(fileURLWithPath: destination))
    }
    public static func captureRegion(_ destination: URL) -> URL {
        let destinationPath = destination.path as String
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-r", "-x", destinationPath]
        task.launch()
        task.waitUntilExit()
        return destination
    }
}
