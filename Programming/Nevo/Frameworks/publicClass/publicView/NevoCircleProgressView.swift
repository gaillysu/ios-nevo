//
//  AnimationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/5.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NevoCircleProgressView: CAShapeLayer {

    fileprivate let progressLimit:CGFloat = 1.0 //The overall progress of the progress bar
    fileprivate var progress:CGFloat = 0 //The progress bar target schedule
    fileprivate var percent:CGFloat {
        //Calculating the percentage of the current value
        return CGFloat(calculatePercent(progress, toProgress: progressLimit))
    }
    fileprivate let progressWidth:CGFloat  = 2.0
    fileprivate var initialProgress:CGFloat!
    fileprivate var progressLayer:CAShapeLayer! //The progress bar object
    fileprivate var progressColor:UIColor = UIColor.green //The background color of the progress bar

    override init(){
        super.init()
        //self.path = drawPathWithArcCenter()
        self.fillColor = UIColor.clear.cgColor
        //self.strokeColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 0.4).CGColor
        //self.lineWidth = 5

        progressLayer = CAShapeLayer()
        progressLayer.path = drawPathWithArcCenter()
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = progressWidth

        self.addSublayer(progressLayer)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers() {
        self.path = drawPathWithArcCenter()
        progressLayer.path = drawPathWithArcCenter()
        super.layoutSublayers()
    }

    /*
    Used to calculate the rotate degree
    */
    fileprivate func DegreesToRadians(_ degrees:CGFloat) -> CGFloat {

        return (degrees * CGFloat(M_PI))/180.0;
    }
    
    /**
    The progress path function

    :returns: Returns the drawing need path
    */
    func drawPathWithArcCenter()->CGPath{
        let position_y:CGFloat = self.frame.size.height/2.0
        let position_x:CGFloat = self.frame.size.width/2.0
        let path:CGPath = UIBezierPath(arcCenter: CGPoint(x: position_x, y: position_y), radius: position_y, startAngle: CGFloat(-M_PI/90), endAngle: CGFloat(4*M_PI/2), clockwise: true).cgPath
        return path
    }

    /**
    Set progress function

    :param: Sprogress You need to set up the current progress
    */
    func setProgress(_ Sprogress:CGFloat,Steps steps:Int = 0,GoalStep goalstep:Int = 0) {
        initialProgress = CGFloat(calculatePercent(progress, toProgress: progressLimit))

        progress = Sprogress

        self.progressLayer.strokeEnd = self.percent
        startAnimation();
    }

    /**
    Set the background color of the progress bar

    :param: mProgressColor The current progress
    */
    func setProgressColor(_ mProgressColor:UIColor) {
        progressColor = mProgressColor
        self.progressLayer.strokeColor = progressColor.cgColor;
    }

    fileprivate func calculatePercent(_ fromProgress:CGFloat,toProgress:CGFloat)->Double {
        if ((toProgress > 0) && (fromProgress > 0)) {

            var progress:CGFloat = 0;

            progress = fromProgress / toProgress

            if ((progress * 100) > 100) {
                progress = 1.0;
            }
            return Double(progress);
        }else{

            return 0.0;
        }
    }

    /**
    Implementation of the animation function
    */
    fileprivate func startAnimation() {
        let pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 1.0
        pathAnimation.fromValue = initialProgress;
        pathAnimation.toValue = percent;
        pathAnimation.isRemovedOnCompletion = true;
        progressLayer.add(pathAnimation, forKey: nil)
    }
}
