//
//  NotificationSetting.swift
//  Nevo
//
//  Created by ideas on 15/3/18.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NotificationSetting: NSObject {
    fileprivate var mStates:Bool = true
    fileprivate let mType:NotificationType
    fileprivate var mClock:Int = 0
    fileprivate var mColor:NSNumber = 0
    var typeName:String {
        get {
            return self.mType.rawValue as String
        }
    }
    
    init(type:NotificationType, clock:Int , color:NSNumber,states:Bool){
        mType = type
        super.init()
        mClock = clock
        mColor = NSNumber(value: self.replaceColor(clock) as UInt32)
        mStates = states
    }

    fileprivate func replaceColor(_ clock:Int)->UInt32{
        // default value
        var ledColor:UInt32
        switch clock {
        case 2:
            ledColor = SetNortificationRequest.SetNortificationRequestValues.RED_LED
        case 4:
            ledColor = SetNortificationRequest.SetNortificationRequestValues.BLUE_LED
        case 6:
            ledColor = SetNortificationRequest.SetNortificationRequestValues.LIGHTGREEN_LED
        case 8:
            ledColor = SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED
        case 10 :
            ledColor = SetNortificationRequest.SetNortificationRequestValues.ORANGE_LED
        case 12:
            ledColor = SetNortificationRequest.SetNortificationRequestValues.GREEN_LED
        case 14:
            ledColor = SetNortificationRequest.SetNortificationRequestValues.LIGHTGREEN_LED
        default:
            ledColor = 0xFF0000
        }
        return ledColor
    }

    func updateValue(_ clock:Int, states:Bool){
        mClock = clock
        mStates = states
    }
    
    func sdescription() -> String{
        var description = ""
        description = "type:\(mType.rawValue) color:\(mClock) status:\(mStates)"
        return description
    }
   
    func getClock() ->Int {
        return mClock
    }

    func getColor() ->NSNumber {
        return mColor
    }
    
    func setColor(_ color:Int) {
        mColor = NSNumber(value: color)
    }

    func setClock(_ clock:Int) {
        mClock = clock
    }
    
    func getStates() -> Bool {
        return mStates
    }
    
    func setStates(_ states:Bool) {
        mStates = states
    }
    /**
    get the type of setting
    
    :returns: NotificationType
    */
    func getType() -> NotificationType{
        return mType
    }

    func getColorName()->String {
        var ledColor:String
        switch mClock {
        case 2:
            ledColor = "RED"
        case 4:
            ledColor = "BLUE"
        case 6:
            ledColor = "LIGHTGREEN"
        case 8:
            ledColor = "YELLOW"
        case 10 :
            ledColor = "ORANGE"
        case 12:
            ledColor = "GREEN"
        default:
            ledColor = ""
        }
        return ledColor
    }
}

enum NotificationType:NSString {
    case call = "CALL"
    case sms = "SMS"
    case email = "EMAIL"
    case facebook = "Facebook"
    case calendar = "Calendar"
    case wechat = "WeChat"
    case whatsapp = "Whatsapp"
    
    static let allValues:[NotificationType] = [call, sms, email, facebook, calendar, wechat, whatsapp]
}
