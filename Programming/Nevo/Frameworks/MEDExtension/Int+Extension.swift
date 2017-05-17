//
//  Int+Extension.swift
//  Nevo
//
//  Created by Karl-John Chow on 4/5/2017.
//  Copyright © 2017 Nevo. All rights reserved.
//

import Foundation

extension Int{
    
    func timeRepresentation() -> String {
        var time = ""
        let hour = Int(self / 60)
        if hour == 1 {
            time.append("\(hour) hour")
        }else if hour > 1 {
            time.append("\(hour) hours")
        }
        let minutes = self % 60
        if minutes == 1 {
            time.append(" \(minutes) minute")
        }else if minutes > 1 {
            time.append(" \(minutes) minutes")
        }
        return time
    }
    
    func shortTimeRepresentation() -> String {
        var time = ""
        let hour = Int(self / 60)
        if hour == 1 {
            time.append("\(hour)hr")
        }else if hour > 1 {
            time.append("\(hour)hrs")
        }
        
        let minutes = self % 60
        if minutes > 0 {
            time.append(" \(minutes)min")
        }
        return time
    }
    
    func superShortTimeRepresentation() -> String {
        var time = ""
        let hour = Int(self / 60)
        if hour > 0 {
            time.append("\(hour)h")
        }
        let minutes = self % 60
        if minutes > 0 {
            time.append(" \(minutes)m")
        }
        return time
    }
    
    func to2String() -> String {
        let value1:NSString = NSString(format: "%d", self)
        if value1.length>1 {
            return value1 as String;
        }else{
            return NSString(format: "0%d", self) as String
        }
    }
    
    func toCGFloat() -> CGFloat {
        let value1:NSString = NSString(format: "%f", self)
        return CGFloat(value1.floatValue)
    }
    
    func toFloat() -> Float {
        let value1:NSString = NSString(format: "%f", self)
        return value1.floatValue
    }
    
    //decimal-> binary
    func dec2binString() -> String {
        var numberValue = self
        var str = ""
        while numberValue > 0 {
            str = "\(numberValue % 2)" + str
            numberValue /= 2
        }
        return str
    }
    
    //decimal -> hexadecimal
    func dec2hex() -> String {
        return String(format: "%0X", self)
    }
}
