//
//  CVApi.swift
//  CVTrans
//
//  Created by 小洋粉 on 2019/9/12.
//  Copyright © 2019 小洋粉. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class CVApi{
    
    // 文字翻译
    public func request(parameters: Parameters,popover:NSPopover, statusItem: NSStatusItem) {
        Alamofire.request("http://cv.qtranser.cn/api/transer",method: .post, parameters: parameters)
            .responseJSON { response in
                let json = JSON(response.result.value as Any)
                self.wordProcess(json: json, parameters: parameters,popover: popover, statusItem:statusItem)
                //self.baidu(str:parameters["word"] as! String)
        }
    }
    
    // 图片翻译
    public func requestImage(parameters: Parameters,popover:NSPopover, statusItem: NSStatusItem) {
        Alamofire.request("http://cv.qtranser.cn/api/transeImage",method: .post, parameters: parameters)
            .responseJSON { response in
                let json = JSON(response.result.value as Any)
                self.wordProcess(json: json, parameters: parameters,popover: popover, statusItem:statusItem)
        }
    }
    
    // 自行百度
    public func baidu(str:String) {
        Alamofire.request(baiduURL(query: str), method: .get)
            .responseJSON{response in
                let json = JSON(response.result.value as Any)
                print(json)
        }
    }
    
    // 检查升级
    public static func update() {
        Alamofire.request("http://cv.qtranser.cn/api/update",method: .get)
            .responseJSON { response in
                let json = JSON(response.result.value as Any)
                if json["Version"].stringValue != ""{
                    if (Float(Config.version)!.isLess(than: (Float(json["Version"].stringValue) )!)) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Update"),
                                                        object: nil,
                                                        userInfo: ["updateURL": json["UpdateUrl"].stringValue])
                    }
                }
        }
    }
    
    public static func login(token:String) {
        let url = "https://api.github.com/user?access_token=" + token
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                let json = JSON(response.result.value as Any)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userName"),
                                                object: nil,
                                                userInfo: ["userName": json["name"].stringValue])
                print(json["name"].stringValue)
                Storage.store(json, to: .documents, as: "userInfo.json")
        }
    }
}

extension CVApi {
    // 自行百度
    public func baiduURL(query:String) -> String {
        let appid = "20190705000315070"
        let salt = String(Date().timeIntervalSince1970)
        let key = "4vPL62dEVVunRdx8PqYO"
        let str = appid + query + salt + key
        let sign = str.md5()
        
        var uri = URLComponents()
        uri.scheme = "https"
        uri.host = "fanyi-api.baidu.com"
        uri.path = "/api/trans/vip/translate"
        uri.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "from", value: Config.fromTo[Config.from]),
            URLQueryItem(name: "to", value:Config.fromTo[Config.to]),
            URLQueryItem(name: "appid", value: appid),
            URLQueryItem(name: "salt", value: salt),
            URLQueryItem(name: "sign", value: sign)
        ]
        return uri.url!.absoluteString
    }
}
// 文字处理
extension CVApi {
    func wordProcess(json: JSON,parameters: Parameters, popover:NSPopover,statusItem: NSStatusItem)  {
        var word: String = ""
        if parameters["word"] != nil {
            word = parameters["word"] as! String
        }
        // 百度结果
        var str = ""
        
        if json["trans_result"].array != nil {
            for item in json["trans_result"].array! {
                str += item["dst"].stringValue + "\n\n"
            }
            if !popover.isShown{  // 如果弹窗是打开状态则不在状态栏显示翻译结果
                statusItem.button?.title = json["trans_result"][0]["dst"].stringValue
            }
        }
        
        var strr = word + "\n\n"
        strr += str
        
        // 金山结果
        if str == "" {
            str = json["symbols"][0]["parts"][0]["means"][0].stringValue
            if !popover.isShown {  // 如果弹窗是打开状态则不在状态栏显示翻译结果
                statusItem.button!.title = str
            }
            
            if !json["symbols"][0]["word_symbol"].exists() {
                // 金山英文
                let en = json["symbols"][0]["ph_en"].stringValue
                let am = json["symbols"][0]["ph_am"].stringValue
                if en != "" {
                    strr += "英:[\(en)]"
                }
                if am != "" {
                    strr += "美:[\(am)]\n\n"
                }
                if (json["symbols"][0]["parts"].array != nil) {
                    for item in json["symbols"][0]["parts"].array! {
                        strr += item["part"].stringValue + "\n"
                        if item["part"].stringValue == "abbr." {
                            // 缩写
                            for i in item["means"].array! {
                                strr += i.stringValue + "\n"
                            }
                        } else {
                            // 普通
                            for i in item["means"].array! {
                                strr += i.stringValue + ";  "
                            }
                            
                            strr += "\n"
                        }
                    }
                }
            } else {
                // 金山中文
                var strrr = ""
                if json["symbols"][0]["parts"].array != nil {
                    for item in json["symbols"][0]["parts"].array! {
                        for i in item["means"].array! {
                            strr += i["word_mean"].stringValue + "\n"
                            strrr += i["word_mean"].stringValue + ", "
                        }
                    }
                }
                statusItem.button!.title = strrr
            }
        }
        Config.strStore = strr
        // 通知弹出详情页面更新数据。
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setCvword"),
                                        object: nil,
                                        userInfo: ["data": strr])
       
    }
}


