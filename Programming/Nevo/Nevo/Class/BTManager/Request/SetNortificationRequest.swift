//
//  SetNortificationRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetNortificationRequest: NevoRequest {
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x02
    }
        
    struct SetNortificationRequestValues {
        //default vibrator number is 3
        static let VIBRATION_ON:UInt8 = 0x03
        static let VIBRATION_OFF:UInt8 = 0x00
        //motor control bit is bit23
        static let VIB_MOTOR:UInt32 = 0x800000
        static let LED_OFF:UInt32 = 0x000000
        //color LED control bit is bit16~21
        static let BLUE_LED:UInt32   = 0x010000
        static let GREEN_LED:UInt32  = 0x100000
        static let YELLOW_LED:UInt32 = 0x040000
        static let RED_LED:UInt32    = 0x200000
        static let ORANGE_LED:UInt32 = 0x080000
        static let LIGHTGREEN_LED:UInt32 = 0x020000
        //white LED control bit is bit0~10
        static let WHITE_1_LED:UInt32 = 0x000001
        static let WHITE_3_LED:UInt32 = 0x000004
        static let WHITE_5_LED:UInt32 = 0x000010
        static let WHITE_7_LED:UInt32 = 0x000040
        static let WHITE_9_LED:UInt32 = 0x000100
        static let WHITE_11_LED:UInt32 = 0x000400
    }
    
    fileprivate var call_vib_number:UInt8 = 0
    fileprivate var call_led_pattern:UInt32 = 0
    
    fileprivate var sms_vib_number:UInt8 = 0
    fileprivate var sms_led_pattern:UInt32 = 0
    
    fileprivate var email_vib_number:UInt8 = 0
    fileprivate var email_led_pattern:UInt32 = 0
    
    fileprivate var facebook_vib_number:UInt8 = 0
    fileprivate var facebook_led_pattern:UInt32 = 0
    
    fileprivate var calendar_vib_number:UInt8 = 0
    fileprivate var calendar_led_pattern:UInt32 = 0
    
    fileprivate var whatsapp_vib_number:UInt8 = 0
    fileprivate var whatsapp_led_pattern:UInt32 = 0
    
    fileprivate var wechat_vib_number:UInt8 = 0
    fileprivate var wechat_led_pattern:UInt32 = 0
    
    
    init(settingArray:[NotificationSetting]) {
        super.init()
        //We set each colors, one by one. In case a color is chosen, we turn on the vibration
        if let setting = self.indexOfObjectAtType(settingArray, type: NotificationType.call) {
            call_vib_number = setting.getStates() ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
            call_led_pattern = setting.getColor().uint32Value
            if call_vib_number == SetNortificationRequestValues.VIBRATION_ON
            {
                call_led_pattern = call_led_pattern | SetNortificationRequestValues.VIB_MOTOR
            }
        }

        if let setting = self.indexOfObjectAtType(settingArray, type: NotificationType.sms) {
            sms_vib_number = setting.getStates() ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
            sms_led_pattern = setting.getColor().uint32Value
            if sms_vib_number == SetNortificationRequestValues.VIBRATION_ON
            {
                sms_led_pattern = sms_led_pattern | SetNortificationRequestValues.VIB_MOTOR
            }
        }
        
        if let setting = self.indexOfObjectAtType(settingArray, type: NotificationType.email) {
            email_vib_number = setting.getStates() ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
            email_led_pattern = setting.getColor().uint32Value
            if email_vib_number == SetNortificationRequestValues.VIBRATION_ON
            {
                email_led_pattern = email_led_pattern | SetNortificationRequestValues.VIB_MOTOR
            }
        }

        if let setting = self.indexOfObjectAtType(settingArray, type: NotificationType.facebook) {
            facebook_vib_number = setting.getStates() ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
            facebook_led_pattern = setting.getColor().uint32Value
            if facebook_vib_number == SetNortificationRequestValues.VIBRATION_ON
            {
                facebook_led_pattern = facebook_led_pattern | SetNortificationRequestValues.VIB_MOTOR
            }
        }

        if let setting = self.indexOfObjectAtType(settingArray, type: NotificationType.calendar) {
            calendar_vib_number = setting.getStates() ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
            calendar_led_pattern = setting.getColor().uint32Value
            if calendar_vib_number == SetNortificationRequestValues.VIBRATION_ON
            {
                calendar_led_pattern = calendar_led_pattern | SetNortificationRequestValues.VIB_MOTOR
            }
        }

        if let setting = self.indexOfObjectAtType(settingArray, type: NotificationType.wechat) {
            wechat_vib_number = setting.getStates() ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
            wechat_led_pattern = setting.getColor().uint32Value
            if wechat_vib_number == SetNortificationRequestValues.VIBRATION_ON
            {
                wechat_led_pattern = wechat_led_pattern | SetNortificationRequestValues.VIB_MOTOR
            }
        }

        if let setting = self.indexOfObjectAtType(settingArray, type: NotificationType.whatsapp) {
            whatsapp_vib_number = setting.getStates() ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
            whatsapp_led_pattern = setting.getColor().uint32Value
            if whatsapp_vib_number == SetNortificationRequestValues.VIBRATION_ON
            {
                whatsapp_led_pattern = whatsapp_led_pattern | SetNortificationRequestValues.VIB_MOTOR
            }
        }

    }

    fileprivate func indexOfObjectAtType(_ settingArray:[NotificationSetting], type:NotificationType) -> NotificationSetting?{
        for setting in settingArray {
            if setting.getType() == type {
                return setting
            }
        }
        return nil
    }

    override func getRawDataEx() -> NSArray {
        
        let values1 :[UInt8] = [0x00,SetNortificationRequest.HEADER(),
            UInt8(call_vib_number&0xFF),
            UInt8(call_led_pattern&0xFF),
            UInt8((call_led_pattern>>8)&0xFF),
            UInt8((call_led_pattern>>16)&0xFF),
            
            UInt8(sms_vib_number&0xFF),
            UInt8(sms_led_pattern&0xFF),
            UInt8((sms_led_pattern>>8)&0xFF),
            UInt8((sms_led_pattern>>16)&0xFF),
            
            UInt8(email_vib_number&0xFF),
            UInt8(email_led_pattern&0xFF),
            UInt8((email_led_pattern>>8)&0xFF),
            UInt8((email_led_pattern>>16)&0xFF),
            
            UInt8(facebook_vib_number&0xFF),
            UInt8(facebook_led_pattern&0xFF),
            UInt8((facebook_led_pattern>>8)&0xFF),
            UInt8((facebook_led_pattern>>16)&0xFF),
            
            UInt8(calendar_vib_number&0xFF),
            UInt8(calendar_led_pattern&0xFF)
            ]
        
        let values2 :[UInt8] = [0xFF,SetNortificationRequest.HEADER(),
            UInt8((calendar_led_pattern>>8)&0xFF),
            UInt8((calendar_led_pattern>>16)&0xFF),
            
            UInt8(wechat_vib_number&0xFF),
            UInt8(wechat_led_pattern&0xFF),
            UInt8((wechat_led_pattern>>8)&0xFF),
            UInt8((wechat_led_pattern>>16)&0xFF),
            
            UInt8(0),
            UInt8(0),
            UInt8(0),
            UInt8(0),
            
            0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
}
