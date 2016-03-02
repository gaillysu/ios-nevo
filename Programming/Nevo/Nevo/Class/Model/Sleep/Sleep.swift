//
//  Sleep.swift
//  Nevo
//
//  Created by Karl Chow on 10/8/15.
//  Copyright © 2015 Nevo. All rights reserved.
//

import Foundation

class Sleep:NSObject{
    
    private var weakSleep:Double;
    private var lightSleep:Double;
    private var deepSleep:Double;
    private var startTimer:NSTimeInterval = 0;
    private var endTimer:NSTimeInterval = 0;
    
    init(weakSleep: Double, lightSleep:Double , deepSleep:Double , startTimer:NSTimeInterval , endTimer:NSTimeInterval){
        self.deepSleep  = deepSleep;
        self.lightSleep = lightSleep;
        self.weakSleep = weakSleep;
        self.startTimer = startTimer;
        self.endTimer = endTimer;
    }

    func getStartTimer()->Double {
        return startTimer
    }

    func getEndTimer()->Double {
        return endTimer
    }

    func getWeakSleep() -> Double{
        return (weakSleep)
    }

    func getLightSleep() -> Double{
        return (lightSleep)
    }
    
    func getDeepSleep() -> Double{
        return (deepSleep)
    }
    
    func getTotalSleep() -> Double{
        return getLightSleep() + getDeepSleep() + getWeakSleep()
    }
}