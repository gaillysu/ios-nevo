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
    
    private var calendar_vib_number:UInt8
    private var calendar_led_pattern:UInt32
    
    //private var whatsapp_vib_number:UInt8
    //private var whatsapp_led_pattern:UInt32
    
    private var wechat_vib_number:UInt8 = 0
    private var wechat_led_pattern:UInt32 = 0
    
    init(typeArray: NSArray) {
        
        //We set each colors, one by one. In case a color is chosen, we turn on the vibration
        let type:TypeModel = typeArray.objectAtIndex(2) as TypeModel
        call_vib_number = (type.getNotificationTypeContent().objectForKey("states") as Bool)
         ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
        call_led_pattern = (type.getNotificationTypeContent().objectForKey("color") as NSNumber).unsignedIntValue
        if call_vib_number == SetNortificationRequestValues.VIBRATION_ON
        {
            call_led_pattern = call_led_pattern | SetNortificationRequestValues.VIB_MOTOR
        }

        let smstype:TypeModel = typeArray.objectAtIndex(1) as TypeModel
        sms_vib_number = (smstype.getNotificationTypeContent().objectForKey("states") as Bool) ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
        sms_led_pattern = (smstype.getNotificationTypeContent().objectForKey("color") as NSNumber).unsignedIntValue
        if sms_vib_number == SetNortificationRequestValues.VIBRATION_ON
        {
            sms_led_pattern = sms_led_pattern | SetNortificationRequestValues.VIB_MOTOR
        }

        let emailtype:TypeModel = typeArray.objectAtIndex(3) as TypeModel
        email_vib_number = (emailtype.getNotificationTypeContent().objectForKey("states") as Bool) ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
        email_led_pattern = (emailtype.getNotificationTypeContent().objectForKey("color") as NSNumber).unsignedIntValue
        if email_vib_number == SetNortificationRequestValues.VIBRATION_ON
        {
            email_led_pattern = email_led_pattern | SetNortificationRequestValues.VIB_MOTOR
        }

        let facebooktype:TypeModel = typeArray.objectAtIndex(0) as TypeModel
        facebook_vib_number = (facebooktype.getNotificationTypeContent().objectForKey("states") as Bool) ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
        facebook_led_pattern = (facebooktype.getNotificationTypeContent().objectForKey("color") as NSNumber).unsignedIntValue
        if facebook_vib_number == SetNortificationRequestValues.VIBRATION_ON
        {
            facebook_led_pattern = facebook_led_pattern | SetNortificationRequestValues.VIB_MOTOR
        }

        let calendartype:TypeModel = typeArray.objectAtIndex(4) as TypeModel
        calendar_vib_number = (calendartype.getNotificationTypeContent().objectForKey("states") as Bool) ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
        calendar_led_pattern = (calendartype.getNotificationTypeContent().objectForKey("color") as NSNumber).unsignedIntValue
        if calendar_vib_number == SetNortificationRequestValues.VIBRATION_ON
        {
            calendar_led_pattern = calendar_led_pattern | SetNortificationRequestValues.VIB_MOTOR
        }

        let wechattype:TypeModel = typeArray.objectAtIndex(5) as TypeModel
        wechat_vib_number = (wechattype.getNotificationTypeContent().objectForKey("states") as Bool) ? SetNortificationRequestValues.VIBRATION_ON : SetNortificationRequestValues.VIBRATION_OFF
        wechat_led_pattern = (wechattype.getNotificationTypeContent().objectForKey("color") as NSNumber).unsignedIntValue
        if wechat_vib_number == SetNortificationRequestValues.VIBRATION_ON
        {
            wechat_led_pattern = wechat_led_pattern | SetNortificationRequestValues.VIB_MOTOR
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
            
            UInt8(calendar_vib_number&0xFF),
            UInt8(calendar_led_pattern&0xFF)
            ]
        
        var values2 :[UInt8] = [0xFF,SetNortificationRequest.HEADER(),
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
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }
}
