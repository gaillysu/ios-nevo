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
    private var mClockTimerView:ClockView?;//init "ClockView" ,Use the code relative layout
    var progressView:NevoCircleProgressView = NevoCircleProgressView()
    var progresValue:CGFloat = 0.0
    
    let StepsGoalKey:String = "ADYSTEPSGOALKEY"
    
    private var mCurrentGoal:Goal = NumberOfStepsGoal()
    private var mVisiable:Bool = true
    private var contentTitleArray:[String] = [NSLocalizedString("CALORIE", comment: ""), NSLocalizedString("STEPS", comment: ""), NSLocalizedString("TIME", comment: ""),NSLocalizedString("KM", comment: "")]
    private var contentTArray:[String] = ["0","0","0","0"]
    var shouldSync = false;
    init() {
        super.init(nibName: "StepGoalSetingController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ClockRefreshManager.sharedInstance.setRefreshDelegate(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self, name: SELECTED_CALENDAR_NOTIFICATION)
        SwiftEventBus.unregister(self, name: EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake((UIScreen.mainScreen().bounds.size.width)/2.0, 40)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        collectionView.registerNib(UINib(nibName: "StepGoalSetingViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "StepGoalSetingIdentifier")
        collectionView?.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView?.backgroundColor = UIColor.whiteColor()
        bulidClockViewandProgressBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        saveContentTArray(NSDate().beginningOfDay.timeIntervalSince1970)
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY) { (notification) in
            let dict:[String:AnyObject] = notification.object as! [String:AnyObject]
            let dailySteps:Int = dict["STEPS"] as! Int
            self.contentTArray.replaceRange(Range(1..<2), with: ["\(dailySteps)"])
            self.calculationData(0, steps: dailySteps, completionData: { (miles, calories) in
                self.contentTArray.replaceRange(Range(3..<4), with: ["\(miles)"])
            })
            self.collectionView.reloadData()
        }
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            self.saveContentTArray(NSDate().beginningOfDay.timeIntervalSince1970)
        }
        
        SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            let userinfo:NSDate = notification.userInfo!["selectedDate"] as! NSDate
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
                XCGLogger.defaultInstance().debug("end handshake nevo");
                //blink once Clock
            }
        }
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) in
            self.checkConnection()
        }
        
        if(!AppDelegate.getAppDelegate().hasSavedAddress()) {
            let tutorialOne:TutorialOneViewController = TutorialOneViewController()
            let nav:UINavigationController = UINavigationController(rootViewController: tutorialOne)
            nav.navigationBarHidden = true
            self.presentViewController(nav, animated: true, completion: nil)
        }else{
            AppDelegate.getAppDelegate().startConnect(false)
        }
    }
    
    /**
     GET Archiver "contentTArray"
     */
    func getContentTArray() {
        let dataArray:NSArray = AppTheme.LoadKeyedArchiverName(StepsGoalKey) as! NSArray
        if(dataArray.count>0) {
            let date:NSTimeInterval = (dataArray[1] as! String).dateFromFormat("YYYY/MM/dd")!.timeIntervalSince1970
            if(date != NSDate.date(year: NSDate().year, month: NSDate().month, day: NSDate().day).timeIntervalSince1970){ return }
            
            contentTArray = (AppTheme.LoadKeyedArchiverName(StepsGoalKey) as! NSArray)[0] as! [String]
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
    func saveContentTArray(beginningDate:NSTimeInterval) {
        //Only for today's data
        let array:NSArray = UserSteps.getCriteria("WHERE date = \(beginningDate)")
        if array.count>0 {
            let dataSteps:UserSteps = array[0] as! UserSteps
            
            self.contentTArray.replaceRange(Range(1..<2), with: ["\(dataSteps.steps)"])
             self.contentTArray.replaceRange(Range(2..<3), with: [String(format: "%.2f", Float(dataSteps.walking_duration+dataSteps.running_duration)/60.0)])
            self.calculationData((dataSteps.walking_duration+dataSteps.running_duration), steps: dataSteps.steps, completionData: { (miles, calories) in
                self.contentTArray.replaceRange(Range(0..<1), with: ["\(calories)"])
                self.contentTArray.replaceRange(Range(3..<4), with: ["\(miles)"])
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
        
        mClockTimerView = ClockView(frame:CGRectMake(0, 0, clockBackGroundView.bounds.width, clockBackGroundView.bounds.width), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!)
        mClockTimerView?.currentTimer()
        clockBackGroundView.addSubview(mClockTimerView!)
        
        progressView.frame = CGRectMake(clockBackGroundView.frame.origin.x-3, clockBackGroundView.frame.origin.y-3, clockBackGroundView.bounds.width+6, clockBackGroundView.bounds.width+6)
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
    func setProgress(progress: Float,dailySteps:Int,dailyStepGoal:Int){
        progresValue = CGFloat(progress)
        progressView.setProgress(progresValue, Steps: dailySteps, GoalStep: dailyStepGoal)
    }
    
    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject) {

    }

    // MARK: - ClockRefreshDelegate
    func clockRefreshAction(){
        mClockTimerView?.currentTimer()
        if AppDelegate.getAppDelegate().isConnected() {
            AppDelegate.getAppDelegate().getGoal()
            XCGLogger.defaultInstance().debug("getGoalRequest")
        }
    }

}

// MARK: - Data calculation
extension StepGoalSetingController {
    
    func calculationData(activeTimer:Int,steps:Int,completionData:((miles:String,calories:String) -> Void)) {
        let profile:NSArray = UserProfile.getAll()
        var userProfile:UserProfile?
        var strideLength:Double = 0
        var userWeight:Double = 0
        if profile.count>0 {
            userProfile = profile.objectAtIndex(0) as? UserProfile
            strideLength = Double(userProfile!.length)*0.415/100
            userWeight = Double(userProfile!.weight)
        }else{
            strideLength = Double(170)*0.415/100
            userWeight = 65
        }
        
        let miles:Double = strideLength*Double(steps)/1000
        //Formula's = (2.0 X persons KG X 3.5)/200 = calories per minute
        let calories:Double = (2.0*userWeight*3.5)/200*Double(activeTimer)
        completionData(miles: String(format: "%.2f",miles), calories: String(format: "%.2f",calories))
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
    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentTitleArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:StepGoalSetingViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("StepGoalSetingIdentifier", forIndexPath: indexPath) as! StepGoalSetingViewCell
        cell.titleLabel.text = contentTitleArray[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.valueLabel.text = "\(contentTArray[indexPath.row]) Cal"
            break;
        case 1:
            cell.valueLabel.text = "\(contentTArray[indexPath.row])"
            break;
        case 2:
            cell.valueLabel.text = "\(contentTArray[indexPath.row]) H"
            break;
        case 3:
            cell.valueLabel.text = "\(contentTArray[indexPath.row]) KM"
            break;
        default:
            break;
        }
        
        return cell
    }
}