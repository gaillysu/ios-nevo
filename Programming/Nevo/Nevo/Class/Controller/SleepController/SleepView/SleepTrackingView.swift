//
//  SleepTrackingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/10/6.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SleepTrackingView: UIView {

    //Put all UI operation HomeView inside
    private let mClockTimerView = ClockView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-60, UIScreen.mainScreen().bounds.width-60), hourImage:  UIImage(named: "white_hour")!, minuteImage: UIImage(named: "white_minute")!, dialImage: UIImage(named: "white_clock")!);//init "ClockView" ,Use the code relative layout

    var progressView:CircleSleepProgressView?
    var progresValue:CGFloat = 0.0
    var collectionView:UICollectionView?

    private var mDelegate:ButtonManagerCallBack!

    func bulidHomeView(delegate:ButtonManagerCallBack) {
        mDelegate = delegate

        self.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 25, Green: 31, Blue: 59)
        mClockTimerView.currentTimer()
        self.addSubview(mClockTimerView)
        mClockTimerView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2.0, UIScreen.mainScreen().bounds.size.height/2.0)//Using the center property determines the location of the ClockView
         mClockTimerView.frame = CGRectMake(mClockTimerView.frame.origin.x, 45, mClockTimerView.frame.size.width, mClockTimerView.frame.size.height)

        progressView = CircleSleepProgressView()
        progressView?.frame = CGRectMake(mClockTimerView.frame.origin.x-5, mClockTimerView.frame.origin.y-5, UIScreen.mainScreen().bounds.width-50, UIScreen.mainScreen().bounds.width-50)
        self.layer.addSublayer(progressView!)

        let height:CGFloat = UIScreen.mainScreen().bounds.size.height - (progressView!.frame.size.height + progressView!.frame.origin.y) - 168
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake((UIScreen.mainScreen().bounds.size.width)/3.0, height/2.0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: CGRectMake(0, progressView!.frame.origin.y+progressView!.frame.size.height+10, UIScreen.mainScreen().bounds.size.width, height), collectionViewLayout: layout)
        collectionView?.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "SleepCollectionViewCell")
        collectionView?.backgroundColor = UIColor.clearColor()
        self.addSubview(collectionView!)
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
