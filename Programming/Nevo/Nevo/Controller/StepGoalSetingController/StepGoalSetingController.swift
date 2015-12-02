//
//  StepGoalSetingController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class StepGoalSetingController: PublicClassController,ButtonManagerCallBack,SyncControllerDelegate {
    
    let NUMBER_OF_STEPS_GOAL_KEY = "NUMBER_OF_STEPS_GOAL_KEY"

    @IBOutlet var stepGoalView: StepGoalSetingView!
    
    private var mCurrentGoal:Goal = NumberOfStepsGoal()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "StepGoalSetingController", bundle: NSBundle.mainBundle())

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppDelegate.getAppDelegate().startConnect(false, delegate: self)

        stepGoalView.bulidStepGoalView(self,navigation: self.navigationItem)
        
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
        if sender.isEqual(stepGoalView.getEnterButton()) {

            setGoal(NumberOfStepsGoal(steps: stepGoalView.getNumberOfStepsGoal()))

        }
    }

    // MARK: - SyncControllerDelegate
    func packetReceived(packet:NevoPacket) {
        //Do nothing
        if packet.getHeader() == GetStepsGoalRequest.HEADER(){
            let thispacket = packet.copy() as DailyStepsNevoPacket
            var dailySteps:Int = thispacket.getDailySteps()
            let dailyStepGoal:Int = thispacket.getDailyStepsGoal()

            let userDefaults = NSUserDefaults.standardUserDefaults();
            userDefaults.setObject(dailyStepGoal,forKey:NUMBER_OF_STEPS_GOAL_KEY)
            userDefaults.synchronize()
        }
        
    }
    
    func connectionStateChanged(isConnected : Bool) {
        //Maybe we just got disconnected, let's check
        //checkConnection()
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
            reconnect()
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
