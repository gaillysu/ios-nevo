//
//  TypeModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class TypeModel: NSObject {
    var faceBookStates:Bool!
    private var faceBookTypeString:NSString = "FaceBook"
    private var faceBookImageIcon:NSString = "facebookIcon"

    var smsStates:Bool!
    private let smsTypeString:NSString = "SMS"
    private let smsImageIcon:NSString = "smsIcon"

    var callStates:Bool!
    private let callTypeString:NSString = "CALL"
    private let callImageIcon:NSString = "callIcon"

    var emailStates:Bool!
    private let emailTypeString:NSString = "EMAIL"
    private let emailImageIcon:NSString = "emailIcon"

    private var contentArray:NSMutableArray!

    override init() {
        super.init()

        faceBookStates = true
        smsStates = true
        callStates = true
        emailStates = true

        contentArray = NSMutableArray(objects: [faceBookStates,faceBookTypeString,faceBookImageIcon],
            [smsStates,smsTypeString,smsImageIcon],
            [callStates,callTypeString,callImageIcon],
            [emailStates,emailTypeString,emailImageIcon])
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
            contentArray.setArray([[faceBookStates,faceBookTypeString,faceBookImageIcon],
                [smsStates,smsTypeString,smsImageIcon],
                [callStates,callTypeString,callImageIcon],
                [emailStates,emailTypeString,emailImageIcon]])
        }else{
            contentArray.setArray([[faceBookStates,faceBookTypeString,faceBookImageIcon],
                [smsStates,smsTypeString,smsImageIcon],
                [callStates,callTypeString,callImageIcon],
                [emailStates,emailTypeString,emailImageIcon]])
        }
        return contentArray
    }

}
