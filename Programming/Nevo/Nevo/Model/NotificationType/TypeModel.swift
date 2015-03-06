//
//  TypeModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class TypeModel: NSObject {
    var faceBookStates:Bool = true
    private var faceBookTypeString:NSString = SetNortificationRequest.SOURCETYPE.FACEBOOK
    private var faceBookImageIcon:NSString = "facebookIcon"
    private var faceBookCurrentColor:NSNumber!


    var smsStates:Bool = true
    private let smsTypeString:NSString = SetNortificationRequest.SOURCETYPE.SMS
    private let smsImageIcon:NSString = "smsIcon"
    private var smsCurrentColor:NSNumber!

    var callStates:Bool = true
    private let callTypeString:NSString = SetNortificationRequest.SOURCETYPE.CALL
    private let callImageIcon:NSString = "callIcon"
    private var callCurrentColor:NSNumber!

    var emailStates:Bool = true
    private let emailTypeString:NSString = SetNortificationRequest.SOURCETYPE.EMAIL
    private let emailImageIcon:NSString = "emailIcon"
    private var emailCurrentColor:NSNumber!

    private var contentArray:NSMutableArray!

    override init() {
        super.init()
        faceBookCurrentColor = NSNumber(unsignedInt: SetNortificationRequest.getLedColor(faceBookTypeString))
        if (faceBookCurrentColor.isEqualToNumber(NSNumber(unsignedInt: SetNortificationRequest.SetNortificationRequestValues.LED_OFF))){
            faceBookStates = false
        }

        smsCurrentColor = NSNumber(unsignedInt: SetNortificationRequest.getLedColor(smsTypeString))
        if (smsCurrentColor.isEqualToNumber(NSNumber(unsignedInt: SetNortificationRequest.SetNortificationRequestValues.LED_OFF))){
            smsStates = false
        }

        callCurrentColor = NSNumber(unsignedInt: SetNortificationRequest.getLedColor(callTypeString))
        if (callCurrentColor.isEqualToNumber(NSNumber(unsignedInt: SetNortificationRequest.SetNortificationRequestValues.LED_OFF))){
            callStates = false
        }

        emailCurrentColor = NSNumber(unsignedInt: SetNortificationRequest.getLedColor(emailTypeString))
        if (emailCurrentColor.isEqualToNumber(NSNumber(unsignedInt: SetNortificationRequest.SetNortificationRequestValues.LED_OFF))){
            emailStates = false
        }

        contentArray = NSMutableArray(objects:
            [faceBookStates,faceBookTypeString,faceBookImageIcon,faceBookCurrentColor],
            [smsStates,smsTypeString,smsImageIcon,smsCurrentColor],
            [callStates,callTypeString,callImageIcon,callCurrentColor],
            [emailStates,emailTypeString,emailImageIcon,emailCurrentColor])
    }

    func setNotificationTypeStates(type:NSString,states:Bool){
        if (type.isEqualToString(faceBookTypeString)){
            faceBookStates = states
        }else if (type.isEqualToString(smsTypeString)){
            smsStates = states
        }else if (type.isEqualToString(callTypeString)){
            callStates = states
        }else if (type.isEqualToString(emailTypeString)){
            emailStates = states
        }
    }

    func getNotificationTypeContent()-> NSMutableArray {
        if (contentArray.count>0){
            contentArray.removeAllObjects()
        }
        contentArray.setArray([
            [faceBookStates,faceBookTypeString,faceBookImageIcon,faceBookCurrentColor],
        [smsStates,smsTypeString,smsImageIcon,smsCurrentColor],
    [callStates,callTypeString,callImageIcon,callCurrentColor],
[emailStates,emailTypeString,emailImageIcon,emailCurrentColor]
            ])
        return contentArray
    }

}
