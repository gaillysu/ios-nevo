//
//  NevoOtaView.swift
//  Nevo
//
//  Created by ideas on 15/3/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class OTAProgress: CAShapeLayer {

    private let progressLimit:CGFloat = 1.0 //The overall progress of the progress bar
    private var progress:CGFloat = 0 //The progress bar target schedule
    private var percent:CGFloat {
        //Calculating the percentage of the current value
        return CGFloat(calculatePercent(progress, toProgress: progressLimit))
    }
    private var initialProgress:CGFloat!
    private var progressLayer:CAShapeLayer! //The progress bar object
    private var progressColor:UIColor = UIColor.greenColor() //The background color of the progress bar

    private var valueLabel:UILabel!


    override init(){
        super.init()
        self.path = drawPathWithArcCenter()
        self.fillColor = UIColor.clearColor().CGColor
        self.strokeColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 0.4).CGColor
        self.lineWidth = 5

        progressLayer = CAShapeLayer()
        progressLayer.path = drawPathWithArcCenter()
        progressLayer.fillColor = UIColor.clearColor().CGColor
        progressLayer.strokeColor = progressColor.CGColor
        progressLayer.lineWidth = 5

        self.addSublayer(progressLayer)

        valueLabel = UILabel(frame: CGRectMake(0, 0, 170, 100))
        //valueLabel.backgroundColor = UIColor.greenColor()
        valueLabel.textAlignment = NSTextAlignment.Center
        valueLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 50)
        valueLabel.numberOfLines = 0
        valueLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.addSublayer(valueLabel.layer)

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
    func setProgress(Sprogress:CGFloat) {
        valueLabel.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0)
        valueLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 50)
        valueLabel.text = NSString(format: "%.0f%c", Float(Sprogress)*100.0,37) as String

        initialProgress = CGFloat(calculatePercent(progress, toProgress: progressLimit))
        progress = Sprogress

        self.progressLayer.strokeEnd = self.percent
        startAnimation();
    }

    /**
    Is the latest edition of the display function

    :param: string
    */
    func setLatestVersion(string:String){
        valueLabel.text = string
        valueLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 23)
    }

    /**
    Upgrade success callback function
    */
    func upgradeSuccessful(){
        valueLabel.text = ""
        let successImage:UIImageView = UIImageView(image: UIImage(named: "success"))
        successImage.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0)
        self.addSublayer(successImage.layer)
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

