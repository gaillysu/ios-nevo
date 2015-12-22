//
//  TutorialScanPageView.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 9/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

class TutorialScanPageView : UIView {
    private var mDelegate:Page4Controller?

    let BACKGROUND_COLOR:UIColor = UIColor(red: 244.0/255.0, green: 242.0/255.0, blue: 241.0/255.0, alpha: 1)

    let TEXT_FONT:UIFont = UIFont(name:"Raleway-Light", size: 23)!
    let BUTTON_FONT:UIFont = UIFont(name:"Raleway-Light", size: 25)!

    let BACK_BUTTON_FONT:UIFont = UIFont(name:"Raleway-Light", size: 20)!
    
    private var mBackButton:UIButton?

    private var mConnectButton:UIButton?
    private var mErrorLabel:UILabel?
    private var mFinishButton:UIButton?
    private var connectImage:UIImageView?

    init(frame: CGRect, delegate:UIViewController) {
        super.init(frame: frame)
        super.backgroundColor = BACKGROUND_COLOR
        if let callBackDelgate = delegate as? Page4Controller {

            mDelegate = callBackDelgate
        }
        buildTutorialPage()

    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        buildTutorialPage()
    }

    func buildTutorialPage() {

        let backButton = UIButton(type:UIButtonType.Custom)
        backButton.frame = CGRectMake(15, 10, 70, 40)
        backButton.setTitle(NSLocalizedString("Back",comment:"button title string"), forState: UIControlState.Normal)
        backButton.titleLabel?.font = BACK_BUTTON_FONT
        backButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backButton)
        
        mBackButton = backButton

        let guideImage:UIImageView = UIImageView(image: UIImage(named: String("step4" as NSString)))
        guideImage.frame = CGRectMake(0, 0, self.frame.size.width-70, 100)
        guideImage.center = CGPointMake(self.frame.size.width/2.0, 100)
        guideImage.contentMode = UIViewContentMode.ScaleAspectFit
        guideImage.userInteractionEnabled = true;
        guideImage.backgroundColor = UIColor.clearColor()
        self.addSubview(guideImage)

        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, guideImage.frame.size.width, 60))
        titleLabel.center = CGPointMake(self.frame.size.width/2.0, guideImage.frame.origin.y+guideImage.frame.size.height+30)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        titleLabel.font = TEXT_FONT
        titleLabel.text = NSLocalizedString("ConnectButton",comment:"lable string")
        self.addSubview(titleLabel)


        connectImage = UIImageView(frame: CGRectMake(0, 0, 150, 150))
        connectImage?.image = UIImage(named:"connect")
        connectImage?.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0+50)
        self.addSubview(connectImage!)

        mConnectButton = UIButton(frame: CGRectMake(0, 0, 150, 150))
        mConnectButton?.setTitle( NSLocalizedString("Connect",comment:"lable string"), forState: UIControlState.Normal)
        mConnectButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        mConnectButton?.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0+50)
        mConnectButton?.contentMode = UIViewContentMode.ScaleAspectFit
        mConnectButton?.backgroundColor = UIColor.clearColor()
        mConnectButton?.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(mConnectButton!)


        mFinishButton = UIButton(frame: CGRectMake(0, 0, 120, 50))
        mFinishButton?.setTitle(NSLocalizedString("Next",comment:"lable string"), forState: UIControlState.Normal)
        mFinishButton?.titleLabel?.font = BUTTON_FONT
        mFinishButton?.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Normal)
        if AppTheme.GET_IS_iPhone4S() {
            mFinishButton?.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-25)
        }else {
            mFinishButton?.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-50)
        }
        mFinishButton?.hidden = true
        mFinishButton?.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(mFinishButton!)

        let errorLabel = UILabel(frame: CGRectMake(0, 0, titleLabel.frame.size.width, 90))
        if AppTheme.GET_IS_iPhone4S(){
            errorLabel.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-80)
        }else {
            errorLabel.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-110)
        }

        errorLabel.textAlignment = NSTextAlignment.Center
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        errorLabel.font = TEXT_FONT
        errorLabel.text = NSLocalizedString("PlaceConnect",comment:"lable string")
        self.addSubview(errorLabel)
        
        mErrorLabel = errorLabel

    }

    func buttonAnimation(sender:UIImageView) {
        let rotationAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(double: M_PI * 2.0);
        rotationAnimation.duration = 1;
        rotationAnimation.cumulative = true;
        rotationAnimation.repeatCount = 10;
        rotationAnimation.delegate = self
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.removedOnCompletion = false
        sender.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }

    func stopButtonAnimation(sender:UIImageView) {
        sender.layer.removeAnimationForKey("rotationAnimation")
    }

    /**
    * 动画开始时
    */
    override func animationDidStart(theAnimation:CAAnimation){
        mConnectButton?.enabled = false
        mConnectButton?.setTitleColor(AppTheme.NEVO_SOLAR_GRAY(), forState: UIControlState.Normal)
    }

    /**
    * 动画结束时
    */
    override func animationDidStop(theAnimation:CAAnimation ,finished:Bool){
        mConnectButton?.enabled = true
        mConnectButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }
    /*
    Connect the Success to empty some pictures don't need the button and the label text
    */
    func connectSuccessClean() {
        connectImage?.image = UIImage(named:"success")
        if mConnectButton != nil {
            stopButtonAnimation(connectImage!)
        }
        mConnectButton?.hidden = true
        mErrorLabel?.hidden = true
        mFinishButton?.hidden = false
    }
    
    /*
    Button Event handling all returns in the controller
    */
    func ButtonAction(sender:UIButton){
        //If the finish button is visible, we shouldn't be able to rotate the figure
        if sender.isEqual(mConnectButton) {
            buttonAnimation(connectImage!)
        }
        mDelegate?.nextButtonAction(sender)
    }
    
    func getBackButton() -> UIButton? {
        return mBackButton
    }
    
    func getConnectButton() -> UIButton? {
        return mConnectButton
    }
    
}