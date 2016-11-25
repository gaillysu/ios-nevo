//
//  AppDelegate-Extension.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/8.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import XCGLogger
import SwiftEventBus

// MARK: - LAUNCH LOGIC
extension AppDelegate {
    
    // MARK: -AppDelegate SET Function
    func setRTC() {
        sendRequest(SetRTCRequest())
    }
    
    func SetProfile() {
        sendRequest(SetProfileRequest())
    }
    
    func SetCardio() {
        sendRequest(SetCardioRequest())
    }
    
    func WriteSetting() {
        sendRequest(WriteSettingRequest())
    }
    
    func setGoal(_ goal:Goal) {
        sendRequest(SetGoalRequest(goal: goal))
    }
    
    func setAlarm(_ alarm:[Alarm]) {
        sendRequest(SetAlarmRequest(alarm:alarm))
    }
    
    func setNewAlarm(_ alarm:NewAlarm) {
        sendRequest(SetNewAlarmRequest(alarm:alarm))
    }
    
    func SetNortification(_ notfication:[NotificationSetting]) {
        XCGLogger.default.debug("SetNortification")
        sendRequest(SetNortificationRequest(settingArray: notfication))
    }
    
    func SetNortification() {
        XCGLogger.default.debug("SetNortification")
        var mNotificationSettingArray:[NotificationSetting] = []
        let mNotificationArray:[MEDUserNotification] = MEDUserNotification.getAll() as! [MEDUserNotification]
        for model in mNotificationArray{
            let notification:MEDUserNotification = model
            if notification.isAddWatch {
                let notificationType:String = notification.notificationType
                var type = NotificationType(rawValue: notificationType as NSString)
                if type == nil {
                    type = NotificationType.other
                }
                let setting:NotificationSetting = NotificationSetting(type: type!, clock: notification.clock, color: NSNumber(value:notification.clock), states:notification.isAddWatch)
                mNotificationSettingArray.append(setting)
            }
        }
        sendRequest(SetNortificationRequest(settingArray: mNotificationSettingArray))
    }
    
    func setSunriseAndSunset(sunrise:Date,sunset:Date) {
        sendRequest(SetSunriseAndSunsetRequest(sunrise: sunrise, sunset: sunset))
    }
    
    /**
     @ledpattern, define Led light pattern, 0 means off all led, 0xFFFFFF means light on all led( include color and white)
     0x7FF means light on all white led (bit0~bit10), 0x3F0000 means light on all color led (bit16~bit21)
     other value, light on the related led
     @motorOnOff, vibrator true or flase
     */
    func SetLedOnOffandVibrator(_ ledpattern:UInt32,  motorOnOff:Bool) {
        sendRequest(LedLightOnOffNevoRequest(ledpattern: ledpattern, motorOnOff: motorOnOff))
    }
    
    func startConnect(_ forceScan:Bool){
        if forceScan{
            self.getMconnectionController()?.forgetSavedAddress()
        }
        self.getMconnectionController()?.connect()
    }
    
    // MARK: -AppDelegate GET Function
    func getTodayTracker() {
        sendRequest(ReadDailyTracker(trackerno:0))
    }
    
    func  getDailyTrackerInfo(){
        sendRequest(ReadDailyTrackerInfo())
    }
    
    func  getDailyTracker(_ trackerno:UInt8){
        sendRequest(ReadDailyTracker(trackerno:trackerno))
    }
    
    func getGoal(){
        sendRequest(GetStepsGoalRequest())
    }
    
    
    func ReadBatteryLevel() {
        sendRequest(ReadBatteryLevelNevoRequest())
    }
    
    //Request the watch
    func getWatchNameRequest() {
        sendRequest(GetWatchName())
    }
    
