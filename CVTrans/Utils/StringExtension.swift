//
//  StringExtension.swift
//  CVTrans
//
//  Created by 小洋粉 on 2019/9/13.
//  Copyright © 2019 小洋粉. All rights reserved.
//


import Cocoa
import CommonCrypto

// md5
extension String {
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }
}

// 字符串方法扩展
extension String {
    // 正则 处理首字母缩略词和单字母单词
    // eg: IAmNotAGoat --> I Am Not 是A Goat
    func titlecased() -> String {
        return self
            .replacingOccurrences(of: "([a-z])([A-Z](?=[A-Z])[a-z]*)", with: "$1 $2", options: .regularExpression)
            .replacingOccurrences(of: "([A-Z])([A-Z][a-z])", with: "$1 $2", options: .regularExpression)
            .replacingOccurrences(of: "([a-z])([A-Z][a-z])", with: "$1 $2", options: .regularExpression)
            .replacingOccurrences(of: "([a-z])([A-Z][a-z])", with: "$1 $2", options: .regularExpression)
            .lowercased() // 金山不支持大写字母开头
            .trimmingCharacters(in: .whitespaces)
    }
}

