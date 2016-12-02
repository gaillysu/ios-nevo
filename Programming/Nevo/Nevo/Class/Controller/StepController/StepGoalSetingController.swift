//
//  StepGoalSetingController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import SwiftEventBus
import XCGLogger
import Timepiece

let NUMBER_OF_STEPS_GOAL_KEY = "NUMBER_OF_STEPS_GOAL_KEY"

class StepGoalSetingController: PublicClassController,ClockRefreshDelegate {
    
    @IBOutlet weak var clockBackGroundView: UIView!
    @IBOutlet weak var collectionView:UICollectionView!
    //Put all UI operation HomeView inside
    fileprivate var mClockTimerView:ClockView?;//init "ClockView" ,Use the code relative layout
    var progressView:NevoCircleProgressView = NevoCircleProgressView()
    var progresValue:CGFloat = 0.0
    
    let StepsGoalKey:String = "ADYSTEPSGOALKEY"
    
    fileprivate var mCurrentGoal:Goal = NumberOfStepsGoal()
    fileprivate var mVisiable:Bool = true
    fileprivate var contentTitleArray:[String] = [NSLocalizedString("CALORIE", comment: ""), NSLocalizedString("STEPS", comment: ""), NSLocalizedString("TIME", comment: ""),NSLocalizedString("KM", comment: "")]
    fileprivate var contentTArray:[String] = ["0","0","0","0"]
    
    fileprivate let SYNC_INTERVAL:TimeInterval = 1*3*60 //unit is second in iOS, every 3min, do sync
    fileprivate let TODAY_SYNC_DATE_KEY = "TODAY_SYNC_DATE_KEY"
    var lastSync = 0.0
    
    var shouldSync = false;
    
    init() {
        super.init(nibName: "StepGoalSetingController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ClockRefreshManager.sharedInstance.setRefreshDelegate(self)
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 0, height: 0)
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UINib(nibName: "StepGoalSetingViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "StepGoalSetingIdentifier")
        collectionView?.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "CollectionViewCell")
        
        getTodayCacheData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self, name: SELECTED_CALENDAR_NOTIFICATION)
        SwiftEventBus.unregister(self, name: EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY)
        SwiftEventBus.unregister(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY)
        SwiftEventBus.unregister(self, name: EVENT_BUS_RAWPACKET_DATA_KEY)
        SwiftEventBus.unregister(self, name: EVENT_BUS_CONNECTION_STATE_CHANGED_KEY)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let layout:UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: collectionView.frame.size.width/2.0, height: collectionView.frame.size.height/2.0 - 10)
        
        bulidClockViewandProgressBar()
        if !AppTheme.isTargetLunaR_OR_Nevo(){
            collectionView.backgroundColor = UIColor.getGreyColor()
            self.view.backgroundColor = UIColor.getGreyColor()
        }else{
            collectionView?.backgroundColor = UIColor.white
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        saveContentTArray(Date().beginningOfDay.timeIntervalSince1970)
        
        if(AppDelegate.getAppDelegate().hasSavedAddress()) {
            AppDelegate.getAppDelegate().startConnect(false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //sync today data
        if !AppDelegate.getAppDelegate().isSyncState() {
            let userDefaults = UserDefaults.standard;
            lastSync = userDefaults.double(forKey: TODAY_SYNC_DATE_KEY)
            if( Date().timeIntervalSince1970-lastSync > SYNC_INTERVAL) {
                AppDelegate.getAppDelegate().getTodayTracker();
                UserDefaults.standard.set(Date().timeIntervalSince1970,forKey:TODAY_SYNC_DATE_KEY)
                UserDefaults.standard.synchronize()
            }
        }
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY) { (notification) in
            let dict:[String:AnyObject] = notification.object as! [String:AnyObject]
            let dailySteps:Int = dict["STEPS"] as! Int
            self.contentTArray.replaceSubrange(Range(1..<2), with: ["\(dailySteps)"])
            StepGoalSetingController.calculationData(0, steps: dailySteps, completionData: { (miles, calories) in
                self.contentTArray.replaceSubrange(Range(3..<4), with: [String(format: "%.2f", miles)])
            })
            self.collectionView.reloadData()
            //TODAY_DATE_CACHE
            UserDefaults.standard.set([TODAY_DATE_CACHE:dailySteps,"DATE":Date()],forKey:TODAY_DATE_CACHE)
            UserDefaults.standard.synchronize()
        }
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            self.saveContentTArray(Date().beginningOfDay.timeIntervalSince1970)
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            let userinfo:Date = notification.userInfo!["selectedDate"] as! Date
            self.saveContentTArray(userinfo.beginningOfDay.timeIntervalSince1970)
        }
        
        //RAWPACKET DATA
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_RAWPACKET_DATA_KEY) { (notification) in
            var percent:Float = 0
            if AppTheme.isTargetLunaR_OR_Nevo() {
                let packet = notification.object as! NevoPacket
                //Do nothing
                if packet.getHeader() == GetStepsGoalRequest.HEADER(){
                    let thispacket = packet.copy() as DailyStepsNevoPacket
                    let dailySteps:Int = thispacket.getDailySteps()
                    let dailyStepGoal:Int = thispacket.getDailyStepsGoal()
                    percent = Float(dailySteps)/Float(dailyStepGoal)
                    
                }
            }else{
                let packet = notification.object as! LunaRPacket
                //Do nothing
                if packet.getHeader() == GetStepsGoalRequest.HEADER(){
                    let thispacket = packet.copy() as LunaRStepsGoalPacket
                    let dailySteps:Int = thispacket.getDailySteps()
                    let dailyStepGoal:Int = thispacket.getDailyStepsGoal()
                    percent = Float(dailySteps)/Float(dailyStepGoal)
                }
            }
            self.progressView.setProgress(CGFloat(percent))
        }
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) in
            self.checkConnection()
        }
    }
}

