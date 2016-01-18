//
//  NotificationSetting.swift
//  Nevo
//
//  Created by ideas on 15/3/18.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NotificationSetting: NSObject {
    private var mStates:Bool = true
    private let mType:NotificationType
    private var mClock:Int = 0
    private var mColor:NSNumber = 0
    var typeName:String {
        get {
            return self.mType.rawValue as String
        }
    }
    
    init(type:NotificationType, clock:Int , color:NSNumber,states:Bool){
        mType = type
        super.init()
        mClock = clock
        mColor = NSNumber(unsignedInt: self.replaceColor(clock))
        mStates = states
    }

    private func replaceColor(clock:Int)->UInt32{
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

    func updateValue(clock:Int, states:Bool){
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
    
    func setColor(color:Int) {
        mColor = color
    }

    func setClock(clock:Int) {
        mClock = clock
    }
    
    func getStates() -> Bool {
        return mStates
    }
    
    func setStates(states:Bool) {
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
    case CALL = "CALL"
    case SMS = "SMS"
    case EMAIL = "EMAIL"
    case FACEBOOK = "Facebook"
    case CALENDAR = "Calendar"
    case WECHAT = "WeChat"
    case WHATSAPP = "Whatsapp"
    
    static let allValues:[NotificationType] = [CALL, SMS, EMAIL, FACEBOOK, CALENDAR, WECHAT, WHATSAPP]
}