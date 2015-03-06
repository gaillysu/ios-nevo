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
    
    struct SOURCETYPE {
        static let CALL:NSString = "CALL"
        static let SMS:NSString = "SMS"
        static let EMAIL:NSString = "EMAIL"
        static let FACEBOOK:NSString = "FaceBook"
        static let TWITTER:NSString = "Twitter"
        static let WHATSAPP:NSString = "Whatsapp"
    }
    
    class func setLedColor(sourceType: NSString,ledColor:UInt32)
    {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        
        userDefaults.setObject(UInt(ledColor),forKey:sourceType)
        
        userDefaults.synchronize()
        
    }
    class  func getLedColor(sourceType: NSString) ->UInt32
    {
        if let color = NSUserDefaults.standardUserDefaults().objectForKey(sourceType) as? UInt
        {
            return UInt32(color)
        }
        // default value
        else{
            if sourceType == SOURCETYPE.CALL  { return SetNortificationRequest.SetNortificationRequestValues.BLUE_LED }
            if sourceType == SOURCETYPE.SMS  { return SetNortificationRequest.SetNortificationRequestValues.GREEN_LED }
            if sourceType == SOURCETYPE.EMAIL  { return SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED }
            if sourceType == SOURCETYPE.FACEBOOK  { return SetNortificationRequest.SetNortificationRequestValues.RED_LED }
            if sourceType == SOURCETYPE.TWITTER  { return SetNortificationRequest.SetNortificationRequestValues.VIOLET_LED }
            if sourceType == SOURCETYPE.WHATSAPP  { return SetNortificationRequest.SetNortificationRequestValues.PURPLE_LED }

            return 0xFF0000
        }
    }

    struct SetNortificationRequestValues {
        static let VIBRATION_ON:UInt8 = 0x03
        static let VIBRATION_OFF:UInt8 = 0x00
        
        static let LED_OFF:UInt32 = 0x000000
        
        static let BLUE_LED:UInt32 = 0x010000
        static let GREEN_LED:UInt32 = 0x020000
        static let YELLOW_LED:UInt32 = 0x040000
        static let RED_LED:UInt32 = 0x080000
        static let VIOLET_LED:UInt32 = 0x100000
        static let PURPLE_LED:UInt32 = 0x200000
        
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
    
    override init() {
        
        //We set each colors, one by one. In case a color is chosen, we turn on the vibration
        
        call_vib_number = SetNortificationRequestValues.VIBRATION_ON
        call_led_pattern = SetNortificationRequest.getLedColor(SOURCETYPE.CALL)
        
        if(call_led_pattern == SetNortificationRequestValues.LED_OFF) {
            call_vib_number = SetNortificationRequestValues.VIBRATION_OFF
        }
        
        
        sms_vib_number = SetNortificationRequestValues.VIBRATION_ON
        sms_led_pattern = SetNortificationRequest.getLedColor(SOURCETYPE.SMS)
        
        if(sms_led_pattern == SetNortificationRequestValues.LED_OFF) {
            sms_vib_number = SetNortificationRequestValues.VIBRATION_OFF
        }
        
        
        email_vib_number = SetNortificationRequestValues.VIBRATION_ON
        email_led_pattern = SetNortificationRequest.getLedColor(SOURCETYPE.EMAIL)
        
        if(email_led_pattern == SetNortificationRequestValues.LED_OFF) {
            email_vib_number = SetNortificationRequestValues.VIBRATION_OFF
        }
        
        
        facebook_vib_number = SetNortificationRequestValues.VIBRATION_ON
        facebook_led_pattern = SetNortificationRequest.getLedColor(SOURCETYPE.FACEBOOK)
        
        if(facebook_led_pattern == SetNortificationRequestValues.LED_OFF) {
            facebook_vib_number = SetNortificationRequestValues.VIBRATION_OFF
        }
        
        
        twitter_vib_number = SetNortificationRequestValues.VIBRATION_ON
        twitter_led_pattern = SetNortificationRequest.getLedColor(SOURCETYPE.TWITTER)
        
        if(twitter_led_pattern == SetNortificationRequestValues.LED_OFF) {
            twitter_vib_number = SetNortificationRequestValues.VIBRATION_OFF
        }
        
        
        whatsapp_vib_number = SetNortificationRequestValues.VIBRATION_ON
        whatsapp_led_pattern = SetNortificationRequest.getLedColor(SOURCETYPE.WHATSAPP)
        
        if(whatsapp_led_pattern == SetNortificationRequestValues.LED_OFF) {
            whatsapp_vib_number = SetNortificationRequestValues.VIBRATION_OFF
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
