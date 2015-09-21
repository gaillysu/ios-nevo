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
    private let mClockTimerView = ClockView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-80, UIScreen.mainScreen().bounds.width-80), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!);//init "ClockView" ,Use the code relative layout

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
        mClockTimerView.center = CGPointMake(self.frame.width/2.0, 64+mClockTimerView.frame.size.height/2 + 30)//Using the center property determines the location of the ClockView

        progressView = CircleProgressView()
        progressView?.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        progressView?.frame = CGRectMake(mClockTimerView.frame.origin.x-5, mClockTimerView.frame.origin.y-5, UIScreen.mainScreen().bounds.width-70, UIScreen.mainScreen().bounds.width-70)
        progressView?.setProgress(progresValue)
        self.layer.addSublayer(progressView!)

        let tabbarView:UIView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 50))
        tabbarView.backgroundColor = UIColor.clearColor()
        //AppTheme.NEVO_CUSTOM_COLOR(Red: 242, Green: 242, Blue: 242)
        tabbarView.center = CGPointMake(UIScreen.mainScreen().bounds.width/2.0, UIScreen.mainScreen().bounds.height-tabbarView.frame.size.height/2)
        self.addSubview(tabbarView)

        let historyBt:UIButton = UIButton(type: UIButtonType.Custom)
        historyBt.frame = CGRectMake(0, 0, 120, 40)
        historyBt.layer.masksToBounds = true
        historyBt.layer.cornerRadius = 5
        historyBt.center = CGPointMake(tabbarView.frame.size.width/2.0, tabbarView.frame.size.height/2.0)
        historyBt.setTitle("History", forState: UIControlState.Normal)
        historyBt.titleLabel?.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 23)
        historyBt.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW()
        tabbarView.addSubview(historyBt)

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