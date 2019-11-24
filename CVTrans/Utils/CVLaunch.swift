//
//  CVLaunch.swift
//  CVTrans
//
//  Created by 小洋粉 on 2019/9/12.
//  Copyright © 2019 小洋粉. All rights reserved.
//

import Cocoa
import ServiceManagement
class CVLaunch {
    static func startupAppWhenLogin(startup: Bool) {
        let appId = "com.xyf.CVlaunch";
        SMLoginItemSetEnabled(appId as CFString, startup);
        
        var startedAtLogin = false
        
        for app in NSWorkspace.shared.runningApplications {
            if app.bundleIdentifier == appId    {
                
                startedAtLogin = true;
            }
        }
        if startedAtLogin {
            let notification = Notification.Name("killme");
            DistributedNotificationCenter.default().post(name: notification, object: Bundle.main.bundleIdentifier!);
        }
    }
}
