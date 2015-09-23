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
        //valueLabel.text = string
        //valueLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 23)
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
        let pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
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
    @IBOutlet weak var nevoWacthImage: UIImageView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!

    private var mDelegate:ButtonManagerCallBack?
    private var tipView:FXBlurView?;
    private var mOTADelegate:NevoOtaController?//OTA for watch version number object
    private var OTAprogressView:OTAProgress?//OTA upgrade progress bar object
    var progresValue:CGFloat = 0.0//OTA upgrade progress bar default value
    var ReUpgradeButton:UIButton?
    
    func buildView(delegate:ButtonManagerCallBack,otacontroller:AnyObject) {

        title.text = NSLocalizedString("Firmware Upgrade", comment:"")

        nevoWacthImage.contentMode = UIViewContentMode.ScaleAspectFit

        if(mDelegate == nil){
            mDelegate = delegate
            //let tipButton:UIButton = UIButton.buttonWithType(UIButtonType.InfoDark) as! UIButton
            //tipButton.frame = CGRectMake(self.frame.size.width-50, 90, 50, 50)
            //tipButton.addTarget(self, action: Selector("tipAction:"), forControlEvents: UIControlEvents.TouchUpInside)
            //self.addSubview(tipButton)

            if(AppTheme.GET_IS_iPhone4S()){
                var frame:CGRect;
                frame = nevoWacthImage.frame;
                frame.size.height = nevoWacthImage.frame.height+10
                nevoWacthImage.frame = frame;
                
                frame = taskLabel.frame
                frame.origin.y = nevoWacthImage.frame.origin.y+nevoWacthImage.frame.size.height
                taskLabel.frame = frame

                frame = warningLabel.frame
                frame.origin.y = taskLabel.frame.origin.y+taskLabel.frame.size.height+5
                warningLabel.frame = frame

                frame = messageLabel.frame
                frame.origin.y = warningLabel.frame.origin.y+warningLabel.frame.size.height
                messageLabel.frame = frame
            }

            warningLabel.text = NSLocalizedString("Attention!",comment:"")
            warningLabel.font = AppTheme.FONT_RALEWAY_BOLD(mSize: 20)

            messageLabel.backgroundColor = UIColor.clearColor()
            messageLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
            messageLabel.numberOfLines = 0;
            messageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.text = String(format: "%@",NSLocalizedString("otahelp",comment:""))

            OTAprogressView = OTAProgress()
            OTAprogressView?.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
            OTAprogressView?.frame = CGRectMake(nevoWacthImage.frame.origin.x, nevoWacthImage.frame.origin.y, nevoWacthImage.frame.size.width, nevoWacthImage.frame.size.height)
            OTAprogressView?.setProgress(progresValue)
            self.layer.addSublayer(OTAprogressView!)

            ReUpgradeButton = UIButton(type:UIButtonType.Custom)
            ReUpgradeButton!.frame = CGRectMake(0, 0, 120, 40)
            ReUpgradeButton!.setTitle(NSLocalizedString("Upgrade", comment: ""), forState: UIControlState.Normal)
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

        let messageS:String  = String(format: "%@",NSLocalizedString("otahelp",comment:""))
        let labelframe:CGRect  = AppTheme.getLabelSize(messageS, andObject: messageLabel.frame,andFont: AppTheme.FONT_RALEWAY_LIGHT(mSize: 16))
        var labelSize:CGRect = labelframe;
        labelSize.size.height = labelframe.size.height;
        messageLabel.frame = labelSize

        ReUpgradeButton!.center = CGPointMake(self.frame.size.width/2.0, messageLabel!.frame.size.height+messageLabel!.frame.origin.y+30)

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

    /**
    Set the OTA upgrade progress value

    :param: progress Progress value
    */
    func setProgress(progress: Float,currentTask:NSInteger,allTask:NSInteger){
        progresValue = CGFloat(progress)
        OTAprogressView?.setProgress(progresValue)
        taskLabel.text = NSString(format: "%.0f%c \(currentTask)/\(allTask)", Float(progresValue)*100.0,37) as String
    }

    /**
    Is the latest edition of the display function

    :param: string
    */
    func setLatestVersion(string:String){
        let messageS:String  = string
        taskLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
        let labelframe:CGRect  = AppTheme.getWidthLabelSize(messageS, andObject: taskLabel.frame,andFont: AppTheme.FONT_RALEWAY_LIGHT(mSize: 15))
        taskLabel.frame = labelframe
        taskLabel.text = string
    }

    /**
    Upgrade success callback function
    */
    func upgradeSuccessful(){
        ReUpgradeButton?.hidden = true
        nevoWacthImage.image = AppTheme.GET_RESOURCES_IMAGE("nevo_wacth_selected");
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
