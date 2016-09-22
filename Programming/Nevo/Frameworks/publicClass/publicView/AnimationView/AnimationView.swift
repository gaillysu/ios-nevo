//
//  AnimationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/5.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit


protocol ButtonManagerCallBack {

    func controllManager(_ sender:AnyObject)
    
}

class AnimationView: UIView {

}

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

class CircleSleepProgressView: CAShapeLayer {
    fileprivate let progressLimit:CGFloat = 1.0 //The overall progress of the progress bar
    fileprivate var progress:CGFloat = 1.0 //The progress bar target schedule
    fileprivate var percent:CGFloat {
        //Calculating the percentage of the current value
        return CGFloat(calculatePercent(progress, toProgress: progressLimit))
    }
    fileprivate let progressWidth:CGFloat  = 2.0
    fileprivate var initialProgress:CGFloat!
    fileprivate var progressColor:UIColor = UIColor.green //The background color of the progress bar

    override init(){
        super.init()
        self.path = drawPathWithArcCenter(Date(),endtimer:Date())
        self.fillColor = UIColor.clear.cgColor
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers() {
        super.layoutSublayers()
    }

    /*
    Used to calculate the rotate degree
    */
    fileprivate func DegreesToRadians(_ degrees:Double) -> Double {

        //#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)  (degrees * M_PI)/180.0;
        return (degrees/180.0*M_PI);
    }

    /**
    The progress path function

    :returns: Returns the drawing need path
    */
    func drawPathWithArcCenter(_ startTimer:Date,endtimer:Date)->CGPath{
        let now:Date = startTimer
        let cal:Calendar = Calendar.current
        let comps:DateComponents = (cal as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day ,NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second,], from: now);
        (comps as NSDateComponents).timeZone = TimeZone.autoupdatingCurrent
        var hour:NSInteger = comps.hour!;
        let minute:NSInteger = comps.minute!;
        let second:NSInteger = comps.second!
        hour = hour > 12 ? hour-12:hour

        let endNow:Date = endtimer
        let endcal:Calendar = Calendar.current
        let endcomps:DateComponents = (endcal as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day ,NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second,], from: endNow);
        var endhour:NSInteger = endcomps.hour!;
        let endminute:NSInteger = endcomps.minute!;
        let endsecond:NSInteger = endcomps.second!
        endhour = endhour > 12 ? endhour-12:endhour

        var startangle:Double = Double(Double(second)/120.0 + Double(minute)/60.0+Double(hour))*Double(2.0/12.0)-0.5
        var endangle:Double = Double(Double(endsecond)/120.0 + Double(endminute)/60.0+Double(endhour))*Double(2.0/12.0)-0.5

        //AppTheme.DLog("startSecond___\(second,minute,hour)___startangle\(startangle) or endsecond______\(endsecond,endminute,endhour)_____\(endangle)")
        let position_y:CGFloat = self.frame.size.height/2.0
        let position_x:CGFloat = self.frame.size.width/2.0

        if(startangle == endangle){
            return UIBezierPath(arcCenter: CGPoint(x: position_x, y: position_y), radius: position_y, startAngle: 0, endAngle: 0, clockwise: true).cgPath
        }
        if(startangle >= 2){
            startangle = startangle-2
        }

        if(startangle < 0){
            startangle = 1.5+(startangle+0.5)
        }

        if(endangle > 2){
            endangle = endangle-2
        }

        if(endangle < 0){
            endangle = 1.5+(endangle+0.5)
        }
        //AppTheme.DLog("startSecond___\(second,minute,hour)___startangle\(startangle) or endsecond______\(endsecond,endminute,endhour)_____\(endangle)")
        let path:CGPath = UIBezierPath(arcCenter: CGPoint(x: position_x, y: position_y), radius: position_y, startAngle: CGFloat(M_PI*startangle), endAngle: CGFloat(M_PI*endangle), clockwise: true).cgPath
        return path
    }

    func setSleepProgress(_ sleepArray:NSArray,resulSleep:((_ dataSleep:Sleep) -> Void)){
        let sleepChartArray = CircleSleepProgressView.combiningSleepData(sleepArray)
        let arrayCount:Int = (sleepChartArray[0] as! [[Date]]).count
        var startDate:Date = Date()
        var endDate:Date = Date()

        var sleepTimer:TimeInterval  = 0
        var wakeTimer:TimeInterval  = 0
        var lightTimer:TimeInterval  = 0
        var deepTimer:TimeInterval  = 0
        var startTimer:TimeInterval = 0
        var endTimer:TimeInterval = 0

        for l:Int in 0 ..< arrayCount {
            initialProgress = CGFloat(calculatePercent(1.0, toProgress: progressLimit))
            let pLayer:CAShapeLayer = CAShapeLayer()
            startDate = ((sleepChartArray[0] as! [[Date]])[l][0]) //[l][0]
            endDate = ((sleepChartArray[0] as! [[Date]])[l][1])
            //AppTheme.DLog("startDate____\(startDate) or endDate______\(endDate)")
            pLayer.path = drawPathWithArcCenter(startDate,endtimer:endDate)
            pLayer.fillColor = UIColor.clear.cgColor
            pLayer.strokeColor = (sleepChartArray[1] as! [CGColor])[l]//sleepChartColorArray[l]
            pLayer.lineWidth = progressWidth
            pLayer.strokeEnd = percent
            self.addSublayer(pLayer)
            startSleepAnimation(pLayer);

            if(l == 0) {
                startTimer = startDate.timeIntervalSince1970
            }

            if(l == arrayCount-1) {
                endTimer = endDate.timeIntervalSince1970
            }
        }

        for i:Int in 0 ..< sleepArray.count {
            let sleepTimerArray:[Int] = (sleepArray.object(at: i) as! Array)[0]
            let weakTimerArray:[Int] = (sleepArray.object(at: i) as! Array)[1]
            let lightTimerArray:[Int] = (sleepArray.object(at: i) as! Array)[2]
            let deepTimerArray:[Int] = (sleepArray.object(at: i) as! Array)[3]

            if(i == 0){
                for s:Int in 18 ..< sleepTimerArray.count {
                    sleepTimer = Double(sleepTimerArray[s]) + sleepTimer
                    wakeTimer = Double(weakTimerArray[s]) + wakeTimer
                    lightTimer = Double(lightTimerArray[s]) + lightTimer
                    deepTimer = Double(deepTimerArray[s]) + deepTimer
                }
            }else{
                for s:Int in 0 ..< sleepTimerArray.count-6 {
                    sleepTimer = Double(sleepTimerArray[s]) + sleepTimer
                    wakeTimer = Double(weakTimerArray[s]) + wakeTimer
                    lightTimer = Double(lightTimerArray[s]) + lightTimer
                    deepTimer = Double(deepTimerArray[s]) + deepTimer
                }
            }
        }

        resulSleep(Sleep(weakSleep: wakeTimer, lightSleep: lightTimer, deepSleep: deepTimer, startTimer: startTimer, endTimer: endTimer))
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
    fileprivate func startSleepAnimation(_ layer:CAShapeLayer) {
        let pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeSleepEnd.scale")
        pathAnimation.duration = 1
        pathAnimation.fromValue = initialProgress;
        pathAnimation.toValue = percent;
        pathAnimation.isRemovedOnCompletion = true;
        layer.add(pathAnimation, forKey: nil)
    }
}
