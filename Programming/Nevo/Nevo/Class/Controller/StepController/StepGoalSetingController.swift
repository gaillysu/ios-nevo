//
//  StepGoalSetingController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit


let NUMBER_OF_STEPS_GOAL_KEY = "NUMBER_OF_STEPS_GOAL_KEY"

class StepGoalSetingController: PublicClassController,ButtonManagerCallBack,SyncControllerDelegate,ClockRefreshDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet var stepGoalView: StepGoalSetingView!
    let StepsGoalKey:String = "ADYSTEPSGOALKEY"
    
    private var mCurrentGoal:Goal = NumberOfStepsGoal()
    private var mVisiable:Bool = true
    private var contentTitleArray:[String] = []
    private var contentTArray:[String] = ["0","0","0"]
    var shouldSync = false;
    init() {
        super.init(nibName: "StepGoalSetingController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentTitleArray = [NSLocalizedString("goal", comment: ""), NSLocalizedString("progress", comment: ""), NSLocalizedString("you_reached", comment: "")]
        ClockRefreshManager.sharedInstance.setRefreshDelegate(self)

        let local:LocalNotification = LocalNotification.sharedInstance()
        local.scheduleNotificationWithKey(NevoAllKeys.LocalStartSportKey(), title: "Today's activity", message: "Today's activity level haven't reach your goals", date: NSDate.date(year: NSDate().year, month: NSDate().month, day: NSDate().day, hour: 13, minute: 0, second: 0) , userInfo: nil)
    }

    override func viewDidLayoutSubviews() {
        stepGoalView.bulidStepGoalView(self,navigation: self.navigationItem)
        stepGoalView.collectionView?.delegate = self
        stepGoalView.collectionView?.dataSource = self

        let dataArray:NSArray = AppTheme.LoadKeyedArchiverName(StepsGoalKey) as! NSArray
        if(dataArray.count>0) {
            let date:NSTimeInterval = (dataArray[1] as! String).dateFromFormat("YYYY/MM/dd")!.timeIntervalSince1970
            if(date != NSDate.date(year: NSDate().year, month: NSDate().month, day: NSDate().day).timeIntervalSince1970){ return }

            contentTArray = (AppTheme.LoadKeyedArchiverName(StepsGoalKey) as! NSArray)[0] as! [String]
            let dailyStepGoal:Int = NSString(string: contentTArray[0]).integerValue
            let dailySteps:Int = NSString(string: contentTArray[2]).integerValue
            let percent:Float = NSString(string: contentTArray[1].stringByReplacingOccurrencesOfString("%", withString: "")).floatValue/100.0
            stepGoalView.setProgress(percent, dailySteps: dailySteps, dailyStepGoal: dailyStepGoal)
            stepGoalView.collectionView.reloadData()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject) {

    }

    // MARK: - ClockRefreshDelegate
    func clockRefreshAction(){
        stepGoalView.getClockTimerView().currentTimer()
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        let labelheight:CGFloat = cell.contentView.frame.size.height
        let titleView = cell.contentView.viewWithTag(1500)
        let iphone:Bool = AppTheme.GET_IS_iPhone5S()
        if(titleView == nil){
            let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, cell.contentView.frame.size.width, labelheight/2.0))
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.textColor = UIColor.grayColor()
            titleLabel.backgroundColor = UIColor.clearColor()
            titleLabel.font = AppTheme.FONT_SFUIDISPLAY_REGULAR(mSize: iphone ? 12:15)
            titleLabel.tag = 1500
            titleLabel.text = contentTitleArray[indexPath.row]
            titleLabel.sizeToFit()
            cell.contentView.addSubview(titleLabel)
            titleLabel.center = CGPointMake(cell.contentView.frame.size.width/2.0, labelheight/2.0-titleLabel.frame.size.height)
        }else {
            let titleLabel:UILabel = titleView as! UILabel
            titleLabel.text = contentTitleArray[indexPath.row]
            titleLabel.sizeToFit()
            titleLabel.center = CGPointMake(cell.contentView.frame.size.width/2.0, labelheight/2.0-titleLabel.frame.size.height)
        }

        let contentView = cell.contentView.viewWithTag(1700)
        if(contentView == nil){
            let contentStepsView:UILabel = UILabel(frame: CGRectMake(0, labelheight/2.0, cell.contentView.frame.size.width, labelheight/2.0))
            contentStepsView.textAlignment = NSTextAlignment.Center
            contentStepsView.backgroundColor = UIColor.clearColor()
            contentStepsView.textColor = UIColor.blackColor()
            contentStepsView.font = AppTheme.FONT_SFUIDISPLAY_REGULAR(mSize: iphone ? 15:18)
            contentStepsView.tag = 1700
            contentStepsView.text = "\(contentTArray[indexPath.row])"
            contentStepsView.sizeToFit()
            cell.contentView.addSubview(contentStepsView)
            contentStepsView.center = CGPointMake(cell.contentView.frame.size.width/2.0,labelheight/2.0+contentStepsView.frame.size.height/2.0)
        }else {
            let contentStepsView:UILabel = contentView as! UILabel
            contentStepsView.text = "\(contentTArray[indexPath.row])"
            contentStepsView.sizeToFit()
            contentStepsView.center = CGPointMake(cell.contentView.frame.size.width/2.0,labelheight/2.0+contentStepsView.frame.size.height/2.0)
        }
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

            stepGoalView.collectionView?.reloadData()
            stepGoalView.setProgress(percent, dailySteps: dailySteps, dailyStepGoal: dailyStepGoal)
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
            self.stepGoalView.getClockTimerView().setClockImage(AppTheme.GET_RESOURCES_IMAGE("clockview600_color"))
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.stepGoalView.getClockTimerView().setClockImage(AppTheme.GET_RESOURCES_IMAGE("clockView600"))
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
