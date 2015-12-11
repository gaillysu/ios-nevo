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

class SleepTrackingController: PublicClassController, SyncControllerDelegate ,ButtonManagerCallBack,ClockRefreshDelegate{
    @IBOutlet weak var sleepView: SleepTrackingView!
    private var mVisiable:Bool = false

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "SleepTrackingController", bundle: NSBundle.mainBundle())

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ClockRefreshManager.sharedInstance.setRefreshDelegate(self)

        sleepView.bulidHomeView(self)

        if(NSUserDefaults.standardUserDefaults().boolForKey("firstLaunch")){
            let page7:Page7Controller = Page7Controller()
            self.presentViewController(page7, animated: true, completion: { () -> Void in
                
            })
        }

    }

    override func viewDidAppear(animated: Bool) {
        //todaySleepArray: sync!.GET_TodaySleepData()
        if !AppDelegate.getAppDelegate().getMconnectionController().hasSavedAddress() {
            AppTheme.DLog("No saved device, let's launch the tutorial")
        } else {
            AppTheme.DLog("We have a saved address, no need to go through the tutorial")
            AppDelegate.getAppDelegate().startConnect(false, delegate: self)
            checkConnection()
            mVisiable = true
        }

        if(AppDelegate.getAppDelegate().GET_TodaySleepData().count == 2){
            sleepView.setProgress(AppDelegate.getAppDelegate().GET_TodaySleepData())
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
        sleepView.getClockTimerView().currentTimer()
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject) {

        if sender.isEqual(sleepView.historyButton){
            let quer:SleepHistoricalViewController = SleepHistoricalViewController()
            self.presentViewController(quer, animated: true, completion:nil)
        }

        if sender.isEqual(sleepView.infoButton) {
            let page7:Page7Controller = Page7Controller()
            self.presentViewController(page7, animated: true, completion: { () -> Void in

            })
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
    // MARK: - SyncControllerDelegate
    func packetReceived(packet:NevoPacket) {

        if packet.getHeader() == LedLightOnOffNevoRequest.HEADER()
        {
            AppTheme.DLog("end handshake nevo");
            //blink once Clock
            self.sleepView.getClockTimerView().setClockImage(AppTheme.GET_RESOURCES_IMAGE("clockview600_color"))
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
              self.sleepView.getClockTimerView().setClockImage(AppTheme.GET_RESOURCES_IMAGE("clockView600"))
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

    func syncFinished(){
        if(AppDelegate.getAppDelegate().GET_TodaySleepData().count==2){
            sleepView.setProgress(AppDelegate.getAppDelegate().GET_TodaySleepData())
        }
    }

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
}
