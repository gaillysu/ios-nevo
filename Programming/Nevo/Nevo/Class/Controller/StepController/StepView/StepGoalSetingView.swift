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

    //Put all UI operation HomeView inside
    private let mClockTimerView = ClockView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-60, UIScreen.mainScreen().bounds.width-60), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!);//init "ClockView" ,Use the code relative layout
    var progressView:CircleProgressView?
    var progresValue:CGFloat = 0.0
    private var mDelegate:ButtonManagerCallBack!

    var collectionView:UICollectionView?

    func bulidStepGoalView(delegate:ButtonManagerCallBack,navigation:UINavigationItem){
        mDelegate = delegate

        //animationView = AnimationView(frame: self.frame, delegate: delegate)
        mClockTimerView.currentTimer()
        mClockTimerView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2.0, UIScreen.mainScreen().bounds.size.height/2.0)//Using the center property determines the location of the ClockView
        mClockTimerView.frame = CGRectMake(mClockTimerView.frame.origin.x, 45, mClockTimerView.frame.size.width, mClockTimerView.frame.size.height)
        self.addSubview(mClockTimerView)

        progressView = CircleProgressView()
        progressView?.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        progressView?.frame = CGRectMake(mClockTimerView.frame.origin.x-5, mClockTimerView.frame.origin.y-5, UIScreen.mainScreen().bounds.width-50, UIScreen.mainScreen().bounds.width-50)
        progressView?.setProgress(0.0)
        self.layer.addSublayer(progressView!)

        let height:CGFloat = UIScreen.mainScreen().bounds.size.height - (progressView!.frame.size.height + progressView!.frame.origin.y) - 168
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake((UIScreen.mainScreen().bounds.size.width)/3.0, height/2.0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: CGRectMake(0, progressView!.frame.origin.y+progressView!.frame.size.height+10, UIScreen.mainScreen().bounds.size.width, height), collectionViewLayout: layout)
        collectionView?.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView?.backgroundColor = UIColor.whiteColor()
        self.addSubview(collectionView!)

    }

    func getClockTimerView() -> ClockView {
        return mClockTimerView
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
