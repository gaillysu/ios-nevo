//
//  HomeView.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import UIkit

class HomeView: UIView {
    
    //Put all UI operation HomeView inside
    private let mClockTimerView = ClockView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-60, UIScreen.mainScreen().bounds.width-60), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!);//init "ClockView" ,Use the code relative layout

    let mProgressView:UIProgressView = UIProgressView(frame: CGRectMake(UIScreen.mainScreen().bounds.width/4, UIScreen.mainScreen().bounds.height-80, UIScreen.mainScreen().bounds.width/2, 20))
    
    func bulidHomeView() {

        mClockTimerView.currentTimer()
        self.addSubview(mClockTimerView)
        mClockTimerView.center = CGPointMake(self.frame.width/2.0, self.frame.height/2.0);//Using the center property determines the location of the ClockView
        //add the progressbar
        mProgressView.progressTintColor = AppTheme.NEVO_SOLAR_YELLOW()
        mProgressView.setProgress(0.57, animated: true)
        self.addSubview(mProgressView)
    }
    
    func getClockTimerView() -> ClockView {
        return mClockTimerView
    }
    
}