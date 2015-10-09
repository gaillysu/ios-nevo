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

class HomeController: UIViewController, SyncControllerDelegate ,ButtonManagerCallBack,ClockRefreshDelegate{
    
    @IBOutlet var homeView: HomeView!
    private var sync:SyncController?
    private var mVisiable:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        homeView.bulidHomeView(self)

        ClockRefreshManager.sharedInstance.setRefreshDelegate(self)
        
        //TEST this is for test. pls not to remove it
                let tapAction = UITapGestureRecognizer(target: self, action: "testHandshake")
                tapAction.numberOfTapsRequired = 2
                homeView.addGestureRecognizer(tapAction)
        //end TEST

    }

    override func viewDidAppear(animated: Bool) {
        
        if !ConnectionControllerImpl.sharedInstance.hasSavedAddress() {
            
            AppTheme.DLog("No saved device, let's launch the tutorial")
            
            self.performSegueWithIdentifier("Home_Tutorial", sender: self)
            
        } else {
            if(sync == nil)
            {
               AppTheme.DLog("We have a saved address, no need to go through the tutorial")
               sync  = SyncController.sharedInstance
               sync?.startConnect(false, delegate: self)
            }
            checkConnection()
            //NSLog("We getGoal in home screen")
            //SyncController.sharedInstance.getGoal()
            mVisiable = true
        }

    }
    
    override func viewDidDisappear(animated: Bool) {
        mVisiable = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ClockRefreshDelegate
    func clockRefreshAction(){
        homeView.getClockTimerView().currentTimer()
        if mVisiable{
            SyncController.sharedInstance.getGoal()
        }
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject) {
        if sender.isEqual(homeView.settingButton) {
            self.performSegueWithIdentifier("Home_Seting", sender: self)
        }
        
        if sender.isEqual(homeView.animationView.getNoConnectScanButton()) {
            AppTheme.DLog("noConnectScanButton")
            reconnect()
        }

    }

    /**
    test communication is normal or not
    */
    func testHandshake(){
        if SyncController.sharedInstance.isConnected()
        {
            AppTheme.DLog("start handshake nevo");
            SyncController.sharedInstance.SetLedOnOffandVibrator(0x3F0000, motorOnOff: false)
        }
    }
    /**
    
    goto OTA screen.
    */
    func gotoOTAScreen(){
        self.performSegueWithIdentifier("Home_nevoOta", sender: self)
    }

    /**

    See SyncControllerDelegate
    
    */
    func packetReceived(packet:NevoPacket) {
        
        if packet.getHeader() == GetStepsGoalRequest.HEADER()
        {
            let thispacket = packet.copy() as DailyStepsNevoPacket
            
            let dailySteps:Int = thispacket.getDailySteps()
            let dailyStepGoal:Int = thispacket.getDailyStepsGoal()
            
            //sync the Goal
            let userDefaults = NSUserDefaults.standardUserDefaults();
            userDefaults.setObject(dailyStepGoal,forKey:"NUMBER_OF_STEPS_GOAL_KEY")
            userDefaults.synchronize()
            
            let percent :Float = Float(dailySteps)/Float(dailyStepGoal)
            
            AppTheme.DLog("get Daily Steps is: \(dailySteps), getDaily Goal is: \(dailyStepGoal),percent is: \(percent)")
            
            homeView.setProgress(percent, dailySteps: dailySteps, dailyStepGoal: dailyStepGoal)
        }
        else if packet.getHeader() == LedLightOnOffNevoRequest.HEADER()
        {
            AppTheme.DLog("end handshake nevo");
            //blink once Clock
            self.homeView.getClockTimerView().setClockImage(AppTheme.GET_RESOURCES_IMAGE("clockview600_color"))
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
              self.homeView.getClockTimerView().setClockImage(AppTheme.GET_RESOURCES_IMAGE("clockView600"))
            })
        }
    }

    /**
    See SyncControllerDelegate
    */
    func receivedRSSIValue(number:NSNumber){

    }

    func connectionStateChanged(isConnected: Bool) {
        //Maybe we just got disconnected, let's check
        
        checkConnection()
    }
    
    /**
    
    Checks if any device is currently connected
    
    */
    
    func checkConnection() {
        
        if sync != nil && !(sync!.isConnected()) {
            //We are currently not connected
            var isView:Bool = false
            for view in homeView.subviews {
                let anView:UIView = view
                if anView.isEqual(homeView.animationView.bulibNoConnectView()) {
                    isView = true
                }
            }
            if !isView {
                homeView.addSubview(homeView.animationView.bulibNoConnectView())
                reconnect()
            }
        } else {
            
            homeView.animationView.endConnectRemoveView()
        }
        self.view.bringSubviewToFront(homeView.titleBgView)
    }
    
    func reconnect() {
        homeView.animationView.RotatingAnimationObject(homeView.animationView.getNoConnectImage()!)
        sync?.connect()
    }
}
