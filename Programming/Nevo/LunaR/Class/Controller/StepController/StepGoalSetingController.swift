//
//  StepGoalSetingController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import SwiftEventBus


let NUMBER_OF_STEPS_GOAL_KEY = "NUMBER_OF_STEPS_GOAL_KEY"

class StepGoalSetingController: PublicClassController,ButtonManagerCallBack,SyncControllerDelegate,ClockRefreshDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var clockBackGroundView: UIView!
    @IBOutlet weak var collectionView:UICollectionView!
    //Put all UI operation HomeView inside
    private var mClockTimerView:ClockView?;//init "ClockView" ,Use the code relative layout
    var progressView:CircleProgressView = CircleProgressView()
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
        let local:LocalNotification = LocalNotification.sharedInstance()
        local.scheduleNotificationWithKey(NevoAllKeys.LocalStartSportKey(), title: "Today's activity", message: "Today's activity level haven't reach your goals", date: NSDate.date(year: NSDate().year, month: NSDate().month, day: NSDate().day, hour: 13, minute: 0, second: 0) , userInfo: nil)
        
        ClockRefreshManager.sharedInstance.setRefreshDelegate(self)
        
        SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self, name: SELECTED_CALENDAR_NOTIFICATION)
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
        collectionView?.backgroundColor = UIColor(rgba: "#54575a")
        
        bulidClockViewandProgressBar()
        self.view.backgroundColor = UIColor(rgba: "#54575a")
        let dataArray:NSArray = AppTheme.LoadKeyedArchiverName(StepsGoalKey) as! NSArray
        if(dataArray.count>0) {
            let date:NSTimeInterval = (dataArray[1] as! String).dateFromFormat("YYYY/MM/dd")!.timeIntervalSince1970
            if(date != NSDate.date(year: NSDate().year, month: NSDate().month, day: NSDate().day).timeIntervalSince1970){ return }

            contentTArray = (AppTheme.LoadKeyedArchiverName(StepsGoalKey) as! NSArray)[0] as! [String]
            let dailyStepGoal:Int = NSString(string: contentTArray[0]).integerValue
            let dailySteps:Int = NSString(string: contentTArray[2]).integerValue
            let percent:Float = NSString(string: contentTArray[1].stringByReplacingOccurrencesOfString("%", withString: "")).floatValue/100.0
            self.setProgress(percent, dailySteps: dailySteps, dailyStepGoal: dailyStepGoal)
            collectionView?.reloadData()
        }

    }

    override func viewWillAppear(animated: Bool) {
        if(!AppDelegate.getAppDelegate().hasSavedAddress()) {
            let tutrorial:HomeTutorialController = HomeTutorialController()
            let nav:UINavigationController = UINavigationController(rootViewController: tutrorial)
            nav.navigationBarHidden = true
            self.presentViewController(nav, animated: true, completion: nil)
        }else{
            AppDelegate.getAppDelegate().startConnect(false, delegate: self)
        }
    }

    func bulidClockViewandProgressBar() {
        for view in clockBackGroundView.subviews {
            if view is ClockView {
                view.removeFromSuperview()
            }
        }
        mClockTimerView = ClockView(frame:CGRectMake(0, 0, clockBackGroundView.bounds.width, clockBackGroundView.bounds.width), hourImage:  UIImage(named: "wacth_hour")!, minuteImage: UIImage(named: "wacth_mint")!, dialImage: UIImage(named: "wacth_dial")!)
        mClockTimerView?.currentTimer()
        clockBackGroundView.addSubview(mClockTimerView!)
        
        progressView.frame = CGRectMake(clockBackGroundView.frame.origin.x-3, clockBackGroundView.frame.origin.y-3, clockBackGroundView.bounds.width+6, clockBackGroundView.bounds.width+6)
        progressView.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        progressView.setProgress(0.0)
        self.view.layer.addSublayer(progressView)
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
            if shouldSync{
                AppDelegate.getAppDelegate().getGoal()
            }
        }
    }

     // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentTitleArray.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StepGoalSetingIdentifier", forIndexPath: indexPath)
        //cell.backgroundColor = UIColor.clearColor()
        (cell as! StepGoalSetingViewCell).titleLabel.text = contentTitleArray[indexPath.row]
        (cell as! StepGoalSetingViewCell).valueLabel.text = "\(contentTArray[indexPath.row])"

        return cell
    }

    // MARK: - SyncControllerDelegate
    func packetReceived(packet:NevoPacket) {
        //Do nothing
        if packet.getHeader() == GetStepsGoalRequest.HEADER(){
            let thispacket = packet.copy() as DailyStepsNevoPacket
            let dailySteps:Int = thispacket.getDailySteps()
            let dailyStepGoal:Int = thispacket.getDailyStepsGoal()
            let percent :Float = Float(dailySteps)/Float(dailyStepGoal)

            AppTheme.DLog("get Daily Steps is: \(dailySteps), getDaily Goal is: \(dailyStepGoal),percent is: \(percent)")
            contentTArray.removeAll()
            contentTArray.insert("\(dailyStepGoal)", atIndex: 0)
            contentTArray.insert(String(format: "%.2f%c", percent*100,37), atIndex: 1)
            contentTArray.insert("\(dailySteps)", atIndex: 2)

            collectionView.reloadData()
            self.setProgress(percent, dailySteps: dailySteps, dailyStepGoal: dailyStepGoal)
            
            AppTheme.KeyedArchiverName(StepsGoalKey, andObject: contentTArray)
            if(dailySteps>=dailyStepGoal) {
                LocalNotification.sharedInstance().cancelNotification([NevoAllKeys.LocalEndSportKey()])
                let local:LocalNotification = LocalNotification.sharedInstance()
                local.scheduleNotificationWithKey(NevoAllKeys.LocalEndSportKey(), title: "Today's activity", message: "Today's activity level has reached your preset goals", date: NSDate.date(year: NSDate().year, month: NSDate().month, day: NSDate().day, hour: 19, minute: 0, second: 0) , userInfo: nil)
            }
        }

        if packet.getHeader() == LedLightOnOffNevoRequest.HEADER(){
            AppTheme.DLog("end handshake nevo");
            //blink once Clock
            mClockTimerView?.setClockImage(AppTheme.GET_RESOURCES_IMAGE("clockview600_color"))
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.mClockTimerView?.setClockImage(AppTheme.GET_RESOURCES_IMAGE("clockView600"))
            })
        }
        
    }
    
    func connectionStateChanged(isConnected : Bool) {
        //Maybe we just got disconnected, let's check
        checkConnection()
    }
    
    /**
     *  Receiving the current device signal strength value
     */
    func receivedRSSIValue(number:NSNumber){

    }
    /**
     *  Data synchronization is complete callback
     */
    func syncFinished(){

    }

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
