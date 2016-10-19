//
//  AppDelegate.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import FMDB
import Alamofire
import BRYXBanner
import Fabric
import Crashlytics
import LTNavigationBar
import IQKeyboardManagerSwift
import SwiftEventBus
import UIColor_Hex_Swift
import XCGLogger
import SwiftyTimer
import RealmSwift
let nevoDBDFileURL:String = "nevoDBName";
let nevoDBNames:String = "nevo.sqlite";
let umengAppKey:String = "56cd052d67e58ed65f002a2f"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,ConnectionControllerDelegate,UIAlertViewDelegate {

    var window: UIWindow?
    //Let's sync every days
    let SYNC_INTERVAL:TimeInterval = 1*30*60 //unit is second in iOS, every 30min, do sync
    let LAST_SYNC_DATE_KEY = "LAST_SYNC_DATE_KEY"
    var lastSync = 0.0
    fileprivate var mConnectionController : ConnectionControllerImpl?
    fileprivate var mPacketsbuffer:[Data] = []
    fileprivate let mHealthKitStore:HKHealthStore = HKHealthStore()
    fileprivate var savedDailyHistory:[NevoPacket.DailyHistory] = []
    fileprivate var currentDay:UInt8 = 0
    fileprivate var mAlertUpdateFW = false

    fileprivate var disConnectAlert:UIAlertView?
    fileprivate let alertUpdateTag:Int = 9000
    
    fileprivate var watchID:Int = 1
    fileprivate var watchName:String = "Nevo"
    fileprivate var watchModelNumber:Int = 1
    fileprivate var watchModel:String = "Paris"
    fileprivate var isSync:Bool = true; // syc state
    fileprivate var getWacthNameTimer:Timer?

    let dbQueue:FMDatabaseQueue = FMDatabaseQueue(path: AppDelegate.dbPath())
    let network = NetworkReachabilityManager(host: "drone.karljohnchow.com")

    class func getAppDelegate()->AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        // Override point for customization after application launch
        UINavigationBar.appearance().tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        //UITabBar.appearance().backgroundImage = UIImage()
        //UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().isTranslucent = false
        UINavigationBar.appearance().lt_setBackgroundColor(UIColor.white)
        //设置导航栏文字颜色和字体
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black,NSFontAttributeName:UIFont(name: "Raleway", size: 20)!]
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
//        
//        IQKeyboardManager.sharedManager().enable = true
//        
//        //Start the logo for the first time
//        if(!UserDefaults.standard.bool(forKey: "LaunchedDatabase")){
//            UserDefaults.standard.set(true, forKey: "LaunchedDatabase")
//            UserDefaults.standard.set(true, forKey: "firstDatabase")
//            /**
//            *  Initialize the database
//            */
//            Presets.defaultPresetsGoal()
//            UserAlarm.defaultAlarm()
//            UserNotification.defaultNotificationColor()
//        }else{
//            UserDefaults.standard.set(false, forKey: "firstDatabase")
//            
//            if(!UserDefaults.standard.bool(forKey: "migration")){
                addDummyData()
                migrateDatabase()
