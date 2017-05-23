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
 

let NUMBER_OF_STEPS_GOAL_KEY = "NUMBER_OF_STEPS_GOAL_KEY"

class StepsController: PublicClassController,ClockRefreshDelegate {
    
    @IBOutlet weak var clockBackGroundView: UIView!
    @IBOutlet weak var collectionView:UICollectionView!
    //Put all UI operation HomeView inside
    fileprivate var mClockTimerView:ClockView?;//init "ClockView" ,Use the code relative layout
    var progressView:NevoCircleProgressView = NevoCircleProgressView()
    var progresValue:CGFloat = 0.0
    
    let StepsGoalKey:String = "ADYSTEPSGOALKEY"
    
    fileprivate var mCurrentGoal:Goal = NumberOfStepsGoal()
    fileprivate var mVisiable:Bool = true
    fileprivate var contentTitleArray:[String] = [NSLocalizedString("CALORIE", comment: ""), NSLocalizedString("STEPS", comment: ""), NSLocalizedString("TIME", comment: ""),NSLocalizedString("Distance", comment: "")]
    fileprivate var contentTArray:[String] = ["0","0","0","0"]
    
    fileprivate let SYNC_INTERVAL:TimeInterval = 1*3*60 //unit is second in iOS, every 3min, do sync
    fileprivate let TODAY_SYNC_DATE_KEY = "TODAY_SYNC_DATE_KEY"
    var lastSync = 0.0
    
    var shouldSync = false;
    
    init() {
        super.init(nibName: "StepsController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ClockRefreshManager.instance.setRefreshDelegate(self)
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 0, height: 0)
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UINib(nibName: "StepViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "StepViewCellIdentifier")
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
        collectionView?.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        saveContentTArray(Date().beginningOfDay.timeIntervalSince1970)
        
        if ConnectionManager.manager.hasSavedAddress() {
            ConnectionManager.manager.startConnect(false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //sync today data
        if !ConnectionManager.manager.isSync {
            let userDefaults = UserDefaults.standard;
            lastSync = userDefaults.double(forKey: TODAY_SYNC_DATE_KEY)
            if( Date().timeIntervalSince1970-lastSync > SYNC_INTERVAL) {
                ConnectionManager.manager.getTodayTracker();
                UserDefaults.standard.set(Date().timeIntervalSince1970,forKey:TODAY_SYNC_DATE_KEY)
                UserDefaults.standard.synchronize()
            }
        }
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY) { (notification) in
            let dict:[String:AnyObject] = notification.object as! [String:AnyObject]
            let dailySteps:Int = dict["STEPS"] as! Int
            self.contentTArray.replaceSubrange(Range(1..<2), with: ["\(dailySteps)"])
            DataCalculation.calculationData(0, steps: dailySteps, completionData: { (miles, calories) in
                self.contentTArray.replaceSubrange(Range(3..<4), with: [String(format: "%.2f", miles)])
            })
            self.collectionView.reloadData()
            //TODAY_DATE_CACHE
            let cacheData:SyncStepsCache = SyncStepsCache(date: Date(), steps: dailySteps)
            _ = Tools.KeyedArchiverName(TODAY_DATE_CACHE, andObject: cacheData)
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
            let packet = notification.object as! NevoPacket
            //Do nothing
            if packet.getHeader() == GetStepsGoalRequest.HEADER(){
                var percent:Float = 0
                let thispacket = packet.copy() as DailyStepsNevoPacket
                let dailySteps:Int = thispacket.getDailySteps()
                let dailyStepGoal:Int = thispacket.getDailyStepsGoal()
                percent = Float(dailySteps)/Float(dailyStepGoal)
                self.progressView.setProgress(CGFloat(percent))
            }
        }
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) in
            self.checkConnection()
        }
    }
}

// MARK: - Events handle
extension StepsController {
    
