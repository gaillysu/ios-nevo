//
//  SetNortificationRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetNortificationRequest: NevoRequest {
    override func getRawDataEx() -> NSArray {
       
        var call_vib_number:UInt8 = 3
        var call_led_pattern:UInt32 = 0
        
        var sms_vib_number:UInt8 = 2
        var sms_led_pattern:UInt32 = 0
        
        var email_vib_number:UInt8 = 1
        var email_led_pattern:UInt32 = 0
        
        var facebook_vib_number:UInt8 = 3
        var facebook_led_pattern:UInt32 = 0

        var twitter_vib_number:UInt8 = 3
        var twitter_led_pattern:UInt32 = 0
        
        var whatsapp_vib_number:UInt8 = 3
        var whatsapp_led_pattern:UInt32 = 0

        var wechat_vib_number:UInt8 = 3
        var wechat_led_pattern:UInt32 = 0

        
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