// MARK: - Events handle
extension StepGoalSetingController {
    /**
     GET Archiver "contentTArray"
     */
    func getContentTArray() {
        let dataArray:NSArray = AppTheme.LoadKeyedArchiverName(StepsGoalKey as NSString) as! NSArray
        if(dataArray.count>0) {
            let date:TimeInterval = (dataArray[1] as! String).dateFromFormat("YYYY/MM/dd", locale: DateFormatter().locale)!.timeIntervalSince1970
            if(date != Date.date(year: Date().year, month: Date().month, day: Date().day).timeIntervalSince1970){ return }
            
            contentTArray = (AppTheme.LoadKeyedArchiverName(StepsGoalKey as NSString) as! NSArray)[0] as! [String]
            let dailyStepGoal:Int = NSString(string: contentTArray[2]).integerValue
            let dailySteps:Int = NSString(string: contentTArray[1]).integerValue
            let percent :Float = Float(dailySteps)/Float(dailyStepGoal)
            
            self.setProgress(percent, dailySteps: dailySteps, dailyStepGoal: dailyStepGoal)
            collectionView?.reloadData()
        }
    }
    
    /**
     Archiver "contentTArray"
     */
    func saveContentTArray(_ beginningDate:TimeInterval) {
        //Only for today's data
        let array = MEDUserSteps.getFilter("date == \(beginningDate)")
        if array.count>0 {
            let dataSteps:MEDUserSteps = array[0] as! MEDUserSteps
            
            let timerValue:Double = Double(dataSteps.walking_duration+dataSteps.running_duration)
            self.contentTArray.replaceSubrange(Range(1..<2), with: ["\(dataSteps.totalSteps)"])
            self.contentTArray.replaceSubrange(Range(2..<3), with: [AppTheme.timerFormatValue(value: Double(timerValue/60.0))])
            StepGoalSetingController.calculationData((dataSteps.walking_duration+dataSteps.running_duration), steps: dataSteps.totalSteps, completionData: { (miles, calories) in
                self.contentTArray.replaceSubrange(Range(0..<1), with: [String(format: "%.2f", calories)])
                self.contentTArray.replaceSubrange(Range(3..<4), with: [String(format: "%.2f", miles)])
            })
            self.collectionView.reloadData()
            //AppTheme.KeyedArchiverName(self.StepsGoalKey, andObject: self.contentTArray)
        }
    }
    
    // MARK: - ClockRefreshDelegate
    func clockRefreshAction(){
        mClockTimerView?.currentTimer()
        if AppDelegate.getAppDelegate().isConnected() {
            AppDelegate.getAppDelegate().getGoal()
            XCGLogger.default.debug("getGoalRequest")
        }
    }
}


// MARK: - Private function
extension StepGoalSetingController {
    func getTodayCacheData() {
        if UserDefaults.standard.object(forKey: TODAY_DATE_CACHE) != nil {
            let dataCache:[String:Any] = UserDefaults.standard.object(forKey: TODAY_DATE_CACHE) as! [String : Any]
            let date:Date = dataCache["DATE"] as! Date
            if date.day == Date().day {
                let dailySteps:Int = dataCache[TODAY_DATE_CACHE] as! Int
                self.contentTArray.replaceSubrange(Range(1..<2), with: ["\(dailySteps)"])
                StepGoalSetingController.calculationData(0, steps: dailySteps, completionData: { (miles, calories) in
                    self.contentTArray.replaceSubrange(Range(3..<4), with: [String(format: "%.2f", miles)])
                })
            }
        }
    }
    
