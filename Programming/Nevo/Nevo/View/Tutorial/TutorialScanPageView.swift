//
//  TutorialScanPageView.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 9/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import UIkit

class TutorialScanPageView : UIView {
    private var mDelegate:Page3Controller?

    let BACKGROUND_COLOR:UIColor = UIColor(red: 244.0/255.0, green: 242.0/255.0, blue: 241.0/255.0, alpha: 1)

    let TEXT_FONT:UIFont = UIFont(name:"Raleway-Light", size: 23)!
    let BUTTON_FONT:UIFont = UIFont(name:"Raleway-Light", size: 25)!

    let BACK_BUTTON_FONT:UIFont = UIFont(name:"Raleway-Light", size: 20)!
    
    private var mBackButton:UIButton?

    private var mConnectButton:UIButton?
    private var mErrorLabel:UILabel?
    private var mFinishButton:UIButton?
    private var mOptionIndices:NSMutableIndexSet = NSMutableIndexSet(index: 1)

    init(frame: CGRect, delegate:UIViewController) {
        super.init(frame: frame)
        super.backgroundColor = BACKGROUND_COLOR
        if let callBackDelgate = delegate as? Page3Controller {

            mDelegate = callBackDelgate
        }
        buildTutorialPage()

    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        buildTutorialPage()
    }

    func buildTutorialPage() {

        let backButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        backButton.frame = CGRectMake(15, 10, 60, 40)
        backButton.setTitle(NSLocalizedString("Back",comment:"button title string"), forState: UIControlState.Normal)
        backButton.titleLabel?.font = BACK_BUTTON_FONT
        backButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backButton)
        
        mBackButton = backButton

        let guideImage:UIImageView = UIImageView(image: UIImage(named: String("step3" as NSString)))
        guideImage.frame = CGRectMake(0, 0, self.frame.size.width-70, 100)
        guideImage.center = CGPointMake(self.frame.size.width/2.0, 100)
        guideImage.contentMode = UIViewContentMode.ScaleAspectFit
        guideImage.userInteractionEnabled = true;
        guideImage.backgroundColor = UIColor.clearColor()
        self.addSubview(guideImage)

        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, guideImage.frame.size.width, 50))
        titleLabel.center = CGPointMake(self.frame.size.width/2.0, guideImage.frame.origin.y+guideImage.frame.size.height+30)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        titleLabel.font = TEXT_FONT
        titleLabel.text = NSLocalizedString("ConnectButton",comment:"lable string")
        self.addSubview(titleLabel)


        let connectButton = UIButton(frame: CGRectMake(0, 0, 150, 150))
        connectButton.setBackgroundImage(UIImage(named:"connect"), forState: UIControlState.Normal)
        //connectButton.setTitle( NSLocalizedString("Connect",comment:"lable string"), forState: UIControlState.Normal)
        connectButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        connectButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0+50)
        connectButton.contentMode = UIViewContentMode.ScaleAspectFit
        connectButton.backgroundColor = UIColor.clearColor()
        connectButton.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(connectButton)
        
        mConnectButton = connectButton


        let finishButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        finishButton.frame = CGRectMake(0, 0, 120, 50)
        finishButton.setTitle(NSLocalizedString(NSLocalizedString("Finish",comment:"lable string"),comment:"button title string"), forState: UIControlState.Normal)
        finishButton.titleLabel?.font = BUTTON_FONT
        finishButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Normal)
        finishButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-90)
        finishButton.hidden = true
        finishButton.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(finishButton)
        
        mFinishButton = finishButton

        let errorLabel = UILabel(frame: CGRectMake(0, 0, titleLabel.frame.size.width, 80))
        errorLabel.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-100)
        errorLabel.textAlignment = NSTextAlignment.Center
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        errorLabel.font = TEXT_FONT
        errorLabel.text = NSLocalizedString("PlaceConnect",comment:"lable string")
        self.addSubview(errorLabel)
        
        mErrorLabel = errorLabel

    }

    func buttonAnimation(sender:UIButton) {
        
        //If the finish button is visible, we shouldn't be able to rotate the figure
        if mFinishButton != nil && !( mFinishButton!.hidden ) {
            return;
        }

        var rotationAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(double: M_PI * 2.0);
        rotationAnimation.duration = 1;
        rotationAnimation.cumulative = true;
        rotationAnimation.repeatCount = 10;
        rotationAnimation.delegate = self
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.removedOnCompletion = false
        sender.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }

    func stopButtonAnimation(sender:UIButton) {
        sender.layer.removeAnimationForKey("rotationAnimation")
    }

    /**
    * 动画开始时
    */
    override func animationDidStart(theAnimation:CAAnimation){
        mConnectButton?.enabled = false
    }

    /**
    * 动画结束时
    */
    override func animationDidStop(theAnimation:CAAnimation ,finished:Bool){
        mConnectButton?.enabled = true
    }
    /*
    Connect the Success to empty some pictures don't need the button and the label text
    */
    func connectSuccessClean() {
        mConnectButton?.setBackgroundImage(UIImage(named:"success"), forState: UIControlState.Normal)
        if let connectButton = mConnectButton {
            stopButtonAnimation(connectButton)
        }
        mFinishButton?.hidden = false
        mErrorLabel?.hidden = true
    }
    /*
    Button Event handling all returns in the controller
    */
    func ButtonAction(sender:UIButton){

        buttonAnimation(sender)
        mDelegate?.nextButtonAction(sender)
        
    }
    
    func getBackButton() -> UIButton? {
        return mBackButton
    }
    
    func getConnectButton() -> UIButton? {
        return mConnectButton
    }
    
}