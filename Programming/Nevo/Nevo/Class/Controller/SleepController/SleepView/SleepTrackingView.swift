//
//  SleepTrackingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/10/6.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SleepTrackingView: UIView {

    @IBOutlet weak var clockBackGroundView: UIView!
    @IBOutlet weak var collectionView:UICollectionView!

    private var mDelegate:ButtonManagerCallBack?
    //Put all UI operation HomeView inside
    private var mClockTimerView:ClockView?;//init "ClockView" ,Use the code relative layout
    var progressView:CircleSleepProgressView?
    var progresValue:CGFloat = 0.0

    func bulidHomeView(delegate:ButtonManagerCallBack) {
        self.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 25, Green: 31, Blue: 59)

        if(mDelegate == nil) {
            mDelegate = delegate
            mClockTimerView = ClockView(frame:CGRectMake(0, 0, clockBackGroundView.bounds.width, clockBackGroundView.bounds.width), hourImage:  AppTheme.GET_RESOURCES_IMAGE("white_hour"), minuteImage: AppTheme.GET_RESOURCES_IMAGE("white_minute"), dialImage: AppTheme.GET_RESOURCES_IMAGE("white_clock"))
            mClockTimerView?.currentTimer()
            clockBackGroundView.addSubview(mClockTimerView!)

            progressView = CircleSleepProgressView()
            progressView?.frame = CGRectMake(clockBackGroundView.frame.origin.x-3, clockBackGroundView.frame.origin.y-3, clockBackGroundView.bounds.width+6, clockBackGroundView.bounds.width+6)
            self.layer.addSublayer(progressView!)

            let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.itemSize = CGSizeMake((UIScreen.mainScreen().bounds.size.width)/3.0, collectionView.frame.size.height/2.0)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            collectionView.collectionViewLayout = layout
            collectionView?.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "SleepCollectionViewCell")
            collectionView?.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 25, Green: 31, Blue: 59)
        }
    }


    func getClockTimerView() -> ClockView {
        return mClockTimerView!
    }

    @IBAction func ButtonAction(sender: AnyObject) {
        mDelegate?.controllManager(sender)
    }

    /**
    set the progress of the progressView

    :param: progress
    :param: animated
    */
    func setProgress(dailySleep:NSArray,resulSleep:((dataSleep:Sleep) -> Void)){
        //progressView?.setProgress(progresValue, Steps: dailySteps, GoalStep: dailyStepGoal)
        progressView?.setSleepProgress(dailySleep, resulSleep: { (dataSleep) -> Void in
            resulSleep(dataSleep: dataSleep)
        })
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
