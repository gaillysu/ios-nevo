//
//  SleepTrackingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/10/6.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SleepTrackingView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var titleBgView: UIView!
    //Put all UI operation HomeView inside
    private let mClockTimerView = ClockView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-60, UIScreen.mainScreen().bounds.width-60), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!);//init "ClockView" ,Use the code relative layout

    var progressView:CircleProgressView?
    var progresValue:CGFloat = 0.0
    var animationView:AnimationView!
    var pushButton:UIButton?

    private var mDelegate:ButtonManagerCallBack!

    func bulidHomeView(delegate:ButtonManagerCallBack) {
        mDelegate = delegate
        animationView = AnimationView(frame: self.frame, delegate: delegate)

        title.textColor = UIColor.whiteColor()
        title.text = NSLocalizedString("SleepTracking", comment: "")
        title.font = AppTheme.SYSTEMFONTOFSIZE()
        title.textAlignment = NSTextAlignment.Center

        mClockTimerView.currentTimer()
        self.addSubview(mClockTimerView)
        mClockTimerView.center = CGPointMake(self.frame.width/2.0, self.frame.height/2.0)//Using the center property determines the location of the ClockView

        progressView = CircleProgressView()
        progressView?.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        progressView?.frame = CGRectMake(mClockTimerView.frame.origin.x-5, mClockTimerView.frame.origin.y-5, UIScreen.mainScreen().bounds.width-50, UIScreen.mainScreen().bounds.width-50)
        progressView?.setProgress(progresValue)
        self.layer.addSublayer(progressView!)

        pushButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width-130, titleBgView.frame.size.height, 120, 45))
        pushButton?.setTitle("Sleep History", forState: UIControlState.Normal)
        pushButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        pushButton?.addTarget(self, action: Selector("ButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(pushButton!)

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

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
