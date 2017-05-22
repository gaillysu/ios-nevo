//
//  Int+Extension.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/29.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation

extension String {
    func toInt() -> Int {
        return NSString(format: "%@", self).integerValue
    }
    
    func toDouble() -> Double {
        return NSString(format: "%@", self).doubleValue
    }
    
    func toFloat() -> Float {
        return NSString(format: "%@", self).floatValue
    }
    
    func length() ->Int {
        return self.characters.count
    }
    
    //binary -> decimal
    func binToDecInt() -> Int {
        let numValue = self
        var sum = 0
        for c in 0..<numValue.characters.count {
            let index = numValue.index(numValue.startIndex, offsetBy: c)
            let value = numValue[index]
            sum = sum * 2 + "\(value)".toInt()
        }
        return sum
    }
    
    //hexadecimal -> decimal
    func hex2dec() -> Int {
        let str = self.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }
    
    func jsonToArray() -> [Any] {
        do{
            let data:Data = self.data(using: String.Encoding.utf8)!
            let array = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let JsonToArray = array as! [Any]
            return JsonToArray
        }catch{
            return []
        }
    }
}
