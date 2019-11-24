//
//  WebServer.swift
//  CVTrans
//
//  Created by 小洋粉 on 2019/9/15.
//  Copyright © 2019 小洋粉. All rights reserved.
//

import Swifter
import SwiftyJSON

//class WebServer {
//    let server = HttpServer()
//}
//
//extension WebServer {
//    func login() {
//        server["/github"] = {request in
//            let params = request.queryParams
//            let token = params[0].1
//            if token != "" {
//                CVApi.login(token: token)
//                return .raw(200,"OK",
//                            ["Access-Control-Allow-Origin": "http://cv.qtranser.cn"],
//                            { writer in
//                                try? writer.write([UInt8]("登陆成功".utf8))
//                })
//            } else {
//                return .raw(200,"OK",
//                            ["Access-Control-Allow-Origin": "http://cv.qtranser.cn"],
//                            { writer in
//                                try? writer.write([UInt8]("登陆失败".utf8))
//                })
//            }
//        }
//        try! server.start(23999)
//    }
//}
//
//extension WebServer {
//    static func initLoginInfo() -> String {
//        if Storage.fileExists("userInfo.json", in: .documents) {
//            let userInfo = Storage.retrieve("userInfo.json", from: .documents, as: JSON.self)
//            return userInfo["name"].stringValue
//        }
//        return "登陆"
//    }
//}
