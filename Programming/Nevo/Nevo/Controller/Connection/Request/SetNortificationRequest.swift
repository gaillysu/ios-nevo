//
//  SetNortificationRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetNortificationRequest: NevoRequest {
    
    let VIBRATION_ON:UInt8 = 0x01
    let VIBRATION_OFF:UInt8 = 0x00
    
    let LED_OFF:UInt32 = 0x000000
    
    let BLUE_LED:UInt32 = 0x000101
    let GREEN_LED:UInt32 = 0x000201
    let YELLOW_LED:UInt32 = 0x000301
    let RED_LED:UInt32 = 0x000401
    let VIOLET_LED:UInt32 = 0x000501
    let PURPLE_LED:UInt32 = 0x000601
    
    let WHITE_1_LED:UInt32 = 0x010001
    let WHITE_3_LED:UInt32 = 0x030001
    let WHITE_5_LED:UInt32 = 0x050001
    let WHITE_7_LED:UInt32 = 0x070001
    let WHITE_9_LED:UInt32 = 0x090001
    let WHITE_11_LED:UInt32 = 0x0b0001
    
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
    
    private var wechat_vib_number:UInt8
    private var wechat_led_pattern:UInt32
    
    init(callColor callLedColor: UInt32 = BLUE_LED, smsColor smsLedColor: UInt32 = GREEN_LED, emailColor emailLedColor: UInt32 = YELLOW_LED, facebookColor facebookLedColor: UInt32 = RED_LED, twitterColor twitterLedColor: UInt32 = VIOLET_LED, whatsappColor whatsappLedColor: UInt32 = PURPLE_LED) {
        
        //We set each colors, one by one. In case a color is chosen, we turn on the vibration
        
        call_vib_number = VIBRATION_ON
        call_led_pattern = callLedColor
        
        if(call_led_pattern == LED_OFF) {
            call_vib_number = VIBRATION_OFF
        }
        
        
        sms_vib_number = VIBRATION_ON
        sms_led_pattern = smsLedColor
        
        if(sms_led_pattern == LED_OFF) {
            sms_vib_number = VIBRATION_OFF
        }
        
        
        email_vib_number = VIBRATION_ON
        email_led_pattern = emailLedColor
        
        if(email_led_pattern == LED_OFF) {
            email_vib_number = VIBRATION_OFF
        }
        
        
        facebook_vib_number = VIBRATION_ON
        facebook_led_pattern = facebookLedColor
        
        if(facebook_led_pattern == LED_OFF) {
            facebook_vib_number = VIBRATION_OFF
        }
        
        
        twitter_vib_number = VIBRATION_ON
        twitter_led_pattern = twitterLedColor
        
        if(twitter_led_pattern == LED_OFF) {
            twitter_vib_number = VIBRATION_OFF
        }
        
        
        whatsapp_vib_number = VIBRATION_ON
        whatsapp_led_pattern = whatsappLedColor
        
        if(whatsapp_led_pattern == LED_OFF) {
            whatsapp_vib_number = VIBRATION_OFF
        }
        
        
        wechat_vib_number = VIBRATION_ON
        wechat_led_pattern = whatsappLedColor
        
        if(wechat_led_pattern == LED_OFF) {
            wechat_vib_number = VIBRATION_OFF
        }
        
        
    }
    
    override func getRawDataEx() -> NSArray {


        
        var values1 :[UInt8] = [0x00,0x02,
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
        
        var values2 :[UInt8] = [0xFF,0x02,
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
