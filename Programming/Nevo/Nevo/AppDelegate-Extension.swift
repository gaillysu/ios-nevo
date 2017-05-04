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
import Alamofire
import Solar
import RealmSwift

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
    
    func setNewAlarm() {
        print("Setting new alarm anyway")
        let lunarAlarm:[MEDUserAlarm] = MEDUserAlarm.getAll() as! [MEDUserAlarm]
        var weakAlarm:[MEDUserAlarm] = lunarAlarm.filter({$0.type == 0})
        var sleepAlarm:[MEDUserAlarm] = lunarAlarm.filter({$0.type == 1})
        
        if weakAlarm.count<7 {
            for _ in weakAlarm.count..<7 {
                let alarm:MEDUserAlarm = MEDUserAlarm()
                alarm.timer = Date().timeIntervalSince1970
                alarm.label = "Off"
                alarm.status = false
                alarm.alarmWeek = 0
                weakAlarm.append(alarm)
            }
        }
        
        if sleepAlarm.count<7 {
            for _ in sleepAlarm.count..<7 {
                let alarm:MEDUserAlarm = MEDUserAlarm()
                alarm.timer = Date().timeIntervalSince1970
                alarm.label = "Off"
                alarm.status = false
                alarm.alarmWeek = 0
                sleepAlarm.append(alarm)
            }
        }
        
        let date:Date = Date()
        for (index,Value) in weakAlarm.enumerated() {
            let alarm:MEDUserAlarm = Value
            let alarmDay:Date = Date(timeIntervalSince1970: alarm.timer)
            let newAlarm:NewAlarm = NewAlarm(alarmhour: alarmDay.hour, alarmmin: alarmDay.minute, alarmNumber: index, alarmWeekday: alarm.alarmWeek)
            sendRequest(SetNewAlarmRequest(alarm:newAlarm))
        }
        
        for (index,Value) in sleepAlarm.enumerated() {
            let alarm:MEDUserAlarm = Value
            let alarmDay:Date = Date(timeIntervalSince1970: alarm.timer)
            if alarm.alarmWeek == date.weekday {
                let nowDate:Date = Date.date(year: Date().year, month: Date().month, day: Date().day, hour: alarmDay.hour, minute: alarmDay.minute, second: 0)
                if nowDate.timeIntervalSince1970<Date().timeIntervalSince1970 {
                    let newAlarm:NewAlarm = NewAlarm(alarmhour: alarmDay.hour, alarmmin: alarmDay.minute, alarmNumber: index+7, alarmWeekday: 0)
                    sendRequest(SetNewAlarmRequest(alarm:newAlarm))
                }else{
                    let newAlarm:NewAlarm = NewAlarm(alarmhour: alarmDay.hour, alarmmin: alarmDay.minute, alarmNumber: index+7, alarmWeekday: alarm.alarmWeek)
                    sendRequest(SetNewAlarmRequest(alarm:newAlarm))
                }
            }else{
                if alarm.alarmWeek > date.weekday {
                    let newAlarm:NewAlarm = NewAlarm(alarmhour: alarmDay.hour, alarmmin: alarmDay.minute, alarmNumber: index+7, alarmWeekday: alarm.alarmWeek)
                    sendRequest(SetNewAlarmRequest(alarm:newAlarm))
                }else{
                    let newAlarm:NewAlarm = NewAlarm(alarmhour: alarmDay.hour, alarmmin: alarmDay.minute, alarmNumber: index+7, alarmWeekday: 0)
                    sendRequest(SetNewAlarmRequest(alarm:newAlarm))
                }
            }
        }
        
    }
    
    func SetNortification(_ notfication:[NotificationSetting]) {
        XCGLogger.default.debug("SetNortification")
        sendRequest(SetNortificationRequest(settingArray: notfication))
    }
    
    func SetNortification() {
        var mNotificationSettingArray:[NotificationSetting] = []
        let setting:NotificationSetting = NotificationSetting(type: NotificationType.call, clock: 12, color: "",colorName: "", states:true,packet:"com.apple.mobilephone",appName:"Call")
        mNotificationSettingArray.append(setting)
        sendRequest(SetNortificationRequest(settingArray: mNotificationSettingArray))
    }

    func deleteAllLunaRNotfication() {
        XCGLogger.default.debug("DeleteAllLunaRNotfication")
        sendRequest(DeleteAllNotificationAppIDRequest())
    }
    
    func LunaRNotfication() {
        let mNotificationArray:[MEDUserNotification] = (MEDUserNotification.getAll() as! [MEDUserNotification]).filter({$0.isAddWatch == true})
        
        for (index,model) in mNotificationArray.enumerated() {
            let notification:MEDUserNotification = model
            if notification.isAddWatch {
                let notificationType:String = notification.notificationType
                var type = NotificationType(rawValue: notificationType as NSString)
                if type == nil {
                    type = NotificationType.other
                }
                
                let setting:NotificationSetting = NotificationSetting(type: type!, clock: notification.clock, color: notification.colorValue,colorName: notification.colorName, states:notification.isAddWatch,packet:notification.appid,appName:notification.appName)
                let packet:String = notification.appid
                let notificationsRequest:SetNotificationAppIDRequest = try! SetNotificationAppIDRequest(number: index, hexColor: setting.getHexColor(), appid: packet, notiFictionOnOff: true, motorOnOff: true)
                self.sendRequest(notificationsRequest)
            }
        }
    }
    
    func delay(seconds:Double, completion: @escaping ()-> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
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
    
    func getLunaRTotalAppId() {
        let getTotalApp:GetTotalNotificationAppReuqest = GetTotalNotificationAppReuqest()
        self.sendRequest(getTotalApp)
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
        let banner = MEDBanner(title: NSLocalizedString("sync_finished", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor("#0dac67"))
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
        lastSync = Date().timeIntervalSince1970
        let userDefaults = UserDefaults.standard;
        userDefaults.set(Date().timeIntervalSince1970,forKey:LAST_SYNC_DATE_KEY)
        userDefaults.synchronize()
    }
        
    func getWatchInfo() -> (watchName:String,watchId:Int) {
        return (self.getWatchName(),self.getWatchID());
    }
    
    func setWatchInfo(_ id:Int,model:Int) {
        // id = 1-Nevo,2-Nevo Solar,3-Lunar,0xff-Nevo
        XCGLogger.default.debug("setWatchInfo:id\(id),model:\(model)")
        
        self.setWatchID(id)
        switch id {
        case 1:
            self.setWatchName("Nevo")
            break
        case 2:
            self.setWatchName("Nevo Solar")
            break
        case 3:
            self.setWatchName("Lunar")
            break
        default:
            self.setWatchName("Nevo")
            break
        }
        //model = 1 - Paris,2 - New York,3 - ShangHai
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
        if let value = self.getMconnectionController() {
            return value.hasSavedAddress()
        }else{
            return false
        }
    }
    
    func isConnected() -> Bool{
        if let value = self.getMconnectionController() {
            return value.isConnected()
        }
        return false;
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
    
    func connectedBanner() {
        if(self.hasSavedAddress()){
            let banner = MEDBanner(title: NSLocalizedString("Connected", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor("#0dac67"))
            banner.dismissesOnTap = true
            banner.show(duration: 1.5)
        }
    }
    
    func disConnectedBanner() {
        if(self.hasSavedAddress()){
            let banner = MEDBanner(title: NSLocalizedString("Disconnected", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.red)
            banner.dismissesOnTap = true
            banner.show(duration: 1.5)
        }
    }
    
    /**
     获取当前手机网络状态
     
     - returns: true->网络联通,false->网络不通
     */
    func getNetworkState()->Bool {
        if let networks = network {
            return networks.isReachable
        }else{
            return false;
        }
    }
}

extension AppDelegate {
    func getSunriseAndSunsetTime() -> (sunriseDate: Date?, sunsetDate: Date?, additionString: String) {
        if latitude == 0 && longitude == 0 {
            return (nil, nil, NSLocalizedString("failed_locate", comment: ""))
        }
        
        if let solar = Solar(latitude: latitude, longitude: longitude) {
            if let sunrise = solar.sunrise, let sunset = solar.sunset {
                return (sunrise, sunset, "")
            } else {
                // these areas are in polar day or night!
                let isNorthernHemisphereHere = latitude > 0
                let isNorthernHemisphereSummer = (3..<10).contains(Date().month)
                
                if isNorthernHemisphereHere == isNorthernHemisphereSummer {
                    return (nil, nil, "Polar daylight")
                } else {
                    return (nil, nil, "Polar night")
                }
            }
        } else {
            return (nil, nil, NSLocalizedString("failed_locate", comment: ""))
        }
    }
    
    func getSunriseAndSunsetTime(date: Date) -> (sunriseDate: Date?, sunsetDate: Date?, additionString: String) {
        if latitude == 0 && longitude == 0 {
            return (nil, nil, NSLocalizedString("failed_locate", comment: ""))
        }
        
        if let solar = Solar(forDate: date, latitude: latitude, longitude: longitude) {
            if let sunrise = solar.sunrise, let sunset = solar.sunset {
                return (sunrise, sunset, "")
            } else {
                // these areas are in polar day or night!
                let isNorthernHemisphereHere = latitude > 0
                let isNorthernHemisphereSummer = (3..<10).contains(Date().month)
                
                if isNorthernHemisphereHere == isNorthernHemisphereSummer {
                    return (nil, nil, "Polar daylight")
                } else {
                    return (nil, nil, "Polar night")
                }
            }
        } else {
            return (nil, nil, NSLocalizedString("failed_locate", comment: ""))
        }
    }
}

// MARK: - 调整 App 的启动逻辑
extension AppDelegate {
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
        #if DEBUG
            
            AppDelegate.getAppDelegate().window? = UIWindow(frame: UIScreen.main.bounds)
            AppDelegate.getAppDelegate().window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            AppDelegate.getAppDelegate().window?.makeKeyAndVisible()
        #endif
        /// 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧
    }
    
    func copyBundleRealmToDocumentFolder() {
        if !AppTheme.realmISFirstCopy(findKey: .get) {
            DispatchQueue.global(qos: .background).async {
                WorldClockDatabaseHelper().setup()
            }
            return
        }
        // copy over old data files for migration
        let defaultURL = Realm.Configuration.defaultConfiguration.fileURL!
        
        if let v0URL = URL.bundleURL(name: "default") {
            do {
                if FileManager.default.fileExists(atPath: defaultURL.path) {
                    try FileManager.default.removeItem(at: defaultURL)
                }
                try FileManager.default.copyItem(at: v0URL, to: defaultURL)
                _ = AppTheme.realmISFirstCopy(findKey: .set)
            } catch let error {
                print("file copy or remove error:\(error)");
            }
        }
        
        let migrationBlock: MigrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
            }
            print("Migration complete.")
        }
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 1, migrationBlock: migrationBlock)
        
        print("Migrated objects in the default Realm: \(try! Realm().objects(City.self))")
    }
} 
// MARK: - Fake Functions for Nevo
extension AppDelegate {
    
