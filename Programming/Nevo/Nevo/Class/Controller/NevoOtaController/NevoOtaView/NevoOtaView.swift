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
        self.strokeColor = UIColor.clearColor().CGColor//UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 0.4).CGColor
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
    @IBOutlet weak var nevoWacthImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var progresLabel: UILabel!
    @IBOutlet weak var firmwareLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var updatingView: UIView!


    private var mDelegate:ButtonManagerCallBack?
    private var tipView:FXBlurView?;
    private var mOTADelegate:NevoOtaController?//OTA for watch version number object
    private var OTAprogressView:OTAProgress?//OTA upgrade progress bar object
    var progresValue:CGFloat = 0.0//OTA upgrade progress bar default value
    
    func buildView(delegate:ButtonManagerCallBack,otacontroller:AnyObject) {
        mDelegate = delegate

        backButton.layer.masksToBounds = true
        backButton.layer.cornerRadius = 10.0
        backButton.layer.borderWidth = 1.0
        backButton.layer.borderColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor

        self.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 239.0, Green: 239.0, Blue: 244.0)

        if(OTAprogressView == nil){
            OTAprogressView = OTAProgress()
        }
        if(AppTheme.GET_IS_iPhone4S()) {
            let point:CGPoint = nevoWacthImage.center
            nevoWacthImage.frame = CGRectMake(0, 0, nevoWacthImage.frame.size.width-20, nevoWacthImage.frame.size.width-20)
            nevoWacthImage.center = point
        }
        OTAprogressView?.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        OTAprogressView?.frame = CGRectMake(nevoWacthImage.frame.origin.x, nevoWacthImage.frame.origin.y, nevoWacthImage.frame.size.width, nevoWacthImage.frame.size.height)
        OTAprogressView?.setProgress(progresValue)
        self.layer.addSublayer(OTAprogressView!)
    }
    

    @IBAction func buttonAction(sender: AnyObject) {
        mDelegate?.controllManager(sender)
    }

    /**
    Set the OTA upgrade progress value

    :param: progress Progress value
    */
    func setProgress(progress: Float, currentTask:NSInteger, allTask:NSInteger, progressString:String){
        progresValue = CGFloat(progress)
        OTAprogressView?.setProgress(progresValue)
        progresLabel.text = String(format: "%.0f%c", progresValue*100,37)
        messageLabel.text = NSLocalizedString("Updating", comment: "") + " \(progressString) " + "(\(currentTask)/\(allTask))"
    }

    func OTAprogressViewHiddenOrNotHidden() {
        if(OTAprogressView!.hidden) {
            OTAprogressView!.hidden = false
        }else{
            OTAprogressView!.hidden = true
        }
    }

    /**
    Is the latest edition of the display function

    :param: string
    */
    func setLatestVersion(string:String){
        let messageS:String  = string
        //taskLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
        //let labelframe:CGRect  = AppTheme.getWidthLabelSize(messageS, andObject: taskLabel.frame,andFont: AppTheme.FONT_RALEWAY_LIGHT(mSize: 15))
        //taskLabel.frame = labelframe
        //taskLabel.text = string
    }

    /**
    Upgrade success callback function
    */
    func upgradeSuccessful(){
        nevoWacthImage.image = AppTheme.GET_RESOURCES_IMAGE("connected");
        OTAprogressView!.hidden = true
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
