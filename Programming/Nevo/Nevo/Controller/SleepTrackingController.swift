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

class SleepTrackingController: UIViewController, SyncControllerDelegate ,ButtonManagerCallBack,ClockRefreshDelegate{
    @IBOutlet weak var sleepView: SleepTrackingView!
    private var sync:SyncController?
    private var mVisiable:Bool = false
    private var sleepArray:NSMutableArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()

        ClockRefreshManager.sharedInstance.setRefreshDelegate(self)

        sleepView.bulidHomeView(self)

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
        sleepView.getClockTimerView().currentTimer()
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject) {
        if sender.isEqual(sleepView.settingButton) {
            self.performSegueWithIdentifier("Home_Seting", sender: self)
        }
        
        if sender.isEqual(sleepView.animationView.getNoConnectScanButton()) {
            AppTheme.DLog("noConnectScanButton")
            reconnect()
        }

        if sender.isEqual(sleepView.pushButton){
            let quer:QueryHistoricalController = QueryHistoricalController()
            self.presentViewController(quer, animated: true, completion:nil)
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

        if(packet.getHeader() == ReadDailyTracker.HEADER()) {
            let today:NSDate  = NSDate()
            let dateFormatter:NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let currentDateStr:NSString = dateFormatter.stringFromDate(today)

            let thispacket:DailyTrackerNevoPacket = packet.copy() as DailyTrackerNevoPacket
            if(currentDateStr.integerValue == thispacket.getDateTimer()){
                let dataArray:[[Int]] = [thispacket.getHourlySleepTime(),thispacket.getHourlyWakeTime(),thispacket.getHourlyLightTime(),thispacket.getHourlyDeepTime()]
                if(sleepArray.count==0){
                    sleepArray.addObject(dataArray)
                }else{
                    sleepArray.insertObject(dataArray, atIndex: 1)
                }
                //daysleepSave.HourlySleepTime = AppTheme.toJSONString(thispacket.getHourlySleepTime())
                //daysleepSave.HourlyWakeTime = AppTheme.toJSONString(thispacket.getHourlyWakeTime())
                //daysleepSave.HourlyLightTime = AppTheme.toJSONString(thispacket.getHourlyLightTime())
                //daysleepSave.HourlyDeepTime = AppTheme.toJSONString(thispacket.getHourlyDeepTime())
            }

            if(currentDateStr.integerValue-1 == thispacket.getDateTimer()){
                let dataArray:[[Int]] = [thispacket.getHourlySleepTime(),thispacket.getHourlyWakeTime(),thispacket.getHourlyLightTime(),thispacket.getHourlyDeepTime()]
                if(sleepArray.count==0){
                    sleepArray.addObject(dataArray)
                }else{
                    sleepArray.insertObject(dataArray, atIndex: 0)
                }
            }

            if(sleepArray.count==2){
                
                sleepView.setProgress(sleepArray,dataColor:[UIColor.greenColor().CGColor,UIColor.grayColor().CGColor,UIColor.orangeColor().CGColor])
            }
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
            for view in sleepView.subviews {
                let anView:UIView = view
                if anView.isEqual(sleepView.animationView.bulibNoConnectView()) {
                    isView = true
                }
            }
            if !isView {
                sleepView.addSubview(sleepView.animationView.bulibNoConnectView())
                reconnect()
            }
        } else {
            
            sleepView.animationView.endConnectRemoveView()
        }
        self.view.bringSubviewToFront(sleepView.titleBgView)
    }
    
    func reconnect() {
        sleepView.animationView.RotatingAnimationObject(sleepView.animationView.getNoConnectImage()!)
        sync?.connect()
    }
}
