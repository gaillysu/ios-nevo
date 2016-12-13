import UIKit

class LunaROTAProgress: CAShapeLayer {

    fileprivate let progressLimit:CGFloat = 1.0 //The overall progress of the progress bar
    fileprivate var progress:CGFloat = 0 //The progress bar target schedule
    fileprivate var percent:CGFloat {
        //Calculating the percentage of the current value
        return CGFloat(calculatePercent(progress, toProgress: progressLimit))
    }
    fileprivate var initialProgress:CGFloat!
    fileprivate var progressLayer:CAShapeLayer! //The progress bar object
    fileprivate var progressColor:UIColor = UIColor.green //The background color of the progress bar


    override init(){
        super.init()
        self.path = drawPathWithArcCenter()
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = UIColor.clear.cgColor//UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 0.4).CGColor
        self.lineWidth = 5

        progressLayer = CAShapeLayer()
        progressLayer.path = drawPathWithArcCenter()
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
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
    func setProgress(_ Sprogress:CGFloat) {
        initialProgress = CGFloat(calculatePercent(progress, toProgress: progressLimit))
        progress = Sprogress

        self.progressLayer.strokeEnd = self.percent
        startAnimation();
    }

    /**
    Is the latest edition of the display function

    :param: string
    */
    func setLatestVersion(_ string:String){
        //valueLabel.text = string
        //valueLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 23)
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

class LunaROtaView: UIView {
    @IBOutlet weak var nevoWacthImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var progresLabel: UILabel!
    @IBOutlet weak var firmwareLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var updatingView: UIView!


    fileprivate var mDelegate:ButtonManagerCallBack?
    fileprivate var OTAprogressView:LunaROTAProgress?//OTA upgrade progress bar object
    var progresValue:CGFloat = 0.0//OTA upgrade progress bar default value
    
    override func awakeFromNib() {
        backgroundColor = UIColor.getLightBaseColor()
        backView.backgroundColor = UIColor.getLunarTabBarColor()
        updatingView.backgroundColor = UIColor.getLunarTabBarColor()
    }
    
    func buildView(_ delegate:ButtonManagerCallBack?) {
        mDelegate = delegate

        backButton.layer.masksToBounds = true
        backButton.layer.cornerRadius = 10.0
        backButton.layer.borderWidth = 1.0
        backButton.layer.borderColor = AppTheme.NEVO_SOLAR_YELLOW().cgColor

        if(OTAprogressView == nil){
            OTAprogressView = LunaROTAProgress()
        }
        if(AppTheme.GET_IS_iPhone4S()) {
            let point:CGPoint = nevoWacthImage.center
            nevoWacthImage.frame = CGRect(x: 0, y: 0, width: nevoWacthImage.frame.size.width-20, height: nevoWacthImage.frame.size.width-20)
            nevoWacthImage.center = point
        }
        OTAprogressView?.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        OTAprogressView?.frame = CGRect(x: nevoWacthImage.frame.origin.x, y: nevoWacthImage.frame.origin.y, width: nevoWacthImage.frame.size.width, height: nevoWacthImage.frame.size.height)
        OTAprogressView?.setProgress(progresValue)
        self.layer.addSublayer(OTAprogressView!)
    }
    

    @IBAction func buttonAction(_ sender: AnyObject) {
        mDelegate?.controllManager(sender)
    }

    /**
    Set the OTA upgrade progress value

    :param: progress Progress value
    */
    func setProgress(_ progress: Float, currentTask:NSInteger, allTask:NSInteger, progressString:String?){
        progresValue = CGFloat(progress)
        OTAprogressView?.setProgress(progresValue)
        progresLabel.text = String(format: "%.0f%c", progresValue*100,37)
        if progressString == nil {
            messageLabel.text = NSLocalizedString("Updating", comment: "") + " \(progressString) " + "(\(currentTask)/\(allTask))"
        }else{
            messageLabel.text = progressString!
        }
    }

    func OTAprogressViewHiddenOrNotHidden() {
        if(OTAprogressView!.isHidden) {
            OTAprogressView!.isHidden = false
        }else{
            OTAprogressView!.isHidden = true
        }
    }

    func upgradeSuccessful(){
        nevoWacthImage.image = AppTheme.GET_RESOURCES_IMAGE("lunar_connected");
        OTAprogressView!.isHidden = true
        updatingView.isHidden = true
        backView.isHidden = false
    }
    
    func upgradeError(){
        nevoWacthImage.image = AppTheme.GET_RESOURCES_IMAGE("connected");
        OTAprogressView!.isHidden = true
        updatingView.isHidden = true
        backView.isHidden = false
    }
}
