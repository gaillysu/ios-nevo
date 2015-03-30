//
//  HomeController.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import UIKit

/*
Controller of the Home Screen,
it should handle very little, only the initialisation of the different Views and the Sync Controller
*/

class HomeController: UIViewController, SyncControllerDelegate ,ButtonManagerCallBack{
    
    @IBOutlet var homeView: HomeView!
    private var sync:SyncController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        homeView.bulidHomeView(self)

        let timer:NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"timerAction:", userInfo: nil, repeats: true);
        
        //TEST this is for test. pls not to remove it 
//                var tapAction = UITapGestureRecognizer(target: self, action: "gotoProfileScreen")
//                tapAction.numberOfTapsRequired = 4
//                tapAction.numberOfTouchesRequired = 2
//                homeView.addGestureRecognizer(tapAction)
        //end TEST

    }

    override func viewDidAppear(animated: Bool) {
        
        if !ConnectionControllerImpl.sharedInstance.hasSavedAddress() {
            
            NSLog("No saved device, let's launch the tutorial")
            
            self.performSegueWithIdentifier("Home_Tutorial", sender: self)
            
        } else {
            if(sync == nil)
            {
               NSLog("We have a saved address, no need to go through the tutorial")
               sync  = SyncController.sharedInstance
               sync?.startConnect(false, delegate: self)
            }
            NSLog("We getGoal in home screen")
            SyncController.sharedInstance.getGoal()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject) {
        if sender.isEqual(homeView.settingButton) {
            self.performSegueWithIdentifier("Home_Seting", sender: self)
        }
    }

    func timerAction(NSTimer) {
        homeView.getClockTimerView().currentTimer()
    }

    
    /**
    
    goto profileTest screen.
    */
    func gotoProfileScreen(){
//        self.performSegueWithIdentifier("Home_profile", sender: self)
        self.performSegueWithIdentifier("Home_nevoOta", sender: self)
    }

    /**

    See SyncControllerDelegate
    
    */
    func packetReceived(packet:NevoPacket) {
        
        if packet.getHeader() == GetStepsGoalRequest.HEADER()
        {
            var thispacket = packet.copy() as DailyStepsNevoPacket
            
            var dailySteps:Int = thispacket.getDailySteps()
            var dailyStepGoal:Int = thispacket.getDailyStepsGoal()
            
            let numberOfSteps = NSUserDefaults.standardUserDefaults().objectForKey("NUMBER_OF_STEPS_GOAL_KEY") as? Int
            
            var percent :Float = Float(dailySteps)/Float(dailyStepGoal)
            
            NSLog("get Daily Steps is: \(dailySteps), getDaily Goal is: \(dailyStepGoal), saved Goal is:\(numberOfSteps),percent is: \(percent)")
            
            homeView.setProgress(percent, dailySteps: dailySteps, dailyStepGoal: dailyStepGoal)
        }
    }

    func connectionStateChanged(isConnected: Bool) {
        //NOTHING to do here
    }
}