    // MARK: - StepGoalSetingController delegate
    // MARK: - StepGoalSetingController function
    /**
     Checks if any device is currently connected
     */
    func checkConnection() {
        if !AppDelegate.getAppDelegate().isConnected() {
            //We are currently not connected
            AppDelegate.getAppDelegate().connect()
        }
    }
    
    // MARK: - Data calculation
    class func calculationData(_ activeTimer:Int,steps:Int,completionData:((_ miles:Double,_ calories:Double) -> Void)) {
        let profile:NSArray = UserProfile.getAll()
        var userProfile:UserProfile?
        var strideLength:Double = 0
        var userWeight:Double = 0
        if profile.count>0 {
            userProfile = profile.object(at: 0) as? UserProfile
            strideLength = Double(userProfile!.length)*0.415/100
            userWeight = Double(userProfile!.weight)
        }else{
            strideLength = Double(170)*0.415/100
            userWeight = 65
        }
        
        let miles:Double = strideLength*Double(steps)/1000
        let calories:Double = (2.0*userWeight*3.5)/200*Double(activeTimer)
        completionData(miles, calories)
    }
    
    /**
     bulid in clockView
     */
    func bulidClockViewandProgressBar() {
        for view in self.clockBackGroundView.subviews {
            if view is ClockView {
                view.removeFromSuperview()
            }
        }
        
        let dialWidth:CGFloat = self.clockBackGroundView.bounds.height
        
        if !AppTheme.isTargetLunaR_OR_Nevo(){
            clockBackGroundView.backgroundColor = UIColor.getGreyColor()
            mClockTimerView = ClockView(frame:CGRect(x: 0, y: 0, width: dialWidth, height: dialWidth), hourImage:  UIImage(named: "wacth_hour")!, minuteImage: UIImage(named: "wacth_mint")!, dialImage: UIImage(named: "wacth_dial")!)
        }else{
            mClockTimerView = ClockView(frame:CGRect(x: 0, y: 0, width: dialWidth, height: dialWidth), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!)
        }
        
        /// 为了和其它类似界面的布局一致, 约束已经被写死了
        mClockTimerView?.center.x = clockBackGroundView.frame.width / 2.0
        mClockTimerView?.center.y = mClockTimerView!.center.y - 20
        
        mClockTimerView?.currentTimer()
        clockBackGroundView.addSubview(mClockTimerView!)
        
        progressView.frame = CGRect(x: -3, y: -3, width: dialWidth+6, height: dialWidth+6)
        progressView.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        progressView.setProgress(0.0)
        mClockTimerView?.layer.addSublayer(progressView)
    }
    
    /**
     set the progress of the progressView
     
     :param: progress
     :param: animated
     */
    func setProgress(_ progress: Float,dailySteps:Int,dailyStepGoal:Int){
        progresValue = CGFloat(progress)
        progressView.setProgress(progresValue, Steps: dailySteps, GoalStep: dailyStepGoal)
    }
}


// MARK: - CollectionView Delegate
extension StepGoalSetingController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
//        return CGSize(width: collectionView.frame.size.width/2.0, height: collectionView.frame.size.height/2 - 10)
//    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:StepGoalSetingViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StepGoalSetingIdentifier", for: indexPath) as! StepGoalSetingViewCell
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            cell.backgroundColor = UIColor.getGreyColor()
            cell.titleLabel.textColor = UIColor.white
            cell.valueLabel.textColor = UIColor.getBaseColor()
        }
        let titleString:String = contentTitleArray[(indexPath as NSIndexPath).row]
        cell.titleLabel.text = titleString.capitalized(with: Locale.current)
        switch (indexPath as NSIndexPath).row {
        case 0:
            cell.valueLabel.text = "\(contentTArray[(indexPath as NSIndexPath).row]) Cal"
            break;
        case 1:
            cell.valueLabel.text = "\(contentTArray[(indexPath as NSIndexPath).row])"
            break;
        case 2:
            cell.valueLabel.text = "\(contentTArray[(indexPath as NSIndexPath).row])"
            break;
        case 3:
            cell.valueLabel.text = "\(contentTArray[(indexPath as NSIndexPath).row]) KM"
            break;
        default:
            break;
        }
        
        return cell
    }
}
