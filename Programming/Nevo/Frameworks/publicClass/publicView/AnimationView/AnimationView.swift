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

}

class NevoCircleProgressView: CAShapeLayer {

    private let progressLimit:CGFloat = 1.0 //The overall progress of the progress bar
    private var progress:CGFloat = 0 //The progress bar target schedule
    private var percent:CGFloat {
        //Calculating the percentage of the current value
        return CGFloat(calculatePercent(progress, toProgress: progressLimit))
    }
    private let progressWidth:CGFloat  = 2.0
    private var initialProgress:CGFloat!
    private var progressLayer:CAShapeLayer! //The progress bar object
    private var progressColor:UIColor = UIColor.greenColor() //The background color of the progress bar

    override init(){
        super.init()
        //self.path = drawPathWithArcCenter()
        self.fillColor = UIColor.clearColor().CGColor
        //self.strokeColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 0.4).CGColor
        //self.lineWidth = 5

        progressLayer = CAShapeLayer()
        progressLayer.path = drawPathWithArcCenter()
        progressLayer.fillColor = UIColor.clearColor().CGColor
        progressLayer.strokeColor = progressColor.CGColor
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
        let pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 1.0
        pathAnimation.fromValue = initialProgress;
        pathAnimation.toValue = percent;
        pathAnimation.removedOnCompletion = true;
        progressLayer.addAnimation(pathAnimation, forKey: nil)
    }
}

class CircleSleepProgressView: CAShapeLayer {
    private let progressLimit:CGFloat = 1.0 //The overall progress of the progress bar
    private var progress:CGFloat = 1.0 //The progress bar target schedule
    private var percent:CGFloat {
        //Calculating the percentage of the current value
        return CGFloat(calculatePercent(progress, toProgress: progressLimit))
    }
    private let progressWidth:CGFloat  = 2.0
    private var initialProgress:CGFloat!
    private var progressColor:UIColor = UIColor.greenColor() //The background color of the progress bar

    override init(){
        super.init()
        self.path = drawPathWithArcCenter(NSDate(),endtimer:NSDate())
        self.fillColor = UIColor.clearColor().CGColor
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
    private func DegreesToRadians(degrees:Double) -> Double {

        //#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)  (degrees * M_PI)/180.0;
        return (degrees/180.0*M_PI);
    }

    /**
    The progress path function

    :returns: Returns the drawing need path
    */
    func drawPathWithArcCenter(startTimer:NSDate,endtimer:NSDate)->CGPathRef{
        let now:NSDate = startTimer
        let cal:NSCalendar = NSCalendar.currentCalendar()
        let comps:NSDateComponents = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day ,NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second,], fromDate: now);
        comps.timeZone = NSTimeZone.localTimeZone()
        var hour:NSInteger = comps.hour;
        let minute:NSInteger = comps.minute;
        let second:NSInteger = comps.second
        hour = hour > 12 ? hour-12:hour

