//
//  HomeView.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

class HomeView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var titleBgView: UIView!
    //Put all UI operation HomeView inside
    private let mClockTimerView = ClockView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-60, UIScreen.mainScreen().bounds.width-60), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!);//init "ClockView" ,Use the code relative layout

    var progressView:CircleProgressView?
    var progresValue:CGFloat = 0.0
    var animationView:AnimationView!
    
    private var mDelegate:ButtonManagerCallBack!
    
    func bulidHomeView(delegate:ButtonManagerCallBack) {
        mDelegate = delegate
        animationView = AnimationView(frame: self.frame, delegate: delegate)
        
        title.textColor = UIColor.whiteColor()
        title.text = NSLocalizedString("homeTitle", comment: "")
        title.font = AppTheme.SYSTEMFONTOFSIZE()
        title.textAlignment = NSTextAlignment.Center

        mClockTimerView.currentTimer()
        self.addSubview(mClockTimerView)
        mClockTimerView.center = CGPointMake(self.frame.width/2.0, self.frame.height/2.0)//Using the center property determines the location of the ClockView

        progressView = CircleProgressView()
        progressView?.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        progressView?.frame = CGRectMake(mClockTimerView.frame.origin.x-5, mClockTimerView.frame.origin.y-5, UIScreen.mainScreen().bounds.width-50, UIScreen.mainScreen().bounds.width-50)
        progressView?.setProgress(progresValue)
        self.layer.addSublayer(progressView)

    }

    
    func getClockTimerView() -> ClockView {
        return mClockTimerView
    }

    @IBAction func ButtonAction(sender: AnyObject) {
        mDelegate?.controllManager(sender)
    }

    /**
    set the progress of the progressView

    :param: progress
    :param: animated
    */
    func setProgress(progress: Float,dailySteps:Int,dailyStepGoal:Int){
        progresValue = CGFloat(progress)
        progressView?.setProgress(progresValue, Steps: dailySteps, GoalStep: dailyStepGoal)
    }
    
    
    
    
}