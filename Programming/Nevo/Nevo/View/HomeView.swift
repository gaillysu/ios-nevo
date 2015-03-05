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

    private let mProgressView:UIProgressView = UIProgressView(frame: CGRectMake(UIScreen.mainScreen().bounds.width/4, UIScreen.mainScreen().bounds.height-80, UIScreen.mainScreen().bounds.width/2, 20))
    
    //a uiview for animation
    var mAnimationView:AnnularProgressView = AnnularProgressView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
    
    func bulidHomeView() {
        self.addSubview(mAnimationView)
        //REMOVE add a test function
        mAnimationView.testDrawAnnularProgressBar()
        
        mClockTimerView.currentTimer()
        self.addSubview(mClockTimerView)
        mClockTimerView.center = CGPointMake(self.frame.width/2.0, self.frame.height/2.0);//Using the center property determines the location of the ClockView
        
        //add the progressbar
        mProgressView.progressTintColor = AppTheme.NEVO_SOLAR_YELLOW()
        setProgressViewProgress(0.0)
        self.addSubview(mProgressView)

    }
    
    func getClockTimerView() -> ClockView {
        return mClockTimerView
    }
    
    /**
    set the progress of the progressView
    
    :param: progress
    :param: animated
    */
    func setProgressViewProgress(progress: Float, animated: Bool = true){
        if !progress.isNaN{
            mProgressView.setProgress(progress, animated: animated)
        }
    }
    
    
    
    
}