        let endNow:NSDate = endtimer
        let endcal:NSCalendar = NSCalendar.currentCalendar()
        let endcomps:NSDateComponents = endcal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day ,NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second,], fromDate: endNow);
        var endhour:NSInteger = endcomps.hour;
        let endminute:NSInteger = endcomps.minute;
        let endsecond:NSInteger = endcomps.second
        endhour = endhour > 12 ? endhour-12:endhour

        var startangle:Double = Double(Double(second)/120.0 + Double(minute)/60.0+Double(hour))*Double(2.0/12.0)-0.5
        var endangle:Double = Double(Double(endsecond)/120.0 + Double(endminute)/60.0+Double(endhour))*Double(2.0/12.0)-0.5

        //AppTheme.DLog("startSecond___\(second,minute,hour)___startangle\(startangle) or endsecond______\(endsecond,endminute,endhour)_____\(endangle)")
        let position_y:CGFloat = self.frame.size.height/2.0
        let position_x:CGFloat = self.frame.size.width/2.0

        if(startangle == endangle){
            return UIBezierPath(arcCenter: CGPointMake(position_x, position_y), radius: position_y, startAngle: 0, endAngle: 0, clockwise: true).CGPath
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
        let path:CGPathRef = UIBezierPath(arcCenter: CGPointMake(position_x, position_y), radius: position_y, startAngle: CGFloat(M_PI*startangle), endAngle: CGFloat(M_PI*endangle), clockwise: true).CGPath
        return path
    }

    func setSleepProgress(sleepArray:NSArray,resulSleep:((dataSleep:Sleep) -> Void)){
        let sleepChartArray = CircleSleepProgressView.combiningSleepData(sleepArray)
        let arrayCount:Int = (sleepChartArray[0] as! [[NSDate]]).count
        var startDate:NSDate = NSDate()
        var endDate:NSDate = NSDate()

        var sleepTimer:NSTimeInterval  = 0
        var wakeTimer:NSTimeInterval  = 0
        var lightTimer:NSTimeInterval  = 0
        var deepTimer:NSTimeInterval  = 0
        var startTimer:NSTimeInterval = 0
        var endTimer:NSTimeInterval = 0

        for l:Int in 0 ..< arrayCount {
            initialProgress = CGFloat(calculatePercent(1.0, toProgress: progressLimit))
            let pLayer:CAShapeLayer = CAShapeLayer()
            startDate = ((sleepChartArray[0] as! [[NSDate]])[l][0]) //[l][0]
            endDate = ((sleepChartArray[0] as! [[NSDate]])[l][1])
            //AppTheme.DLog("startDate____\(startDate) or endDate______\(endDate)")
            pLayer.path = drawPathWithArcCenter(startDate,endtimer:endDate)
            pLayer.fillColor = UIColor.clearColor().CGColor
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
            let sleepTimerArray:[Int] = sleepArray.objectAtIndex(i).objectAtIndex(0) as! [Int]
            let weakTimerArray:[Int] = sleepArray.objectAtIndex(i).objectAtIndex(1) as! [Int]
            let lightTimerArray:[Int] = sleepArray.objectAtIndex(i).objectAtIndex(2) as! [Int]
            let deepTimerArray:[Int] = sleepArray.objectAtIndex(i).objectAtIndex(3) as! [Int]

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

        resulSleep(dataSleep: Sleep(weakSleep: wakeTimer, lightSleep: lightTimer, deepSleep: deepTimer, startTimer: startTimer, endTimer: endTimer))
    }

    /**
    解析睡眠数据

    :param: array 睡眠原始数据

    :returns: 返回解析后的数据
    */
    class func combiningSleepData(array:NSArray) -> NSArray {
        let cal:NSCalendar = NSCalendar.currentCalendar()
        var lastTimer:Int = 0
        var startDate:NSDate?
        var endDate:NSDate?
        var sleepChartArray:[[NSDate]] = []
        var sleepChartColorArray:[CGColor] = []
        let todayDate:NSDate = GmtNSDate2LocaleNSDate(NSDate())
        for(var i:Int = 23; i>=12;i -= 1){
            let sleepTimerArray:[Int] = array.objectAtIndex(0).objectAtIndex(0) as! [Int]
            let weakTimerArray:[Int] = array.objectAtIndex(0).objectAtIndex(1) as! [Int]
            let lightTimerArray:[Int] = array.objectAtIndex(0).objectAtIndex(2) as! [Int]
            let deepTimerArray:[Int] = array.objectAtIndex(0).objectAtIndex(3) as! [Int]

            if(sleepTimerArray[i] == 0 && i == 23){
                break
            }

            if(sleepTimerArray[i]==0 && i != 23){
                for l:Int in i+1 ..< sleepTimerArray.count {
                    lastTimer = 60-sleepTimerArray[l]
                    startDate = cal.dateBySettingHour(l, minute: lastTimer , second:0, ofDate: todayDate, options: NSCalendarOptions())!
                    if(lastTimer+weakTimerArray[l]+lightTimerArray[l] == 60){
                        if(l == 23){
                            endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: 0, minute: 0, second: 0)
                        }else{
                            endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l+1, minute: 0, second: 0)
                        }

                    }else{
                        endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l, minute: lastTimer+weakTimerArray[l]+lightTimerArray[l], second: 0)
                    }
                    sleepChartArray.append([startDate!,endDate!])
                    sleepChartColorArray.append(AppTheme.getLightSleepColor().CGColor)
                    //AppTheme.DLog("Light startDate____\(startDate) or endDate______\(endDate)")
                    startDate = endDate
                    if(lastTimer+weakTimerArray[l]+lightTimerArray[l]+deepTimerArray[l] == 60){
                        if(l == 23){
                            endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: 0, minute: 0, second: 0)
                        }else{
                            endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l+1, minute: 0, second: 0)
                        }
                    }else{
                        endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l, minute: lastTimer+weakTimerArray[l]+lightTimerArray[l]+deepTimerArray[l], second: 0)
                    }
                    sleepChartArray.append([startDate!,endDate!])
                    sleepChartColorArray.append(AppTheme.getDeepSleepColor().CGColor)
                    //AppTheme.DLog("Deep startDate____\(startDate) or endDate______\(endDate)")
                }
                break
            }
        }
        if(sleepChartArray.count != 0){
            //计算跨天睡眠(前一天有睡眠数据)
            let sleepTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(0) as! [Int]
            let weakTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(1) as! [Int]
            let lightTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(2) as! [Int]
            let deepTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(3) as! [Int]

            for l:Int in 0 ..< sleepTimerArray.count-12 {
                if(sleepTimerArray[l] == 0){
                    break
                }
                startDate = endDate
                if(lightTimerArray[l]+weakTimerArray[l] == 60){
                    endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l+1, minute: 0, second: 0)
                }else{
                    endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l, minute: lightTimerArray[l]+weakTimerArray[l], second: 0)
                }
                sleepChartArray.append([startDate!,endDate!])
                sleepChartColorArray.append(AppTheme.getLightSleepColor().CGColor)
                //AppTheme.DLog("Light startDate____\(startDate) or endDate______\(endDate)")

                startDate = endDate
                if(lightTimerArray[l]+weakTimerArray[l]+deepTimerArray[l] == 60){
                    endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l+1, minute: 0, second: 0)
                }else{
                    endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l, minute: lightTimerArray[l]+weakTimerArray[l]+deepTimerArray[l], second: 0)
                }
                sleepChartArray.append([startDate!,endDate!])
                sleepChartColorArray.append(AppTheme.getDeepSleepColor().CGColor)
            }
        }else{
            //跨天后的睡眠计算(前一天无睡眠数据)
            let sleepTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(0) as! [Int]
            let weakTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(1) as! [Int]
            let lightTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(2) as! [Int]
            let deepTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(3) as! [Int]

            for l:Int in 0 ..< sleepTimerArray.count-12 {
                if(sleepTimerArray[l] == 0){
                    continue
                }
                lastTimer = 60-sleepTimerArray[l]
                if(sleepChartArray.count==0){
                    startDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l, minute: lastTimer, second: 0)
                }else{
                    startDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l, minute: 0, second: 0)
                }
                if(lastTimer+lightTimerArray[l]+weakTimerArray[l] == 60){
                    if(sleepChartArray.count == 0 || lightTimerArray[l]+weakTimerArray[l] == 60){
                        endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l+1, minute: 0, second: 0)
                    }else{
                        endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l, minute: lightTimerArray[l]+weakTimerArray[l], second: 0)
                    }

                }else{
                    endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l, minute: lightTimerArray[l]+weakTimerArray[l], second: 0)
                }
                sleepChartArray.append([startDate!,endDate!])
                sleepChartColorArray.append(AppTheme.getLightSleepColor().CGColor)

                startDate = endDate
                if(lightTimerArray[l]+weakTimerArray[l]+deepTimerArray[l] == 60){
                    endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l+1, minute: 0, second: 0)
                }else{
                    if(sleepChartArray.count==1){
                        endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l+1, minute: 0, second: 0)
                    }else{
                        endDate = NSDate.date(year: todayDate.year, month: todayDate.month, day: todayDate.day, hour: l, minute: lightTimerArray[l]+weakTimerArray[l]+deepTimerArray[l], second: 0)
                    }
                }
                sleepChartArray.append([startDate!,endDate!])
                sleepChartColorArray.append(AppTheme.getDeepSleepColor().CGColor)
            }
        }

        return NSArray(array: [sleepChartArray,sleepChartColorArray]);
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
    private func startSleepAnimation(layer:CAShapeLayer) {
        let pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeSleepEnd.scale")
        pathAnimation.duration = 1
        pathAnimation.fromValue = initialProgress;
        pathAnimation.toValue = percent;
        pathAnimation.removedOnCompletion = true;
        layer.addAnimation(pathAnimation, forKey: nil)
    }
}