//                UserDefaults.standard.set(true, forKey: "migration")
//            }
//        }
//
//        /**
//        Initialize the BLE Manager
//        */
//        mConnectionController = ConnectionControllerImpl()
//        mConnectionController?.setDelegate(self)
//        //lastSync = userDefaults.double(forKey: LAST_SYNC_DATE_KEY)
//        
//        adjustLaunchLogic()
//        
//        //cancel all notifications  PM-13:00, PM 19:00
//        LocalNotification.sharedInstance().cancelNotification([NevoAllKeys.LocalStartSportKey(),NevoAllKeys.LocalEndSportKey()])
//
//        //Rate our app Pop-up
//        iRate.sharedInstance().messageTitle = NSLocalizedString("Rate Nevo", comment: "")
//        iRate.sharedInstance().message = NSLocalizedString("If you like Nevo, please take the time, etc", comment:"");
//        iRate.sharedInstance().cancelButtonLabel = NSLocalizedString("No, Thanks", comment:"");
//        iRate.sharedInstance().remindButtonLabel = NSLocalizedString("Remind Me Later", comment:"");
//        iRate.sharedInstance().rateButtonLabel = NSLocalizedString("Rate It Now", comment:"");
//        iRate.sharedInstance().applicationBundleID = "com.nevowatch.Nevo"
//        iRate.sharedInstance().onlyPromptIfLatestVersion = true
//        iRate.sharedInstance().usesPerWeekForPrompt = 1
//        iRate.sharedInstance().previewMode = true
//        iRate.sharedInstance().promptAtLaunch = false
//        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        UIApplication.shared.beginBackgroundTask (expirationHandler: { () -> Void in })
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func application(_ application: UIApplication , didReceive notification: UILocalNotification ) {
        if (disConnectAlert == nil) {
            disConnectAlert = UIAlertView(title: NSLocalizedString("BLE_LOST_TITLE", comment: ""), message: NSLocalizedString("BLE_CONNECTION_LOST", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("Ok", comment: ""))
            disConnectAlert?.show()
        }
    }

    // MARK: -dbPath
    class func dbPath()->String{
        var docsdir:String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        let filemanage:FileManager = FileManager.default
        //nevoDBDFileURL
        docsdir = docsdir.appendingFormat("%@%@/", "/",nevoDBDFileURL)
        var isDir : ObjCBool = ObjCBool(false)
        let exit:Bool = filemanage.fileExists(atPath: docsdir, isDirectory:&isDir )
        if (!exit || !isDir.boolValue) {
            do{
                try filemanage.createDirectory(atPath: docsdir, withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError{
                NSLog("failed: \(error.localizedDescription)")
            }
        }
        let dbpath:String = docsdir + nevoDBNames
        return dbpath;
    }

    func isSyncState()-> Bool {
        return isSync
    }
    
    func getMconnectionController()->ConnectionControllerImpl?{
        return mConnectionController
    }
    
    func setWactnID(_ id:Int) {
        watchID = id
    }
    
    func getWactnID()->Int {
         return watchID
    }
    
    func setWatchName(_ name:String) {
        watchName = name
    }
    
    func getWatchName() ->String {
        return watchName;
    }
    
    func setWatchModelNumber(_ number:Int) {
        watchModelNumber = number
    }
    
    func getWatchModelNumber()->Int {
        return watchModelNumber
    }
    
    func setWatchModel(_ model:String) {
        watchModel = model;
    }
    
    func getWatchModel() -> String {
        return watchModel
    }
    
    // MARK: - ConnectionControllerDelegate
    /**
     Called when a packet is received from the device
     */
    func packetReceived(_ packet: RawPacket) {

        mPacketsbuffer.append(packet.getRawData() as Data)
        if(packet.isLastPacket()) {
            let packet:NevoPacket = NevoPacket(packets:mPacketsbuffer)
            if(!packet.isVaildPacket()) {
                XCGLogger.default.debug("Invaild packet............\(packet.getPackets().count)")
                mPacketsbuffer = []
                return;
            }
            SwiftEventBus.post(EVENT_BUS_RAWPACKET_DATA_KEY, sender: packet)

            //We just received a full response, so we can safely send the next request
            SyncQueue.sharedInstance.next()
            
            if(packet.getHeader() == GetWatchName.HEADER()) {
                let watchpacket = packet.copy() as WatchNamePacket
                self.setWatchInfo(watchpacket.getWatchID(), model: watchpacket.getModelNumber())
                //start sync data
                //self.syncActivityData()
                if getWacthNameTimer!.isValid {
                    getWacthNameTimer?.invalidate()
                    getWacthNameTimer = nil
                }
                self.setRTC()
            }
            
            if(packet.getHeader() == SetRTCRequest.HEADER()) {
                //setp2:start set user profile
                self.SetProfile()
            }

            if(packet.getHeader() == SetProfileRequest.HEADER()) {
                //step3:
                self.WriteSetting()
            }

            if(packet.getHeader() == WriteSettingRequest.HEADER()) {
                //step4:
                self.SetCardio()
            }

            if(packet.getHeader() == SetCardioRequest.HEADER()) {
                //step5: sync the notification setting, if remove nevo's battery, the nevo notification reset, so here need sync it
                var mNotificationSettingArray:[NotificationSetting] = []
                let notArray:NSArray = UserNotification.getAll()
                let notificationTypeArray:[NotificationType] = [NotificationType.call, NotificationType.email, NotificationType.facebook, NotificationType.sms, NotificationType.wechat]
                for notificationType in notificationTypeArray {
                    for model in notArray{
                        let notification:UserNotification = model as! UserNotification
                        if(notification.NotificationType == notificationType.rawValue as String){
                            let setting:NotificationSetting = NotificationSetting(type: notificationType, clock: notification.clock, color: 0, states:notification.status)
                            mNotificationSettingArray.append(setting)
                            break
                        }
                    }
                }

                //start sync notification setting on the phone side
                SetNortification(mNotificationSettingArray)
            }

            if(packet.getHeader() == SetNortificationRequest.HEADER()) {
                let weakAlarm:NSArray = UserAlarm.getCriteria("WHERE type = \(0)")
                let sleepAlarm:NSArray = UserAlarm.getCriteria("WHERE type = \(1)")
                
                for index in 0 ..< 14{
                    let date:Date = Date()
                    let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: index, alarmWeekday: 0)
                    if(self.isConnected()){
                        self.setNewAlarm(newAlarm)
                    }
                }
                
                let date:Date = Date()
                for (index,Value) in weakAlarm.enumerated() {
                    let alarm:UserAlarm = Value as! UserAlarm
                    let alarmDay:Date = Date(timeIntervalSince1970: alarm.timer)
                    if alarm.status {
                        let newAlarm:NewAlarm = NewAlarm(alarmhour: alarmDay.hour, alarmmin: alarmDay.minute, alarmNumber: index, alarmWeekday: alarm.dayOfWeek)
                        self.setNewAlarm(newAlarm)
                    }
                }
                
                for (index,Value) in sleepAlarm.enumerated() {
                    let alarm:UserAlarm = Value as! UserAlarm
                    let alarmDay:Date = Date(timeIntervalSince1970: alarm.timer)
                    print("alarmDay:\(alarmDay),alarm:\(alarm.type,alarm.status,alarm.dayOfWeek,date.weekday)")
                    if alarm.type == 1 && alarm.status && alarm.dayOfWeek == date.weekday{
                        let newAlarm:NewAlarm = NewAlarm(alarmhour: alarmDay.hour, alarmmin: alarmDay.minute, alarmNumber: index+7, alarmWeekday: 0)
                        self.setNewAlarm(newAlarm)
                    }else{
                        if alarm.status && alarm.dayOfWeek >= date.weekday{
                            let newAlarm:NewAlarm = NewAlarm(alarmhour: alarmDay.hour, alarmmin: alarmDay.minute, alarmNumber: index+7, alarmWeekday: alarm.dayOfWeek)
                            self.setNewAlarm(newAlarm)
                        }
                    }
                }
                //start sync data
                //self.syncActivityData()
            }

            if(packet.getHeader() == SetAlarmRequest.HEADER()) {
                //start sync data
                self.syncActivityData()
                //self.getWatchName()
            }

            if(packet.getHeader() == ReadDailyTrackerInfo.HEADER()) {
                let thispacket = packet.copy() as DailyTrackerInfoNevoPacket
                currentDay = 0
                savedDailyHistory = thispacket.getDailyTrackerInfo()
                XCGLogger.default.debug("History Total Days:\(self.savedDailyHistory.count),Today is \(GmtNSDate2LocaleNSDate(Date()))")
                if savedDailyHistory.count > 0 {
                    self.getDailyTracker(currentDay)
                }
            }

            if(packet.getHeader() == ReadDailyTracker.HEADER()) {
                let thispacket:DailyTrackerNevoPacket = packet.copy() as DailyTrackerNevoPacket

                let timeStr:String = String(format: "%d" ,thispacket.getDateTimer())
                if(timeStr.length() < 8 ) {
                    return
                }
                
                 let index = timeStr.index(timeStr.startIndex, offsetBy: 4)
                let year:String = timeStr.substring(to: index)
                
                let range: Range = timeStr.index(timeStr.startIndex, offsetBy: 4)..<timeStr.index(timeStr.startIndex, offsetBy: 6)
                let month:String = timeStr.substring(with: range)
                
                let range2: Range = timeStr.index(timeStr.startIndex, offsetBy: 6)..<timeStr.index(timeStr.startIndex, offsetBy: 8)
                let day:String = timeStr.substring(with: range2)
                
                let timerInterval:Date = Date.date(year.toInt(), month: month.toInt(), day: day.toInt())
                let timerInter:TimeInterval = timerInterval.timeIntervalSince1970

                let stepsArray = UserSteps.getCriteria("WHERE createDate = \(timeStr)")
                let stepsModel:UserSteps = UserSteps()
                stepsModel.id = 0
                stepsModel.steps = thispacket.getDailySteps()
                stepsModel.goalsteps = thispacket.getStepsGoal()
                stepsModel.distance = thispacket.getDailyDist()
                stepsModel.hourlysteps = "\(AppTheme.toJSONString(thispacket.getHourlySteps() as AnyObject!))"
                stepsModel.hourlydistance = "\(AppTheme.toJSONString(thispacket.getHourlyDist() as AnyObject!))"
                stepsModel.calories = Double(thispacket.getDailyCalories())
                stepsModel.hourlycalories = "\(AppTheme.toJSONString(thispacket.getHourlyCalories() as AnyObject!))"
                stepsModel.inZoneTime = thispacket.getInZoneTime()
                stepsModel.outZoneTime = thispacket.getOutZoneTime()
                stepsModel.inactivityTime = thispacket.getDailyRunningDuration()+thispacket.getDailyWalkingDuration()
                stepsModel.goalreach = Double(thispacket.getDailySteps())/Double(thispacket.getStepsGoal())
                stepsModel.date = timerInter
                stepsModel.createDate = "\(timeStr)"
                stepsModel.walking_distance = thispacket.getDailyWalkingDistance()
                stepsModel.walking_duration = thispacket.getDailyWalkingDuration()
                stepsModel.walking_calories = thispacket.getDailyCalories()
                stepsModel.running_distance = thispacket.getRunningDistance()
                stepsModel.running_duration = thispacket.getDailyRunningDuration()
                stepsModel.running_calories = thispacket.getDailyCalories()
                
                //upload steps data to validic
                UPDATE_VALIDIC_REQUEST.updateToValidic(NSArray(arrayLiteral: stepsModel))
                
                if(stepsArray.count>0) {
                    let step:UserSteps = stepsArray[0] as! UserSteps
                    if(step.steps < thispacket.getDailySteps()) {
                        XCGLogger.default.debug("Data that has been saved····")
                        stepsModel.id = step.id
                        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                            stepsModel.update()
                        })
                    }
                }else {
                    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                        stepsModel.add({ (id, completion) -> Void in
                        })
                    })
                }

                //save sleep data for every hour.
                //save format: first write wake, then write sleep(light&deep)
                let sleepArray = UserSleep.getCriteria("WHERE date = \(timerInterval.timeIntervalSince1970)")
                let model:UserSleep = UserSleep()
                model.id = 0
                model.date = timerInterval.timeIntervalSince1970
                model.totalSleepTime = thispacket.getDailySleepTime()
                model.hourlySleepTime = "\(AppTheme.toJSONString(thispacket.getHourlySleepTime() as AnyObject!))"
                model.totalWakeTime = 0
                model.hourlyWakeTime = "\(AppTheme.toJSONString(thispacket.getHourlyWakeTime() as AnyObject!))"
                model.totalLightTime = 0
                model.hourlyLightTime = "\(AppTheme.toJSONString(thispacket.getHourlyLightTime() as AnyObject!))"
                model.totalDeepTime = 0
                model.hourlyDeepTime = "\(AppTheme.toJSONString(thispacket.getHourlyDeepTime() as AnyObject!))"
                
                //upload sleep data to validic
                //UPDATE_VALIDIC_REQUEST.updateSleepDataToValidic(NSArray(arrayLiteral: stepsModel))
                
                if(sleepArray.count>0) {
                    let sleep:UserSleep = sleepArray[0] as! UserSleep
                    let localSleepArray:[Int] = AppTheme.jsonToArray(sleep.hourlySleepTime) as! [Int]
                    var localTime:Int = 0
                    
                    for value in localSleepArray {
                        localTime+=value
                    }
                    
                    let currentSleepArray:[Int] = thispacket.getHourlySleepTime()
                    var currentSleepTime:Int = 0
                    for value in currentSleepArray {
                        currentSleepTime+=value
                    }
                    
                    if currentSleepTime>localTime {
                        model.id = sleep.id
                        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                            _ = model.update()
                        })
                    }
                }else {
                    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                        _ = model.add({ (id, completion) -> Void in
                        })
                    })
                }

                //TODO:crash  数组越界
                if Int(currentDay)<savedDailyHistory.count {
                    savedDailyHistory[Int(currentDay)].TotalSteps = thispacket.getDailySteps()
                    savedDailyHistory[Int(currentDay)].HourlySteps = thispacket.getHourlySteps()
                    savedDailyHistory[Int(currentDay)].TotalCalories = thispacket.getDailyCalories()
                    savedDailyHistory[Int(currentDay)].HourlyCalories = thispacket.getHourlyCalories()
                    
                    //save to health kit
                    let hk = NevoHKImpl()
                    hk.requestPermission()
                    
                    let now:Date = Date()
                    let saveDay:Date = savedDailyHistory[Int(currentDay)].Date as Date
                    let nowDate:Date = Date.date(now.year, month: now.month, day: now.day, hour: now.hour, minute: 0, second: 0)
                    let saveDate:Date = Date.date(saveDay.year, month: saveDay.month, day: saveDay.day, hour: saveDay.hour, minute: 0, second: 0)
                    
                    // to HK Running
                    for index:Int in 0 ..< thispacket.getHourlyRunningDistance().count {
                        if(thispacket.getHourlyRunningDistance()[index] > 0) {
                            hk.writeDataPoint(RunningToHK(distance:Double(thispacket.getHourlyRunningDistance()[index]), date:Date.date(saveDay.year, month: saveDay.month, day: saveDay.day, hour: index, minute: 0, second: 0)), resultHandler: { (result, error) in
                            })
                        }
                    }
                    
                    // to HK Calories
                    for index:Int in 0 ..< thispacket.getHourlyCalories().count {
                        if savedDailyHistory[Int(currentDay)].HourlyCalories[index] > 0 && index == now.hour &&
                            (nowDate != saveDate){
                            
                            hk.writeDataPoint(CaloriesToHK(calories: Double(savedDailyHistory[Int(currentDay)].HourlyCalories[index]), date: Date.date(saveDay.year, month: saveDay.month, day: saveDay.day, hour: index, minute: 0, second: 0)), resultHandler: { (result, error) in
                                if (result != true) {
                                    XCGLogger.default.debug("Save Hourly Calories error\(index),\(error)")
                                }else{
                                    XCGLogger.default.debug("Save Hourly Calories OK")
                                }
                            })
                        }
                    }
                    
                    for i:Int in 0 ..< savedDailyHistory[Int(currentDay)].HourlySteps.count {
                        //only save vaild hourly steps for every day, include today.
                        //exclude update current hour step, due to current hour not end
                        //for example: at 10:20~ 10:25AM, walk 100 steps, 10:50~10:59, walk 300 steps
                        //user can't see the 10:00AM record data at 10:XX clock
                        //user can see 10:00AM data when 11:20 do a big sync, the value should be 400 steps
                        //that is to say, user can't see current hour 's step in healthkit, he can see it by waiting one hour
                        if savedDailyHistory[Int(currentDay)].HourlySteps[i] > 0 &&
                            (nowDate != saveDate){
                            hk.writeDataPoint(HourlySteps(numberOfSteps: savedDailyHistory[Int(currentDay)].HourlySteps[i],date: savedDailyHistory[Int(currentDay)].Date,hour:i,update: false), resultHandler: { (result, error) -> Void in
                                if (result != true) {
                                    XCGLogger.default.debug("Save Hourly steps error\(i),\(error)")
                                }else{
                                    XCGLogger.default.debug("Save Hourly steps OK")
                                }
                            })
                        }
                    }
                }

                //end save
                currentDay += 1
                if(currentDay < UInt8(savedDailyHistory.count)) {
                    if currentDay == 1 {
                        SwiftEventBus.post(EVENT_BUS_BEGIN_BIG_SYNCACTIVITY, sender:nil)
                    }
                    self.getDailyTracker(currentDay)
                }else {
                    //currentDay = 0
                    isSync = false
                    self.syncFinished()
                    SwiftEventBus.post(EVENT_BUS_END_BIG_SYNCACTIVITY, sender:nil)
                }
            }

            if(packet.getHeader() == GetStepsGoalRequest.HEADER()) {
                //refresh current hourly steps changing in the healthkit
                let thispacket = packet.copy() as DailyStepsNevoPacket
                let dailySteps:Int = thispacket.getDailySteps()
                let dailyStepGoal:Int = thispacket.getDailyStepsGoal()
                let percent :Float = Float(dailySteps)/Float(dailyStepGoal)
                SwiftEventBus.post(EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY, sender:["STEPS":dailySteps,"GOAL":dailyStepGoal,"PERCENT":percent] as AnyObject)
            }
            
            //find Phone
            if (TestMode.sharedInstance(packet.getPackets()).isTestModel()) {
                AppTheme.playSound()
            }
            
            mPacketsbuffer = []
        }
    }

    func connectionStateChanged(_ isConnected : Bool) {
        //send local notification
        SwiftEventBus.post(EVENT_BUS_CONNECTION_STATE_CHANGED_KEY, sender:isConnected as AnyObject)

        if(isConnected) {
            if(self.hasSavedAddress()){
                let banner = MEDBanner(title: NSLocalizedString("Connected", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor(rgba: "#0dac67"))
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
            }

            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.connected)

            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                //setp1: cmd 0x01, set RTC, for every connected Nevo
                self.mPacketsbuffer = []

                self.getWatchNameRequest()
                
                self.getWacthNameTimer = Timer.after(5, {
                    self.setRTC()
                })
            })

        }else {
            if(self.hasSavedAddress()){
                let banner = MEDBanner(title: NSLocalizedString("Disconnected", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.red)
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
            }
            
            isSync = false

            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.disconnected)
            SyncQueue.sharedInstance.clear()
            mPacketsbuffer = []
        }
    }

    func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:NSString) {
        let mcuver = AppTheme.GET_SOFTWARE_VERSION()
        let blever = AppTheme.GET_FIRMWARE_VERSION()

        XCGLogger.default.debug("Build in software version: \(mcuver), firmware version: \(blever)")

        if ((whichfirmware == DfuFirmwareTypes.softdevice  && version.integerValue < mcuver)
            || (whichfirmware == DfuFirmwareTypes.application  && version.integerValue < blever)) {
            //for tutorial screen, don't popup update dialog
            if !mAlertUpdateFW {
                mAlertUpdateFW = true
                let titleString:String = NSLocalizedString("Update", comment: "")
                let msg:String = NSLocalizedString("An_update_is_available_for_your_watch", comment: "")
                let buttonString:String = NSLocalizedString("Update", comment: "")
                let cancelString:String = NSLocalizedString("Cancel", comment: "")

                if((UIDevice.current.systemVersion as NSString).floatValue >= 8.0){
                    // is this necessary? i have to change the rootViewController's Class during launch, maybe...
//                    let tabVC:UITabBarController = self.window?.rootViewController as! UITabBarController
                    let tabVC = self.window?.rootViewController

                    let actionSheet:UIAlertController = UIAlertController(title: titleString, message: msg, preferredStyle: UIAlertControllerStyle.alert)
                    let alertAction1:AlertAction = AlertAction(title: cancelString, style: UIAlertActionStyle.cancel, handler: { ( alert) -> Void in

                    })
                    actionSheet.addAction(alertAction1)

                    let alertAction2:AlertAction = AlertAction(title: buttonString, style: UIAlertActionStyle.default, handler: { ( alert) -> Void in
                        let otaCont:NevoOtaViewController = NevoOtaViewController()
                        let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
                        tabVC?.present(navigation, animated: true, completion: nil)

                    })
                    actionSheet.addAction(alertAction2)
                    if !AppTheme.isTargetLunaR_OR_Nevo() {
                        alertAction1.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
                        alertAction2.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
                    }else{
                        alertAction1.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
                        alertAction2.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
                    }
                    tabVC?.present(actionSheet, animated: true, completion: nil)
                }else{
                    let actionSheet:UIAlertView = UIAlertView(title: titleString, message: msg, delegate: self, cancelButtonTitle: cancelString, otherButtonTitles: buttonString)
                    actionSheet.layer.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW().cgColor
                    actionSheet.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                    actionSheet.tag = alertUpdateTag
                    actionSheet.show()
                }

            }
        }
    }

    /**
     *  Receiving the current device signal strength value
     */
    func receivedRSSIValue(_ number:NSNumber){
        SwiftEventBus.post(EVENT_BUS_RSSI_VALUE, sender: number)
    }

    func bluetoothEnabled(_ enabled:Bool) {
        if(!enabled && self.hasSavedAddress()) {
            let banner = MEDBanner(title: NSLocalizedString("bluetooth_turned_off_enable", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.red)
            banner.dismissesOnTap = true
            banner.show(duration: 1.5)
        }
    }

    func scanAndConnect(){
        if(self.hasSavedAddress()) {
            let banner = MEDBanner(title: NSLocalizedString("search_for_nevo", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 1.5)
        }
    }
}


// Only used for migration for database.
extension AppDelegate{
    
    func addDummyData(){
        for i in 0..<10 {
            let userAlarm = UserAlarm()
            userAlarm.dayOfWeek = i
            userAlarm.label = "Alarm \(i)"
            userAlarm.repeatStatus = false
            userAlarm.status = true
            userAlarm.timer = 12.50
            userAlarm.type = i % 2 == 0 ? 0 : 1
            userAlarm.add({ (_, success) in
                print("Added Alarm = \(success)")
            })
        }
        
        for _ in 0..<10{
            let userSteps = UserSteps()
            userSteps.steps = 2000
            userSteps.goalsteps = 7000
            userSteps.distance = 1000
            userSteps.hourlysteps = "[100,100,100,100,100,100,100,100,100,100,0,0,100,100,100,100,100,100,100,100,100,100,0,0]"
            userSteps.hourlydistance = "[50,50,50,50,50,50,50,50,50,50,0,0,50,50,50,50,50,50,50,50,50,50,0,0]"
            userSteps.calories = 1000
            userSteps.hourlycalories = "[50,50,50,50,50,50,50,50,50,50,0,0,50,50,50,50,50,50,50,50,50,50,0,0]"
            userSteps.inZoneTime = 100;
            userSteps.outZoneTime = 200;
            userSteps.inactivityTime = 300;
            userSteps.goalreach = 0.0;
            userSteps.date = 0
            userSteps.createDate = "20161019"
            userSteps.walking_distance = 100
            userSteps.walking_duration = 200
            userSteps.walking_calories = 300
            userSteps.running_distance = 100
            userSteps.running_duration = 200
            userSteps.running_calories = 300
            userSteps.validic_id = ""
            userSteps.add({ (_, success) in
                print("Added Steps = \(success)")
            })
        }
        
        for _ in 0..<10{
            let userSleep = UserSleep()
            userSleep.date = 0
            userSleep.totalSleepTime = 300;
            userSleep.hourlySleepTime = "[300]";
            userSleep.totalWakeTime = 100;
            userSleep.hourlyWakeTime = "[100]";
            userSleep.totalLightTime = 100;
            userSleep.hourlyLightTime = "[100]";
            userSleep.totalDeepTime = 100;
            userSleep.hourlyDeepTime = "[100]";
            userSleep.add({ (_, success) in
                print("Added Sleep = \(success)")
            })
        }
        
        for _ in 0..<10{
            let presets = Presets()
            presets.steps = 1000
            presets.label = "My Goal"
            presets.status = true
            presets.add({ (_, success) in
                print("Presets Presets = \(success)")
            })
        }
        let notificationTypeArray:[String] = ["Calendar", "Facebook", "EMAIL", "CALL", "SMS","WeChat"]
        for i in 0..<6{
            let notification = UserNotification()
            notification.clock = i
            notification.NotificationType = "\(notificationTypeArray[i])"
            notification.status = true
            notification.add({ (_, success) in
                print("Notification Notification = \(success)")
            })
        }
        
        let profile = UserProfile()
        profile.first_name = "Karl-John"
        profile.last_name = "Chow"
        profile.birthday = "1992-09-14"
        profile.gender = true
        profile.weight = 70
        profile.length = 175
        profile.metricORimperial = false
        profile.created = Date().timeIntervalSince1970
        profile.email = "karl.chow92@gmail.com"
        profile.add({ (_, success) in
            print("Notification Notification = \(success)")
        })
        
        
        
        print("\(UserAlarm.getAll().count)")
        print("\(UserSteps.getAll().count)")
        print("\(UserSleep.getAll().count)")
        print("\(Presets.getAll().count)")
        print("\(UserNotification.getAll().count)")
    }
    
    
    func migrateDatabase(){
        let realm:Realm = try! Realm()
        try! realm.write ({
            realm.deleteAll()
        })
        
        print("Migrating User Alarm")
        for object in UserAlarm.getAll(){
            if let alarmModel = object as? UserAlarm {
                let alarm = AlarmRealm()
                alarm.fromAlarmModel(alarmModel: alarmModel)
                
                try! realm.write ({
                    realm.add(alarm)
                })
                _ = alarmModel.remove()
            }else{
                print("Alarm migration went wrong, strangely")
            }
        }
        print("Migrating User Steps")
        for object in UserSteps.getAll() {
            if let stepsModel = object as? UserSteps {
                let steps = Steps()
                steps.fromStepsModel(userSteps: stepsModel)
                try! realm.write ({
                    realm.add(steps)
                })
                _ = stepsModel.remove()
            }else{
                print("Steps migration went wrong, strangely")
            }
        }
        
        print("Migrating User Sleep")
        for object in UserSleep.getAll() {
            if let sleepModel = object as? UserSleep {
                let sleep = SleepRealm()
                sleep.fromSleepModel(sleepModel: sleepModel)
                try! realm.write ({
                    realm.add(sleep)
                })
                _ = sleepModel.remove()
            }else{
                print("Sleep migration went wrong, strangely")
            }
        }
        
        print("Migrating User Presets")
        for object in Presets.getAll() {
            if let presetsModel = object as? Presets {
                let presets = PresetsRealm()
                presets.fromPresetsModel(presetsModel: presetsModel)
                try! realm.write ({
                    realm.add(presets)
                })
                _ = presetsModel.remove()
            }else{
                print("Goal migration went wrong, strangely")
            }
        }
        
        print("Migrating User Notifications")
        for object in UserNotification.getAll(){
            if let notificationModel = object as? UserNotification{
                let notifications = Notifications()
                notifications.fromNotificationModel(notificationModel: notificationModel)
                try! realm.write ({
                    realm.add(notifications)
                })
                _ = notificationModel.remove()
            }else{
                print("Notification migration went wrong, strangely")
            }
        }
        
        for object in UserProfile.getAll(){
            if let userProfile = object as? UserProfile{
                let profile = Profile()
                profile.fromUserProfile(nevoProfileModel: userProfile)
                try! realm.write ({
                    realm.add(profile)
                })
                _ = userProfile.remove()
            }else{
                print("Notification migration went wrong, strangely")
            }
        }
        
        
        print("Alarm count = \(realm.objects(AlarmRealm.self).count)")
        print("Step count = \(realm.objects(Steps.self).count)")
        print("Sleep count = \(realm.objects(SleepRealm.self).count)")
        print("Presets count = \(realm.objects(PresetsRealm.self).count)")
        print("Profile count = \(realm.objects(Profile.self).count)")
        print("Notifications count = \(realm.objects(Notifications.self).count)")
        
    }
}
