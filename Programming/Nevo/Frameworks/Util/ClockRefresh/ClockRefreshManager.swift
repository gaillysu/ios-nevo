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
    static let instance = ClockRefreshManager()
    
    fileprivate override init() {
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
    
    func everyRefresh(_ block: @escaping () -> Void) {
        if #available(iOS 10.0, *) {
            let timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { (timer) in
                block()
            }
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        } else {
            let timer = Timer.every(15.seconds, {
                block()
            })
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
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
