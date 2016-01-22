//
//  StepGoalSetingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

/*
StepGoalSetingView class all button events to follow this protocol
*/
protocol StepGoalButtonActionCallBack {

    func controllManager(sender:UIButton)

}

class StepGoalSetingView: UIView {

    @IBOutlet weak var clockBackGroundView: UIView!
    @IBOutlet weak var collectionView:UICollectionView!

    private var mDelegate:ButtonManagerCallBack!
    //Put all UI operation HomeView inside
    private var mClockTimerView:ClockView?;//init "ClockView" ,Use the code relative layout
    var progressView:CircleProgressView?
    var progresValue:CGFloat = 0.0

    func bulidStepGoalView(delegate:ButtonManagerCallBack,navigation:UINavigationItem){
        //animationView = AnimationView(frame: self.frame, delegate: delegate)

        if(mDelegate == nil) {
            mDelegate = delegate
            mClockTimerView = ClockView(frame:CGRectMake(0, 0, clockBackGroundView.bounds.width, clockBackGroundView.bounds.width), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!)
            mClockTimerView?.currentTimer()
            clockBackGroundView.addSubview(mClockTimerView!)

            progressView = CircleProgressView()
            progressView?.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
            progressView?.frame = CGRectMake(clockBackGroundView.frame.origin.x-3, clockBackGroundView.frame.origin.y-3, clockBackGroundView.bounds.width+6, clockBackGroundView.bounds.width+6)
            progressView?.setProgress(0.0)
            self.layer.addSublayer(progressView!)

            let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.itemSize = CGSizeMake((UIScreen.mainScreen().bounds.size.width)/3.0, collectionView.frame.size.height/2.0)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 1
            collectionView.collectionViewLayout = layout
            collectionView?.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "CollectionViewCell")
            collectionView?.backgroundColor = UIColor.whiteColor()
        }
    }

    func getClockTimerView() -> ClockView {
        return mClockTimerView!
    }

    /*
    Button Action
    */
    @IBAction func buttonAction(sender: AnyObject) {
        //CallBack StepGoalSetingController
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

    // MARK: - toolbarSegmentedDelegate
    func didSelectedSegmentedControl(segment:UISegmentedControl){

    }
}
