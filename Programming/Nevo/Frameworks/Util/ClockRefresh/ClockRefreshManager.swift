//
//  ClockRefreshManager.swift
//  Nevo
//
//  Created by leiyuncun on 15/10/6.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class ClockRefreshManager: NSObject {
    fileprivate var refreshObject:[ClockRefreshDelegate] = []

    /**
     A classic singelton pattern
     */
    class var sharedInstance : ClockRefreshManager {
        struct Singleton {
            static let instance = ClockRefreshManager()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
        /**
        *  Ten seconds to refresh the clock and read the data
        */
        Timer.scheduledTimer(timeInterval: 10, target: self, selector:#selector(ClockRefreshManager.refreshTimerAction(_:)), userInfo: nil, repeats: true);
    }

    func refreshTimerAction(_ timer:Timer){
        for delegate in refreshObject {
            delegate.clockRefreshAction()
        }
    }

    /**
    Set clock the refresh objects

    :param: delegate refresh objects
    */
    func setRefreshDelegate(_ delegate:ClockRefreshDelegate){
        for objectDelegate in refreshObject {
            if objectDelegate is StepsHistoryViewController {
                return
            }
            
            if objectDelegate is StepGoalSetingController {
                return
            }
        }
        refreshObject.append(delegate)
    }
}

protocol ClockRefreshDelegate {

    /**
    *  Refresh the callback protocol
    */
    func clockRefreshAction()
}
