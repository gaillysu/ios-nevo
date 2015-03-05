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
        mNoConnectScanButton?.setTitle(NSLocalizedString(" ", comment: ""), forState: UIControlState.Normal)
    }

    /**
    * Animation Stop
    */
    override func animationDidStop(theAnimation:CAAnimation ,finished:Bool){
        NSLog("end");
        mNoConnectScanButton?.enabled = true
        mNoConnectScanButton?.setTitle(NSLocalizedString("Connect", comment: ""), forState: UIControlState.Normal)
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
