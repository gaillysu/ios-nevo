//
//  AnimationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/5.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit


protocol ButtonManagerCallBack {

    func controllManager(sender:AnyObject)
    
}

class AnimationView: UIView {

    private var mNoConnectionView:UIView?
    private var mNoConnectImage:UIImageView?
    private var mNoConnectScanButton:UIButton?
    let PICKER_BG_COLOR = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)//pickerView background color
    let BUTTONBGVIEW_COLOR = UIColor(red: 244/255.0, green: 242/255.0, blue: 241/255.0, alpha: 1)//View button background color
    let NO_CONNECT_VIEW:Int = 1200

    private var mDelegate:ButtonManagerCallBack!

    init(frame: CGRect,delegate:ButtonManagerCallBack) {
        super.init(frame: frame)
        mDelegate = delegate

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bulibNoConnectView()->UIView{
        if mNoConnectionView==nil {
            mNoConnectionView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
            mNoConnectionView?.backgroundColor = PICKER_BG_COLOR
            mNoConnectionView?.tag = NO_CONNECT_VIEW
            self.addSubview(mNoConnectionView!)

            let message:UILabel = UILabel(frame: CGRectMake(0, 0, 300, 90))
            message.center = CGPointMake(self.frame.size.width/2, mNoConnectionView!.frame.size.height/2.0-120)
            message.text = NSLocalizedString("nevoConnected", comment: "")
            message.numberOfLines = 0
            message.lineBreakMode = NSLineBreakMode.ByWordWrapping
            message.textAlignment = NSTextAlignment.Center
            message.textColor = UIColor.blackColor()
            mNoConnectionView?.addSubview(message)

            mNoConnectImage = UIImageView(frame: CGRectMake(0, 0, 160, 160))
            mNoConnectImage?.image = UIImage(named: "connect")
            mNoConnectImage?.center = CGPointMake(mNoConnectionView!.frame.size.width/2.0, mNoConnectionView!.frame.size.height/2.0)
            mNoConnectImage?.backgroundColor = UIColor.clearColor()
            mNoConnectionView?.addSubview(mNoConnectImage!)

            mNoConnectScanButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
            mNoConnectScanButton?.frame = CGRectMake(0, 0, 160, 160)
            mNoConnectScanButton?.center = CGPointMake(mNoConnectionView!.frame.size.width/2.0, mNoConnectionView!.frame.size.height/2.0)
            mNoConnectScanButton?.setTitle(NSLocalizedString("Connect", comment: ""), forState: UIControlState.Normal)
            mNoConnectScanButton?.backgroundColor = UIColor.clearColor()
            mNoConnectScanButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            mNoConnectScanButton?.addTarget(self, action: Selector("noConnectButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
            mNoConnectionView?.addSubview(mNoConnectScanButton!)

            let message2:UILabel = UILabel(frame: CGRectMake(0, 0, 300, 90))
            message2.center = CGPointMake(self.frame.size.width/2, mNoConnectionView!.frame.size.height/2.0+120)
            message2.text = NSLocalizedString("pushHoldButton", comment: "")
            message2.numberOfLines = 0
            message2.lineBreakMode = NSLineBreakMode.ByWordWrapping
            message2.textAlignment = NSTextAlignment.Center
            message2.textColor = UIColor.blackColor()
            mNoConnectionView?.addSubview(message2)

        } else {

            if let noConnect:UIView = mNoConnectionView {
                UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.LayoutSubviews, animations: { () -> Void in

                    noConnect.alpha = 1;

                    }) { (Bool) -> Void in
                        noConnect.hidden=false
                }
            }
        }
        return mNoConnectionView!
    }

    func noConnectButtonAction(sender:UIButton){
        //forgot the address to reconnect
        NSLog("noConnectScanButton")
        NSLog("forgot the watch address before \(NSUserDefaults.standardUserDefaults().objectForKey(ConnectionControllerImpl.Const.SAVED_ADDRESS_KEY))")
        NSUserDefaults.standardUserDefaults().removeObjectForKey(ConnectionControllerImpl.Const.SAVED_ADDRESS_KEY)
        //CallBack StepGoalSetingController
        mDelegate?.controllManager(sender as UIButton)
    }
    
    func RotatingAnimationObject(sender:UIImageView) {

        var rotationAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(double: M_PI * 2.0);
        rotationAnimation.duration = 1;
        rotationAnimation.cumulative = true;
        rotationAnimation.repeatCount = 10;
        rotationAnimation.delegate = self
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.removedOnCompletion = false
        sender.layer.addAnimation(rotationAnimation, forKey: "NoButtonRotationAnimation")
    }

    func endConnectRemoveView() {

        if let noConnect:UIView = mNoConnectionView {
            UIView.animateKeyframesWithDuration(0.5, delay: 0, options: UIViewKeyframeAnimationOptions.LayoutSubviews, animations: { () -> Void in

                noConnect.alpha = 0;

                }) { (Bool) -> Void in
                    noConnect.hidden=true
            }
        }
    }

    /**
    * Animation Start
    */
    override func animationDidStart(theAnimation:CAAnimation)
    {
        NSLog("begin");
        mNoConnectScanButton?.enabled = false
        mNoConnectScanButton?.setTitleColor(AppTheme.NEVO_SOLAR_GRAY(), forState: UIControlState.Normal)
    }

    /**
    * Animation Stop
    */
    override func animationDidStop(theAnimation:CAAnimation ,finished:Bool){
        NSLog("end");
        mNoConnectScanButton?.enabled = true
        mNoConnectScanButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }

    func getNoConnectScanButton() -> UIButton? {
        return mNoConnectScanButton
    }

    func getNoConnectImage() -> UIImageView? {
        return mNoConnectImage
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

class CircleProgressView: CAShapeLayer {

    private let progressLimit:CGFloat = 1.0 //The overall progress of the progress bar
    private var progress:CGFloat = 0 //The progress bar target schedule
    private var percent:CGFloat {
        //Calculating the percentage of the current value
        return CGFloat(calculatePercent(progress, toProgress: progressLimit))
    }
    private var initialProgress:CGFloat!
    private var progressLayer:CAShapeLayer! //The progress bar object
    private var progressColor:UIColor = UIColor.greenColor() //The background color of the progress bar

    
    private var array:NSMutableArray!


    override init(){
        super.init()
        array = NSMutableArray()
        //self.path = drawPathWithArcCenter()
        self.fillColor = UIColor.clearColor().CGColor
        //self.strokeColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 0.4).CGColor
        //self.lineWidth = 5

        progressLayer = CAShapeLayer()
        progressLayer.path = drawPathWithArcCenter()
        progressLayer.fillColor = UIColor.clearColor().CGColor
        progressLayer.strokeColor = progressColor.CGColor
        progressLayer.lineWidth = 5

        self.addSublayer(progressLayer)

        for var index:Int = 0; index < 2; index++ {
            let valueLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 120, 25))
            //valueLabel.backgroundColor = UIColor.greenColor()
            valueLabel.textAlignment = NSTextAlignment.Center
            valueLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
            valueLabel.tag = index
            self.addSublayer(valueLabel.layer)
            array?.addObject(valueLabel)
        }

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
    private func DegreesToRadians(degrees:CGFloat) -> CGFloat {

        return (degrees * CGFloat(M_PI))/180.0;
    }
    
    /**
    The progress path function

    :returns: Returns the drawing need path
    */
    func drawPathWithArcCenter()->CGPathRef{
        let position_y:CGFloat = self.frame.size.height/2.0
        let position_x:CGFloat = self.frame.size.width/2.0
        let path:CGPathRef = UIBezierPath(arcCenter: CGPointMake(position_x, position_y), radius: position_y, startAngle: CGFloat(-M_PI/90), endAngle: CGFloat(4*M_PI/2), clockwise: true).CGPath
        return path
    }

    /**
    Set progress function

    :param: Sprogress You need to set up the current progress
    */
    func setProgress(Sprogress:CGFloat,Steps steps:Int = 0,GoalStep goalstep:Int = 0) {
        for layer in array {
            let valueLabel:UILabel = layer as! UILabel
            if (valueLabel.tag == 0) {
                valueLabel.center = CGPointMake(self.frame.size.width/2.0-valueLabel.frame.size.width/2-10, self.frame.size.height+30)
                valueLabel.text = NSString(format: "%@%.1f%c", NSLocalizedString("Progress: ",comment: ""),Float(Sprogress)*100.0,37) as String
            }else if (valueLabel.tag == 1) {
                valueLabel.center = CGPointMake(self.frame.size.width/2.0+valueLabel.frame.size.width/2+10, self.frame.size.height+30)
                valueLabel.text = String(format:"%@\(steps)",NSLocalizedString("Step: ",comment: ""))
            }
        }

        initialProgress = CGFloat(calculatePercent(progress, toProgress: progressLimit))
        progress = Sprogress

        self.progressLayer.strokeEnd = self.percent
        startAnimation();
    }

    /**
    Set the background color of the progress bar

    :param: mProgressColor The current progress
    */
    func setProgressColor(mProgressColor:UIColor) {
        progressColor = mProgressColor
        self.progressLayer.strokeColor = progressColor.CGColor;
    }

    private func calculatePercent(fromProgress:CGFloat,toProgress:CGFloat)->Double {
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
    private func startAnimation() {
        var pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 1.0
        pathAnimation.fromValue = initialProgress;
        pathAnimation.toValue = percent;
        pathAnimation.removedOnCompletion = true;
        progressLayer.addAnimation(pathAnimation, forKey: nil)
    }
}
