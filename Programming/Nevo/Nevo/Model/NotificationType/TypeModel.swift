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
    private var faceBookTypeString:NSString = EnterNotificationController.SOURCETYPE.FACEBOOK
    private var faceBookImageIcon:NSString = "facebookIcon"
    var faceBookCurrentColor:NSNumber!


    var smsStates:Bool = true
    private let smsTypeString:NSString = EnterNotificationController.SOURCETYPE.SMS
    private let smsImageIcon:NSString = "smsIcon"
    var smsCurrentColor:NSNumber!

    var callStates:Bool = true
    private let callTypeString:NSString = EnterNotificationController.SOURCETYPE.CALL
    private let callImageIcon:NSString = "callIcon"
    var callCurrentColor:NSNumber!

    var emailStates:Bool = true
    private let emailTypeString:NSString = EnterNotificationController.SOURCETYPE.EMAIL
    private let emailImageIcon:NSString = "emailIcon"
    var emailCurrentColor:NSNumber!

    private var contentArray:NSMutableArray!

    override init() {
        super.init()
        faceBookCurrentColor = NSNumber(unsignedInt: EnterNotificationController.getLedColor(faceBookTypeString))
        faceBookStates = EnterNotificationController.getMotorOnOff(faceBookTypeString)

        smsCurrentColor = NSNumber(unsignedInt: EnterNotificationController.getLedColor(smsTypeString))
        smsStates = EnterNotificationController.getMotorOnOff(smsTypeString)
        
        callCurrentColor = NSNumber(unsignedInt: EnterNotificationController.getLedColor(callTypeString))
        callStates = EnterNotificationController.getMotorOnOff(callTypeString)

        emailCurrentColor = NSNumber(unsignedInt: EnterNotificationController.getLedColor(emailTypeString))
        emailStates = EnterNotificationController.getMotorOnOff(emailTypeString)

        contentArray = NSMutableArray(objects:
            [faceBookStates,faceBookTypeString,faceBookImageIcon,faceBookCurrentColor],
            [smsStates,smsTypeString,smsImageIcon,smsCurrentColor],
            [callStates,callTypeString,callImageIcon,callCurrentColor],
            [emailStates,emailTypeString,emailImageIcon,emailCurrentColor])
    }

    func setNotificationTypeStates(type:NSString,states:Bool){
        if (type.isEqualToString(faceBookTypeString)){
            faceBookStates = states
            faceBookCurrentColor = NSNumber(unsignedInt:EnterNotificationController.getLedColor(faceBookTypeString))
        }else if (type.isEqualToString(smsTypeString)){
            smsStates = states
            smsCurrentColor = NSNumber(unsignedInt:EnterNotificationController.getLedColor(smsTypeString))
        }else if (type.isEqualToString(callTypeString)){
            callStates = states
            callCurrentColor = NSNumber(unsignedInt: EnterNotificationController.getLedColor(callTypeString))
        }else if (type.isEqualToString(emailTypeString)){
            emailStates = states
            emailCurrentColor = NSNumber(unsignedInt:EnterNotificationController.getLedColor(emailTypeString))
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
