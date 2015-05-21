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
            return self.mType.rawValue as String
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
    
    func sdescription() -> String{
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

    /**
    Get in front of the cell dot color

    :returns: Returns the color of the value
    */
    func getBagroundColor()->UIColor{
        var currentColor:UInt32 = self.getColor().unsignedIntValue
        if (currentColor == SetNortificationRequest.SetNortificationRequestValues.RED_LED){
            return AppTheme.NEVO_CUSTOM_COLOR(Red: 229, Green: 0, Blue: 18)
        }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.BLUE_LED){
            return AppTheme.NEVO_CUSTOM_COLOR(Red: 44, Green: 166, Blue: 224)
        }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.GREEN_LED){
            return AppTheme.NEVO_CUSTOM_COLOR(Red: 141, Green: 194, Blue: 31)
        }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED){
            return AppTheme.NEVO_CUSTOM_COLOR(Red: 250, Green: 237, Blue: 0)
        }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.ORANGE_LED){
            return AppTheme.NEVO_CUSTOM_COLOR(Red: 242, Green: 150, Blue: 0)
        }
        else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.LIGHTGREEN_LED){
            return AppTheme.NEVO_CUSTOM_COLOR(Red: 13, Green: 172, Blue: 103)
        }
        return UIColor.whiteColor()
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