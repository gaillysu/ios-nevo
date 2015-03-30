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
    private var mColor:NSNumber
    var typeName:String {
        get {
            return self.mType.rawValue
        }
    }
    
    init(type:NotificationType, color:NSNumber){
        mType = type
        mColor = color
    }
    
    
    class func indexOfObjectAtType(settingArray:[NotificationSetting], type:NotificationType) -> NotificationSetting?{
        for setting in settingArray {
            if setting.getType() == type {
                return setting
            }
        }
        return nil
    }

    func updateValue(color:NSNumber, states:Bool){
//        mColor = NSNumber(unsignedInt: EnterNotificationController.getLedColor(mType.rawValue))
//        mStates = EnterNotificationController.getMotorOnOff(mType.rawValue)
        mColor = color
        mStates = states
    }
    
    func description() -> String{
        var description = ""
        description = "type:\(mType.rawValue) color:\(mColor) status:\(mStates)"
        return description
    }
    
    func getColorName() ->String{
        var colorName = ""
        return colorName
    }
   
    func getColor() ->NSNumber {
        return mColor
    }
    
    func setColor(color:NSNumber) {
        mColor = color
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
    
}

enum NotificationType:NSString {
    case CALL = "CALL"
    case SMS = "SMS"
    case EMAIL = "EMAIL"
    case FACEBOOK = "Facebook"
    case CALENDAR = "Calendar"
    case WECHAT = "WeChat"
    
    static let allValues:[NotificationType] = [CALL, SMS, EMAIL, FACEBOOK, CALENDAR, WECHAT]
}