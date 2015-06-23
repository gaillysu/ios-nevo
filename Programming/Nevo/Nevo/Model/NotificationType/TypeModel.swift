//
//  TypeModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class TypeModel: NSObject {

    private var states:Bool?
    private var typeString:NSString?
    private var imageIcon:NSString?
    private var currentColor:NSNumber?
    private var getDictionary:NSDictionary!

    init(type:NSString, state:Bool, icon:NSString, color:NSNumber) {
        super.init()
        states = state
        typeString = type
        imageIcon = icon
        currentColor = color
        getDictionary = NSDictionary(objectsAndKeys: states!,"states",typeString!,"type",imageIcon!,"icon",currentColor!,"color")
    }

    func setNotificationTypeStates(type:NSString, state:Bool, icon:NSString, color:NSNumber){
        states = state
        typeString = type
        imageIcon = icon
        currentColor = color
    }

    func getNotificationTypeContent() ->NSDictionary {

        getDictionary = NSDictionary(objectsAndKeys: states!,"states",typeString!,"type",imageIcon!,"icon",currentColor!,"color")
        return getDictionary
    }

}