    func setWorldTime() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            if let row = MEDSettings.int(forKey: "SET_SYNCTIME_TYPE"), row == 0 {
                if let city = HomeClockUtil.shared.getHomeCityWithSelectedFlag(), let timezone = HomeClockUtil.shared.getTimezoneWithCity(city: city) {
                    let cityZone = timezone.gmtTimeOffset*60
                    let localZone = Date.getLocalOffSet()
                    
                    var hourOffset = 0
                    var minOffset = 0
                    if localZone>cityZone {
                        let remainder = (localZone-cityZone)%3600
                        if remainder != 0 {
                            minOffset = remainder/60
                        }
                        hourOffset = 24-Int((localZone-cityZone)/3600)
                    }else{
                        let remainder = (cityZone-localZone)%3600
                        if remainder != 0 {
                            minOffset = remainder/60
                        }
                        hourOffset = Int((cityZone-localZone)/3600)
                    }
                    let setWordClock:SetWorldClockRequest = SetWorldClockRequest(hourOffset: hourOffset, minOffset: minOffset)
                    self.sendRequest(setWordClock)
                }else{
                    let setWordClock:SetWorldClockRequest = SetWorldClockRequest(hourOffset: 0, minOffset: 0)
                    self.sendRequest(setWordClock)
                }
            }else{
                let setWordClock:SetWorldClockRequest = SetWorldClockRequest(hourOffset: 0, minOffset: 0)
                self.sendRequest(setWordClock)
            }
        }
    }
}
