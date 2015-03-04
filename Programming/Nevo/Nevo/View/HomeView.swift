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
    
    //a layer for animation
    private var mAnimationLayer:CAShapeLayer = CAShapeLayer()
    //for test the value of ProgressView
    var mTestProgressViewPercent:Double = 0.1
    
    func bulidHomeView() {
        initAnimationLayer()
        
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
    
    /**
    ini the tAnimationLayer
    
    :returns: none
    */
    func initAnimationLayer() {
        mAnimationLayer.fillColor = UIColor.clearColor().CGColor
        mAnimationLayer.strokeColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
//        mAnimationLayer.backgroundColor = UIColor.redColor().CGColor
        mAnimationLayer.lineWidth = 3
        mAnimationLayer.frame = self.frame
        self.layer.addSublayer(mAnimationLayer)
        
        //add a action to test the animation
        var tapAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapActionAnimationLayer"))
        self.addGestureRecognizer(tapAction)
        
    }
    
    /**
    action to draw the AnnularProgressBar
    */
    func tapActionAnimationLayer(){
        mTestProgressViewPercent+=0.1
        NSLog("annular progress bar value is: \(mTestProgressViewPercent)")
        drawAnnularProgressBar(progress: mTestProgressViewPercent)
    }
    
    /**
    draw the AnnularProgressBar
    
    :param: progress percent of the progressView
    */
    func drawAnnularProgressBar(progress:Double = 0) {
        var path = UIBezierPath()
        var rect:CGRect = UIScreen.mainScreen().applicationFrame
        var clockWith = UIScreen.mainScreen().bounds.width - 60
        path.addArcWithCenter(CGPointMake(rect.size.width/2, rect.size.height/2), radius: (clockWith+10)/2, startAngle: 0, endAngle: CGFloat(2*M_PI*progress), clockwise: true)
        mAnimationLayer.path = path.CGPath
        //path.removeAllPoints()
        var bas:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        bas.duration = 1
        bas.delegate = self
        bas.fromValue = 0
        bas.toValue  = 1
        mAnimationLayer.addAnimation(bas, forKey: "key")
    }
}