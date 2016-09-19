//
//  TypeModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class TypeModel: NSObject {

    fileprivate var states:Bool?
    fileprivate var typeString:NSString?
    fileprivate var imageIcon:NSString?
    fileprivate var currentColor:NSNumber?
    fileprivate var getDictionary:NSDictionary!

    init(type:NSString, state:Bool, icon:NSString, color:NSNumber) {
        super.init()
        states = state
        typeString = type
        imageIcon = icon
        currentColor = color
        getDictionary = ["states":states!, "type":typeString!, "icon":imageIcon!, "color":currentColor!]
    }

    func setNotificationTypeStates(_ type:NSString, state:Bool, icon:NSString, color:NSNumber){
        states = state
        typeString = type
        imageIcon = icon
        currentColor = color
    }

    func getNotificationTypeContent() ->NSDictionary {

        getDictionary = ["states":states!, "type":typeString!, "icon":imageIcon!, "color":currentColor!]
        return getDictionary
    }

}
