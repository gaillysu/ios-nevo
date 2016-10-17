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

class StepGoalSetingController: PublicClassController,ButtonManagerCallBack,ClockRefreshDelegate {
    
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self, name: SELECTED_CALENDAR_NOTIFICATION)
        SwiftEventBus.unregister(self, name: EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width)/2.0, height: 40)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UINib(nibName: "StepGoalSetingViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "StepGoalSetingIdentifier")
        collectionView?.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "CollectionViewCell")
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
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY) { (notification) in
            let dict:[String:AnyObject] = notification.object as! [String:AnyObject]
            let dailySteps:Int = dict["STEPS"] as! Int
            self.contentTArray.replaceSubrange(Range(1..<2), with: ["\(dailySteps)"])
            self.calculationData(0, steps: dailySteps, completionData: { (miles, calories) in
                self.contentTArray.replaceSubrange(Range(3..<4), with: ["\(miles)"])
            })
            self.collectionView.reloadData()
        }
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            
        }
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            
            self.saveContentTArray(Date().beginningOfDay.timeIntervalSince1970)
        }
        
        SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            let userinfo:Date = notification.userInfo!["selectedDate"] as! Date
            self.saveContentTArray(userinfo.beginningOfDay.timeIntervalSince1970)
        }
        
        //RAWPACKET DATA
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_RAWPACKET_DATA_KEY) { (notification) in
            let packet = notification.object as! NevoPacket
            //Do nothing
            if packet.getHeader() == GetStepsGoalRequest.HEADER(){
                let thispacket = packet.copy() as DailyStepsNevoPacket
                let dailySteps:Int = thispacket.getDailySteps()
                let dailyStepGoal:Int = thispacket.getDailyStepsGoal()
                let percent :Float = Float(dailySteps)/Float(dailyStepGoal)
            }
            
            if packet.getHeader() == LedLightOnOffNevoRequest.HEADER(){
                XCGLogger.default.debug("end handshake nevo");
                //blink once Clock
            }
        }
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) in
            self.checkConnection()
        }
        
        if(!AppDelegate.getAppDelegate().hasSavedAddress()) {
            let tutorialOne:TutorialOneViewController = TutorialOneViewController()
            let nav:UINavigationController = UINavigationController(rootViewController: tutorialOne)
            nav.isNavigationBarHidden = true
            self.present(nav, animated: true, completion: nil)
        }else{
            AppDelegate.getAppDelegate().startConnect(false)
        }
    }
    
    /**
     GET Archiver "contentTArray"
     */
    func getContentTArray() {
        let dataArray:NSArray = AppTheme.LoadKeyedArchiverName(StepsGoalKey as NSString) as! NSArray
        if(dataArray.count>0) {
            let date:TimeInterval = (dataArray[1] as! String).dateFromFormat("YYYY/MM/dd")!.timeIntervalSince1970
            if(date != Date.date(Date().year, month: Date().month, day: Date().day).timeIntervalSince1970){ return }
            
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
        let array:NSArray = UserSteps.getCriteria("WHERE date = \(beginningDate)")
        if array.count>0 {
            let dataSteps:UserSteps = array[0] as! UserSteps
            
            self.contentTArray.replaceSubrange(Range(1..<2), with: ["\(dataSteps.steps)"])
             self.contentTArray.replaceSubrange(Range(2..<3), with: [String(format: "%.2f", Float(dataSteps.walking_duration+dataSteps.running_duration)/60.0)])
            self.calculationData((dataSteps.walking_duration+dataSteps.running_duration), steps: dataSteps.steps, completionData: { (miles, calories) in
                self.contentTArray.replaceSubrange(Range(0..<1), with: ["\(calories)"])
                self.contentTArray.replaceSubrange(Range(3..<4), with: ["\(miles)"])
            })
            self.collectionView.reloadData()
            //AppTheme.KeyedArchiverName(self.StepsGoalKey, andObject: self.contentTArray)
        }
    }

    /**
     bulid in clockView
     */
    func bulidClockViewandProgressBar() {
        for view in clockBackGroundView.subviews {
            if view is ClockView {
                view.removeFromSuperview()
            }
        }
        
        if !AppTheme.isTargetLunaR_OR_Nevo(){
            clockBackGroundView.backgroundColor = UIColor.getGreyColor()
            mClockTimerView = ClockView(frame:CGRect(x: 0, y: 0, width: clockBackGroundView.bounds.width, height: clockBackGroundView.bounds.width), hourImage:  UIImage(named: "wacth_hour")!, minuteImage: UIImage(named: "wacth_mint")!, dialImage: UIImage(named: "wacth_dial")!)
        }else{
            mClockTimerView = ClockView(frame:CGRect(x: 0, y: 0, width: clockBackGroundView.bounds.width, height: clockBackGroundView.bounds.width), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!)
        }
        
        
        mClockTimerView?.currentTimer()
        clockBackGroundView.addSubview(mClockTimerView!)
        
        progressView.frame = CGRect(x: clockBackGroundView.frame.origin.x-3, y: clockBackGroundView.frame.origin.y-3, width: clockBackGroundView.bounds.width+6, height: clockBackGroundView.bounds.width+6)
        progressView.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        progressView.setProgress(0.0)
        //self.view.layer.addSublayer(progressView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK: - ButtonManagerCallBack
    func controllManager(_ sender:AnyObject) {

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

// MARK: - Data calculation
extension StepGoalSetingController {
    
    func calculationData(_ activeTimer:Int,steps:Int,completionData:((_ miles:String,_ calories:String) -> Void)) {
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
        //Formula's = (2.0 X persons KG X 3.5)/200 = calories per minute
        let calories:Double = (2.0*userWeight*3.5)/200*Double(activeTimer)
        completionData(String(format: "%.2f",miles), String(format: "%.2f",calories))
    }
}

// MARK: - SyncControllerDelegate
extension StepGoalSetingController {
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
}

extension StepGoalSetingController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: (UIScreen.main.bounds.size.width)/2.0, height: collectionView.frame.size.height/2 - 10)
    }
    
    // MARK: - UICollectionViewDataSource
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
            cell.valueLabel.text = "\(contentTArray[(indexPath as NSIndexPath).row]) H"
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