    /**
     Archiver "contentTArray"
     */
    func saveContentTArray(_ beginningDate:TimeInterval) {
        //Only for today's data
        let array = MEDUserSteps.getFilter("date = \(beginningDate)")
        if array.count>0 {
            let dataSteps:MEDUserSteps = array[0] as! MEDUserSteps
            
            let timerValue:Double = Double(dataSteps.walking_duration+dataSteps.running_duration)
            self.contentTArray.replaceSubrange(Range(1..<2), with: ["\(dataSteps.totalSteps)"])
            self.contentTArray.replaceSubrange(Range(2..<3), with: [Double(timerValue/60.0).timerFormatValue()])
            DataCalculation.calculationData((dataSteps.walking_duration+dataSteps.running_duration), steps: dataSteps.totalSteps, completionData: { (miles, calories) in
                self.contentTArray.replaceSubrange(Range(0..<1), with: [String(format: "%.2f", calories)])
                self.contentTArray.replaceSubrange(Range(3..<4), with: [String(format: "%.2f", miles)])
            })
            self.collectionView.reloadData()
            //Tools.KeyedArchiverName(self.StepsGoalKey, andObject: self.contentTArray)
        }
    }
    
    // MARK: - ClockRefreshDelegate
    func clockRefreshAction(){
        mClockTimerView?.currentTimer()
        if ConnectionManager.manager.isConnected {
            ConnectionManager.manager.getGoal()
            XCGLogger.default.debug("getGoalRequest")
        }
    }
}


// MARK: - Private function
extension StepsController {
    func getTodayCacheData() {
        if let value = Tools.LoadKeyedArchiverName(TODAY_DATE_CACHE) {
            if value is SyncStepsCache {
                let cacheData:SyncStepsCache = value as! SyncStepsCache
                if let date:Date = cacheData.todayDate, let dailySteps:Int = cacheData.todaySteps {
                    if date.day == Date().day {
                        self.contentTArray.replaceSubrange(Range(1..<2), with: ["\(dailySteps)"])
                        DataCalculation.calculationData(0, steps: dailySteps, completionData: { (miles, calories) in
                            self.contentTArray.replaceSubrange(Range(3..<4), with: [String(format: "%.2f", miles)])
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - StepGoalSetingController delegate
    // MARK: - StepGoalSetingController function
    /**
     Checks if any device is currently connected
     */
    func checkConnection() {
        if !ConnectionManager.manager.isConnected {
            //We are currently not connected
            ConnectionManager.manager.connect()
        }
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
        
        mClockTimerView = ClockView(frame:CGRect(x: 0, y: 0, width: dialWidth, height: dialWidth), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!)
        
        mClockTimerView?.center.x = clockBackGroundView.frame.width / 2.0
        mClockTimerView?.center.y = mClockTimerView!.center.y - 20
        
        mClockTimerView?.currentTimer()
        clockBackGroundView.addSubview(mClockTimerView!)
        
        progressView.frame = CGRect(x: -3, y: -3, width: dialWidth+6, height: dialWidth+6)
        progressView.setProgressColor(UIColor.baseColor)
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
extension StepsController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:StepViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StepViewCellIdentifier", for: indexPath) as! StepViewCell
        let titleString:String = contentTitleArray[(indexPath as NSIndexPath).row]
        cell.titleLabel.text = titleString.capitalized(with: Locale.current)
        switch indexPath.row {
        case 0:
            cell.valueLabel.text = "\(contentTArray[indexPath.row]) Cal"
            break;
        case 1:
            cell.valueLabel.text = "\(contentTArray[indexPath.row])"
            break;
        case 2:
            cell.valueLabel.text = "\(contentTArray[indexPath.row])"
            break;
        case 3:
            var unit:String = "KM"
            var unitValue:Double = "\(contentTArray[indexPath.row])".toDouble()
            if UserDefaults.standard.getUserSelectedUnitValue() == 1 {
                unit = "Mi"
                unitValue = unitValue*kmToMi
            }
            cell.valueLabel.text = "\(unitValue.to2Double()) \(unit)"
            break;
        default:
            break;
        }
        
        return cell
    }
}