    // MARK: -AppDelegate syncActivityData
    /**
     This function will syncrhonise activity data with the watch.
     It is a long process and hence shouldn't be done too often, so we save the date of previous sync.
     The watch should be emptied after all data have been saved.
     */
    func syncActivityData() {
        
        if( Date().timeIntervalSince1970-lastSync > SYNC_INTERVAL) {
            //We haven't synched for a while, let's sync now !
            XCGLogger.default.debug("*** Sync started ! ***")
            self.getDailyTrackerInfo()
            lastSync = Date().timeIntervalSince1970
            if(isConnected()) {
                let banner = MEDBanner(title: NSLocalizedString("syncing_data", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
            }
        }
    }
    
    /**
     When the sync process is finished, le't refresh the date of sync
     */
    func syncFinished() {
        let banner = MEDBanner(title: NSLocalizedString("sync_finished", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor(rgba:"#0dac67"))
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
        lastSync = Date().timeIntervalSince1970
        let userDefaults = UserDefaults.standard;
        userDefaults.set(Date().timeIntervalSince1970,forKey:LAST_SYNC_DATE_KEY)
        userDefaults.synchronize()
    }
    
    // MARK: - ConnectionController protocol
    func  getFirmwareVersion() -> NSString{
        return isConnected() ? self.getMconnectionController()!.getFirmwareVersion() : NSString()
    }
    
    func  getSoftwareVersion() -> NSString{
        return isConnected() ? self.getMconnectionController()!.getSoftwareVersion() : NSString()
    }
    
    func getWatchNameInfo() -> [String:Int] {
        return [self.getWatchName():self.getWactnID()];
    }
    
    func getWatchModelInfo() -> [String:Int] {
        return [self.getWatchModel():self.getWatchModelNumber()];
    }
    
    func setWatchInfo(_ id:Int,model:Int) {
        // id = 1-Nevo,2-Nevo Solar,3-Lunar,0xff-Nevo
        UserDefaults.standard.set(id, forKey: "WATCHNAME_KEY")
        UserDefaults.standard.synchronize()
        switch id {
        case 1:
            self.setWactnID(1)
            self.setWatchName("Nevo")
            break
        case 2:
            self.setWactnID(2)
            self.setWatchName("Nevo Solar")
            break
        case 3:
            self.setWactnID(3)
            self.setWatchName("Lunar")
            break
        default:
            self.setWactnID(1)
            self.setWatchName("Nevo")
            break
        }
        
        //model = 1 - Paris,2 - New York,3 - ShangHai
        switch model {
        case 1:
            self.setWatchModelNumber(1)
            self.setWatchModel("Paris")
            break
        case 2:
            self.setWatchModelNumber(2)
            self.setWatchModel("New York")
            break
        case 3:
            self.setWatchModelNumber(3)
            self.setWatchModel("ShangHai")
            break
        default:
            self.setWatchModelNumber(1)
            self.setWatchModel("Paris")
            break
        }
    }
    
    func connect() {
        self.getMconnectionController()?.connect()
    }
    
    func disconnect() {
        self.getMconnectionController()?.disconnect()
    }
    
    func forgetSavedAddress() {
        self.getMconnectionController()?.forgetSavedAddress()
    }
    
    func hasSavedAddress()->Bool {
        return self.getMconnectionController()!.hasSavedAddress()
    }
    
    func restoreSavedAddress() {
        self.getMconnectionController()?.restoreSavedAddress()
    }
    
    func isConnected() -> Bool{
        return self.getMconnectionController()!.isConnected()
        
    }
    
    func sendRequest(_ r:Request) {
        if(isConnected()){
            SyncQueue.sharedInstance.post( { (Void) -> (Void) in
                self.getMconnectionController()?.sendRequest(r)
                
            } )
        }else {
            //tell caller
            SwiftEventBus.post(EVENT_BUS_CONNECTION_STATE_CHANGED_KEY, sender:false as AnyObject)
        }
    }
    
    func adjustLaunchLogic() {
        let hasWatch:Bool = AppDelegate.getAppDelegate().hasSavedAddress()
        let isFirsttimeLaunch = AppDelegate.getAppDelegate().isFirsttimeLaunch
        if isFirsttimeLaunch {
            let naviController = UINavigationController(rootViewController: LoginController())
            AppDelegate.getAppDelegate().window? = UIWindow(frame: UIScreen.main.bounds)
            AppDelegate.getAppDelegate().window?.rootViewController = naviController
            AppDelegate.getAppDelegate().window?.makeKeyAndVisible()
        } else {
            if !hasWatch {
                let naviController:UINavigationController = UINavigationController(rootViewController: TutorialOneViewController())
                naviController.isNavigationBarHidden = true
                AppDelegate.getAppDelegate().window? = UIWindow(frame: UIScreen.main.bounds)
                AppDelegate.getAppDelegate().window?.rootViewController = naviController
                AppDelegate.getAppDelegate().window?.makeKeyAndVisible()
            }
        }
        
        /// Alter the entry of app here when testing a single module.
        /// 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧
        
//        AppDelegate.getAppDelegate().window? = UIWindow(frame: UIScreen.main.bounds)
//        AppDelegate.getAppDelegate().window?.rootViewController = SunriseSetController()
//        AppDelegate.getAppDelegate().window?.makeKeyAndVisible()
        
        /// 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧
    }
}
