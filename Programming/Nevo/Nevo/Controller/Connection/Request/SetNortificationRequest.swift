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
        static let VIOLET_LED:UInt32 = 0x080000
        static let PURPLE_LED:UInt32 = 0x020000
        //white LED control bit is bit0~10
        static let WHITE_1_LED:UInt32 = 0x000001
        static let WHITE_3_LED:UInt32 = 0x000004
        static let WHITE_5_LED:UInt32 = 0x000010
        static let WHITE_7_LED:UInt32 = 0x000040
        static let WHITE_9_LED:UInt32 = 0x000100
        static let WHITE_11_LED:UInt32 = 0x000400
    }
    
    private var call_vib_number:UInt8
    private var call_led_pattern:UInt32
    
    private var sms_vib_number:UInt8
    private var sms_led_pattern:UInt32
    
    private var email_vib_number:UInt8
    private var email_led_pattern:UInt32
    
    private var facebook_vib_number:UInt8
    private var facebook_led_pattern:UInt32
    
    private var twitter_vib_number:UInt8
    private var twitter_led_pattern:UInt32
    
    private var whatsapp_vib_number:UInt8
    private var whatsapp_led_pattern:UInt32
    
    private var wechat_vib_number:UInt8 = 0
    private var wechat_led_pattern:UInt32 = 0
    
    init(type: TypeModel) {
        
        //We set each colors, one by one. In case a color is chosen, we turn on the vibration
        call_vib_number = type.callStates
         ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
        call_led_pattern = (type.callCurrentColor as NSNumber).unsignedIntValue
        if call_vib_number == SetNortificationRequestValues.VIBRATION_ON
        {
            call_led_pattern = call_led_pattern | SetNortificationRequestValues.VIB_MOTOR
        }
        
        sms_vib_number = type.smsStates ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
        sms_led_pattern = (type.smsCurrentColor as NSNumber).unsignedIntValue
        if sms_vib_number == SetNortificationRequestValues.VIBRATION_ON
        {
            sms_led_pattern = sms_led_pattern | SetNortificationRequestValues.VIB_MOTOR
        }
        
        email_vib_number = type.emailStates ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
        email_led_pattern = (type.emailCurrentColor as NSNumber).unsignedIntValue
        if email_vib_number == SetNortificationRequestValues.VIBRATION_ON
        {
            email_led_pattern = email_led_pattern | SetNortificationRequestValues.VIB_MOTOR
        }
        
        facebook_vib_number = type.faceBookStates ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
        facebook_led_pattern = (type.faceBookCurrentColor as NSNumber).unsignedIntValue
        if facebook_vib_number == SetNortificationRequestValues.VIBRATION_ON
        {
            facebook_led_pattern = facebook_led_pattern | SetNortificationRequestValues.VIB_MOTOR
        }
        
        twitter_vib_number = EnterNotificationController.getMotorOnOff(EnterNotificationController.SOURCETYPE.TWITTER) ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
        twitter_led_pattern = EnterNotificationController.getLedColor(EnterNotificationController.SOURCETYPE.TWITTER)
        if twitter_vib_number == SetNortificationRequestValues.VIBRATION_ON
        {
            twitter_led_pattern = twitter_led_pattern | SetNortificationRequestValues.VIB_MOTOR
        }
        
        whatsapp_vib_number = EnterNotificationController.getMotorOnOff(EnterNotificationController.SOURCETYPE.WHATSAPP) ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
        whatsapp_led_pattern = EnterNotificationController.getLedColor(EnterNotificationController.SOURCETYPE.WHATSAPP)
        if whatsapp_vib_number == SetNortificationRequestValues.VIBRATION_ON
        {
            whatsapp_led_pattern = whatsapp_led_pattern | SetNortificationRequestValues.VIB_MOTOR
        }
        
        
    }
    
    override func getRawDataEx() -> NSArray {


        
        var values1 :[UInt8] = [0x00,SetNortificationRequest.HEADER(),
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
            
            UInt8(twitter_vib_number&0xFF),
            UInt8(twitter_led_pattern&0xFF)
            ]
        
        var values2 :[UInt8] = [0xFF,SetNortificationRequest.HEADER(),
            UInt8((twitter_led_pattern>>8)&0xFF),
            UInt8((twitter_led_pattern>>16)&0xFF),
            
            UInt8(whatsapp_vib_number&0xFF),
            UInt8(whatsapp_led_pattern&0xFF),
            UInt8((whatsapp_led_pattern>>8)&0xFF),
            UInt8((whatsapp_led_pattern>>16)&0xFF),
            
            UInt8(wechat_vib_number&0xFF),
            UInt8(wechat_led_pattern&0xFF),
            UInt8((wechat_led_pattern>>8)&0xFF),
            UInt8((wechat_led_pattern>>16)&0xFF),
            
            0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }
}
