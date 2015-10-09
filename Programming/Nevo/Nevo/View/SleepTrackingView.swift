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

    var progressView:CircleSleepProgressView?
    var progresValue:CGFloat = 0.0
    var animationView:AnimationView!
    var historyButton:UIButton?

    private var mDelegate:ButtonManagerCallBack!

    func bulidHomeView(delegate:ButtonManagerCallBack) {
        mDelegate = delegate
        animationView = AnimationView(frame: self.frame, delegate: delegate)

        title.textColor = UIColor.whiteColor()
        title.text = NSLocalizedString("SLEEP_TITLE", comment: "")
        title.font = AppTheme.SYSTEMFONTOFSIZE(mSize: 20)
        title.textAlignment = NSTextAlignment.Center

        mClockTimerView.currentTimer()
        self.addSubview(mClockTimerView)
        mClockTimerView.center = CGPointMake(self.frame.width/2.0, self.frame.height/2.0)//Using the center property determines the location of the ClockView

        progressView = CircleSleepProgressView()
        progressView?.frame = CGRectMake(mClockTimerView.frame.origin.x-5, mClockTimerView.frame.origin.y-5, UIScreen.mainScreen().bounds.width-50, UIScreen.mainScreen().bounds.width-50)
        self.layer.addSublayer(progressView!)

        historyButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width-70, titleBgView.frame.size.height+20, 50, 50))
        //sleep_history_icon
        historyButton?.setImage(UIImage(named: "sleep_history_icon"), forState: UIControlState.Normal)
        historyButton?.setImage(UIImage(named: "sleep_history_icon"), forState: UIControlState.Highlighted)
        //historyButton?.setTitle("Sleep History", forState: UIControlState.Normal)
        historyButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        historyButton?.addTarget(self, action: Selector("ButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(historyButton!)

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
    func setProgress(dailySleep:NSArray){
        //progressView?.setProgress(progresValue, Steps: dailySteps, GoalStep: dailyStepGoal)
        progressView?.setSleepProgress(dailySleep)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
