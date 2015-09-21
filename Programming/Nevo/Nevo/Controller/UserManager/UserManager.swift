//
//  UserManager.swift
//  Nevo
//
//  Created by leiyuncun on 15/9/21.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserManager: NSObject {
    private var delegate:[AnyObject] = []
    class var sharedInstance : UserManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : UserManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = UserManager()
        }
        return Static.instance!
    }

    override init() {
        super.init()
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("RefreshAction"), userInfo: nil, repeats: true)
    }


    func setRefreshObject(object:DataRefreshDelegate){
        delegate.append(object)
    }

    /**
    Refresh every object callback

    :param: timer:timer object
    */
    func RefreshAction(){
        for reDelegate in delegate {
            reDelegate.dataRefresh!()
        }
    }
}

@objc protocol DataRefreshDelegate {

    /**
    Refresh the protocol object
    */
    optional func dataRefresh();
}