class NevoOtaView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var titleBgView: UIView!
    
    @IBOutlet weak var backButton: UIButton!

    private var mDelegate:ButtonManagerCallBack?
    private var tipView:FXBlurView?;
    private var mOTADelegate:NevoOtaController?//OTA for watch version number object
    private var watchVersion:UILabel?//Display watch MCU and BLE version number
    private var OTAprogressView:OTAProgress?//OTA upgrade progress bar object
    var progresValue:CGFloat = 0.0//OTA upgrade progress bar default value
    var ReUpgradeButton:UIButton?
    
    func buildView(delegate:ButtonManagerCallBack,otacontroller:NevoOtaController) {
        mDelegate = delegate
        mOTADelegate = otacontroller

        title.text = NSLocalizedString("Firmware Upgrade", comment:"")

        watchVersion = UILabel(frame: CGRectMake(0, 90, 150, 50))
        watchVersion!.numberOfLines = 0
        watchVersion!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        watchVersion!.textAlignment = NSTextAlignment.Left
        watchVersion!.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
        self.addSubview(watchVersion!)
        self.setVersionLbael(mOTADelegate!.getSoftwareVersion(), bleNumber: mOTADelegate!.getFirmwareVersion())

        let tipButton:UIButton = UIButton.buttonWithType(UIButtonType.InfoDark) as! UIButton
        tipButton.frame = CGRectMake(self.frame.size.width-50, 90, 50, 50)
        tipButton.addTarget(self, action: Selector("tipAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(tipButton)

        OTAprogressView = OTAProgress()
        OTAprogressView?.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        OTAprogressView?.frame = CGRectMake(UIScreen.mainScreen().bounds.width/2.0-(UIScreen.mainScreen().bounds.width-50)/2.0, watchVersion!.frame.origin.y+60, UIScreen.mainScreen().bounds.width-50, UIScreen.mainScreen().bounds.width-50)
        OTAprogressView?.setProgress(progresValue)
        self.layer.addSublayer(OTAprogressView)

        ReUpgradeButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        ReUpgradeButton!.frame = CGRectMake(0, 0, 120, 40)
        ReUpgradeButton!.center = CGPointMake(self.frame.size.width/2.0, OTAprogressView!.frame.size.height+OTAprogressView!.frame.origin.y+40)
        ReUpgradeButton!.setTitle(NSLocalizedString("Re-Upgrade", comment: ""), forState: UIControlState.Normal)
        ReUpgradeButton!.titleLabel?.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
        ReUpgradeButton!.backgroundColor = UIColor.clearColor()
        ReUpgradeButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        ReUpgradeButton!.addTarget(self, action: Selector("buttonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        ReUpgradeButton!.layer.masksToBounds = true
        ReUpgradeButton!.layer.cornerRadius = 20.0
        ReUpgradeButton!.layer.borderWidth = 2;//边框宽度
        ReUpgradeButton!.layer.borderColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
        self.addSubview(ReUpgradeButton!)
    }

    @IBAction func buttonAction(sender: AnyObject) {
        mDelegate?.controllManager(sender)
    }

    func tipAction(sender:UIButton){
        if(sender.tag==5200){
            self.closeTipView()
        }else{
            self.tipTextView()
        }
    }

    func setVersionLbael(mcuNumber:NSString,bleNumber:NSString){
        watchVersion!.text = String(format: "Mcu %@%@\n BLE %@%@",NSLocalizedString("Version:",comment:""), mcuNumber,NSLocalizedString("Version:",comment:""),bleNumber)
    }

    /**
    Set the OTA upgrade progress value

    :param: progress Progress value
    */
    func setProgress(progress: Float){
        progresValue = CGFloat(progress)
        OTAprogressView?.setProgress(progresValue)
    }

    /**
    Is the latest edition of the display function

    :param: string
    */
    func setLatestVersion(string:String){
        OTAprogressView?.setLatestVersion(string)
    }

    /**
    Upgrade success callback function
    */
    func upgradeSuccessful(){
        OTAprogressView?.upgradeSuccessful()
    }

    /**
    Prevent OTA disconnect tip
    */
    func tipTextView(){
        tipView = FXBlurView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        tipView!.dynamic = false
        tipView!.blurRadius = 12
        tipView!.contentMode = UIViewContentMode.Bottom;
        tipView!.tintColor = UIColor.clearColor()
        self.addSubview(tipView!)

        let cancelTip:UIButton = UIButton(frame: CGRectMake(self.frame.size.width-60, 0, 45, 45))
        cancelTip.setImage(UIImage(named: "cancelicon"), forState: UIControlState.Normal)
        cancelTip.addTarget(self, action: Selector("tipAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        cancelTip.tag = 5200
        tipView!.addSubview(cancelTip)

        let textView:UITextView = UITextView(frame: CGRectMake(5, 30, self.frame.size.width-10, 250))
        textView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0)
        textView.editable = false
        textView.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 18)
        textView.textAlignment = NSTextAlignment.Center
        textView.backgroundColor = UIColor.clearColor()
        textView.text = NSLocalizedString("otahelp",comment:"")
        tipView!.addSubview(textView)

        let attentionLabel:UILabel = UILabel(frame: CGRectMake(0, textView.frame.origin.y-40, self.frame.size.width, 40))
        attentionLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 30)
        attentionLabel.backgroundColor = UIColor.clearColor()
        attentionLabel.textAlignment = NSTextAlignment.Center
        attentionLabel.text = NSLocalizedString("Attention!", comment: "")
        tipView!.addSubview(attentionLabel)

        tipView!.updateAsynchronously(true, completion: { () -> Void in
            self.tipView!.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
            self.tipView!.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0)
        })

        let popAnimation:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
        popAnimation.duration = 0.4;
        popAnimation.values = [NSValue(CATransform3D: CATransform3DMakeScale(0.01, 0.01, 1.0)),NSValue(CATransform3D: CATransform3DMakeScale(1.1, 1.1, 1.0)),NSValue(CATransform3D: CATransform3DMakeScale(0.9, 0.9, 1.0)),NSValue(CATransform3D: CATransform3DIdentity)]
        popAnimation.keyTimes = [0.2, 0.5, 0.75, 1.0];
        popAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        tipView!.layer.addAnimation(popAnimation , forKey: "")
    }

    /**
    Close the OTA attention function
    */
    func closeTipView(){
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.tipView!.transform = CGAffineTransformMakeScale(0.05, 0.05);
        }) { (Bool) -> Void in
            self.tipView!.removeFromSuperview()
        }

    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
