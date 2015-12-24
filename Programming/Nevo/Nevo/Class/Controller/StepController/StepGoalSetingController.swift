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
    
    private var mCurrentGoal:Goal = NumberOfStepsGoal()
    private var mVisiable:Bool = true
    private var myHud:SyncBar = SyncBar.getSyncBar()
    private var contentTitleArray:[String] = []
    private var contentTArray:[String] = ["0","0","0","0","0","0"]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "StepGoalSetingController", bundle: NSBundle.mainBundle())

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myHud.setStatusLabel("Syncing nevo")
        myHud.showHudAddedToView(self.view)

        contentTitleArray = [NSLocalizedString("goal", comment: ""), NSLocalizedString("you_reached", comment: ""), NSLocalizedString("progress", comment: ""), NSLocalizedString("all_day_mileage", comment: ""), NSLocalizedString("all_day_steps", comment: ""), NSLocalizedString("all_day_consume", comment: "")]
        
        AppDelegate.getAppDelegate().startConnect(false, delegate: self)

        stepGoalView.bulidStepGoalView(self,navigation: self.navigationItem)
        stepGoalView.collectionView?.delegate = self
        stepGoalView.collectionView?.dataSource = self

        ClockRefreshManager.sharedInstance.setRefreshDelegate(self)
        
        if let numberOfSteps = NSUserDefaults.standardUserDefaults().objectForKey(NUMBER_OF_STEPS_GOAL_KEY) as? Int {
            setGoal(NumberOfStepsGoal(steps: numberOfSteps))
        } else {
            setGoal(NumberOfStepsGoal(intensity: GoalIntensity.LOW))
        }

    }

    override func viewDidLayoutSubviews() {
        
    }

    override func viewDidAppear(animated: Bool) {
        checkConnection()

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
        if mVisiable{
            AppDelegate.getAppDelegate().getGoal()
        }
    }

     // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath)
        let titleView = cell.contentView.viewWithTag(1500)
        if(titleView == nil){
            let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height/3.0))
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.textColor = UIColor.grayColor()
            titleLabel.backgroundColor = UIColor.whiteColor()
            titleLabel.font = UIFont.systemFontOfSize((cell.contentView.frame.size.height/3.0)*0.6)
            titleLabel.tag = 1500
            titleLabel.text = contentTitleArray[indexPath.row]
            cell.contentView.addSubview(titleLabel)
        }else {
             let titleLabel:UILabel = titleView as! UILabel
            titleLabel.text = contentTitleArray[indexPath.row]
        }

        let contentView = cell.contentView.viewWithTag(1700)
        if(contentView == nil){
            let contentStepsView:UILabel = UILabel(frame: CGRectMake(0, cell.contentView.frame.size.height/3.0, cell.contentView.frame.size.width, (cell.contentView.frame.size.height/3.0)*2.0))
            contentStepsView.textAlignment = NSTextAlignment.Center
            contentStepsView.backgroundColor = UIColor.whiteColor()
            contentStepsView.font = UIFont.systemFontOfSize((cell.contentView.frame.size.height/3.0)*0.9)
            contentStepsView.tag = 1700
            contentStepsView.text = "\(contentTArray[indexPath.row])"
            cell.contentView.addSubview(contentStepsView)
        }else {
            let contentStepsView:UILabel = contentView as! UILabel
            contentStepsView.text = "\(contentTArray[indexPath.row])"
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

            let userDefaults = NSUserDefaults.standardUserDefaults();
            userDefaults.setObject(dailyStepGoal,forKey:NUMBER_OF_STEPS_GOAL_KEY)
            userDefaults.synchronize()
            let percent :Float = Float(dailySteps)/Float(dailyStepGoal)

            AppTheme.DLog("get Daily Steps is: \(dailySteps), getDaily Goal is: \(dailyStepGoal),percent is: \(percent)")

            contentTArray.removeAtIndex(0)
            contentTArray.insert("\(dailyStepGoal)steps", atIndex: 0)
            contentTArray.removeAtIndex(1)
            contentTArray.insert("\(dailySteps)steps", atIndex: 1)
            contentTArray.removeAtIndex(2)
            contentTArray.insert(String(format: "%.2f%c", percent*100,37), atIndex: 2)
            stepGoalView.collectionView?.reloadData()

            stepGoalView.setProgress(percent, dailySteps: dailySteps, dailyStepGoal: dailyStepGoal)
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
        myHud.hideFromView(self.view)
    }

    // MARK: - StepGoalSetingController function
    /**
    Checks if any device is currently connected
    */
    func checkConnection() {

        if !AppDelegate.getAppDelegate().isConnected() {
            //We are currently not connected
            reconnect()
            
            if(!myHud.isHudView()) {
                myHud.showHudAddedToView(self.view)
            }
            myHud.setStatusLabel("Disconnect nevo")
        }
    }

    func reconnect() {
        AppDelegate.getAppDelegate().connect()
    }

    func setGoal(goal:Goal) {
        mCurrentGoal = goal

        let userDefaults = NSUserDefaults.standardUserDefaults();

        userDefaults.setObject(goal.getValue(),forKey:NUMBER_OF_STEPS_GOAL_KEY)
        userDefaults.synchronize()
        AppDelegate.getAppDelegate().setGoal(goal)
    }
}
