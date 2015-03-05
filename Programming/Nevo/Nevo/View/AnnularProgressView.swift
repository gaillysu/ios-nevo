//
//  AnnularProgressView.swift
//  Nevo
//
//  Created by ideas on 15/3/5.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

/**
*  a annular progress bar  view to show the progress
*/
class AnnularProgressView: UIView {

    //base layer to show the value before
    var mTrackLayer:CAShapeLayer!
    //aninmation layer
    var mProgressLayer:CAShapeLayer!
    //record the value before
    var mProgressValueBefore:Double = 0
    //for test
    var mTestProgressViewPercent:Double = 0.1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //init base layer
        mTrackLayer = CAShapeLayer()
        mTrackLayer.fillColor = UIColor.clearColor().CGColor
        mTrackLayer.strokeColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
        mTrackLayer.lineWidth = 3
        mTrackLayer.frame = self.frame
        
        //init aninmation layer
        mProgressLayer = CAShapeLayer()
        mProgressLayer.fillColor = UIColor.clearColor().CGColor
        mProgressLayer.strokeColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
        mProgressLayer.lineWidth = 3
        mProgressLayer.frame = self.frame
        
        self.layer.addSublayer(mTrackLayer)
        self.layer.addSublayer(mProgressLayer)
        
    }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
    add a action to test the DrawAnnularProgressBar
    */
    func testDrawAnnularProgressBar(){
        var tapAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapActionAnimationLayer"))
        self.addGestureRecognizer(tapAction)
    }
    
    /**
    test to draw the AnnularProgressBar
    */
    func tapActionAnimationLayer(){
        mTestProgressViewPercent+=0.1
        if mTestProgressViewPercent>1 {
            mTestProgressViewPercent = 0.1
        }
        NSLog("annular progress bar value is: \(mTestProgressViewPercent)")
        drawAnnularProgressBar(progress: mTestProgressViewPercent)
    }
    
    /**
    
    
    :param: progress percent of the progressView
    */
    /**
    draw the AnnularProgressBar
    
    :param: progress progress of the progressView
    :param: duration duration of the animation,default is 1
    */
    func drawAnnularProgressBar(#progress:Double, duration:CFTimeInterval = 1) {
        var progressReal = progress
        if progressReal>1 {
            progressReal = 1
        }
        if mProgressValueBefore>progressReal {
            mProgressValueBefore = 0
        }
        var path = UIBezierPath(),pathBefore = UIBezierPath()
        var rect:CGRect = UIScreen.mainScreen().applicationFrame
        var clockWith = UIScreen.mainScreen().bounds.width - 60
        pathBefore.addArcWithCenter(CGPointMake(rect.size.width/2, rect.size.height/2), radius: (clockWith+10)/2, startAngle: 0, endAngle: CGFloat(2*M_PI*mProgressValueBefore), clockwise: true)
        mTrackLayer.path = pathBefore.CGPath
        
        path.addArcWithCenter(CGPointMake(rect.size.width/2, rect.size.height/2), radius: (clockWith+10)/2, startAngle: CGFloat(2*M_PI*mProgressValueBefore), endAngle: CGFloat(2*M_PI*progressReal), clockwise: true)
        mProgressLayer.path = path.CGPath
        mProgressValueBefore = progressReal

        var bas:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        bas.duration = duration
        bas.delegate = self
        bas.fromValue = 0
        bas.toValue  = 1
        mProgressLayer.addAnimation(bas, forKey: "key")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
