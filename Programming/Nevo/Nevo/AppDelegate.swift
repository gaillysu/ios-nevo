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
import Timepiece
import Fabric
import Crashlytics
import LTNavigationBar
import IQKeyboardManagerSwift
import SwiftEventBus
import XCGLogger

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
        
        IQKeyboardManager.sharedManager().enable = true
        
        //Start the logo for the first time
        if(!UserDefaults.standard.bool(forKey: "LaunchedDatabase")){
            UserDefaults.standard.set(true, forKey: "LaunchedDatabase")
            UserDefaults.standard.set(true, forKey: "firstDatabase")
            /**
            *  Initialize the database
            */
            Presets.defaultPresetsGoal()
            UserAlarm.defaultAlarm()
            UserNotification.defaultNotificationColor()
        }else{
            UserDefaults.standard.set(false, forKey: "firstDatabase")
        }
        
        /**
        *  Initialize the umeng
        *
        *  @param umengAppKey umeng AppKey
        *  @param BATCH       ReportPolicy
        *  @param ""         channel Id
        *
        */
        UMAnalyticsConfig.sharedInstance().appKey = umengAppKey
        MobClick.startWithConfigure(UMAnalyticsConfig.sharedInstance())

        /**
        Initialize the BLE Manager
        */
        mConnectionController = ConnectionControllerImpl()
        mConnectionController?.setDelegate(self)
        let userDefaults = UserDefaults.standard;
        lastSync = userDefaults.double(forKey: LAST_SYNC_DATE_KEY)
        
        //cancel all notifications  PM-13:00, PM 19:00
        LocalNotification.sharedInstance().cancelNotification([NevoAllKeys.LocalStartSportKey(),NevoAllKeys.LocalEndSportKey()])

        //Rate our app Pop-up
        iRate.sharedInstance().messageTitle = NSLocalizedString("Rate Nevo", comment: "")
        iRate.sharedInstance().message = NSLocalizedString("If you like Nevo, please take the time, etc", comment:"");
        iRate.sharedInstance().cancelButtonLabel = NSLocalizedString("No, Thanks", comment:"");
        iRate.sharedInstance().remindButtonLabel = NSLocalizedString("Remind Me Later", comment:"");
        iRate.sharedInstance().rateButtonLabel = NSLocalizedString("Rate It Now", comment:"");
        iRate.sharedInstance().applicationBundleID = "com.nevowatch.Nevo"
        iRate.sharedInstance().onlyPromptIfLatestVersion = true
        iRate.sharedInstance().usesPerWeekForPrompt = 1
        iRate.sharedInstance().previewMode = true
        iRate.sharedInstance().promptAtLaunch = false
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        UIApplication.shared.beginBackgroundTask (expirationHandler: { () -> Void in })
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
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
        var isDir : ObjCBool = false
        let exit:Bool = filemanage.fileExists(atPath: docsdir, isDirectory:&isDir )
        if (!exit || !isDir) {
            do{
                try filemanage.createDirectory(atPath: docsdir, withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError{
                NSLog("failed: \(error.localizedDescription)")
            }
        }
        let dbpath:String = docsdir + nevoDBNames
        return dbpath;
    }

    func getNetworkState()->Bool {
        return false;
    }

    /**
     获取网络数据函数,对AFNetworking的二次封装

     :param: requestURL    请求目的的URL 字符串
     :param: resultHandler 请求后返回的数据块
     */
    func getRequestNetwork(_ requestURL:String,parameters:AnyObject,resultHandler:@escaping ((_ result:AnyObject?,_ error:NSError?) -> Void)){
        Alamofire.request(.POST, requestURL, parameters: parameters as? [String : AnyObject] ,encoding: .URL).responseJSON { (response) -> Void in
            if response.result.isSuccess {
                NSLog("getJSON: \(response.result.value!)")
                resultHandler(result: response.result.value, error: nil)
            }else if (response.result.isFailure){
                resultHandler(result: response.result.value, error: NSError(domain: "error", code: 403, userInfo: nil))
            }else{
                resultHandler(result: nil, error: NSError(domain: "unknown error", code: 404, userInfo: nil))
            }
        }

    }
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


    func SetNortification(_ settingArray:[NotificationSetting]) {
        XCGLogger.defaultInstance().debug("SetNortification")
        sendRequest(SetNortificationRequest(settingArray: settingArray))
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
            mConnectionController?.forgetSavedAddress()
        }
        mConnectionController?.connect()
    }

    // MARK: -AppDelegate GET Function

    func getMconnectionController()->ConnectionControllerImpl{
        return mConnectionController!
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
    
    func getWatchName() {
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
            XCGLogger.defaultInstance().debug("*** Sync started ! ***")
            self.getDailyTrackerInfo()
            lastSync = Date().timeIntervalSince1970
            if(isConnected()) {
                let banner = Banner(title: NSLocalizedString("syncing_data", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
            }
        }
    }

    /**
     When the sync process is finished, le't refresh the date of sync
     */
    func syncFinished() {
        let banner = Banner(title: NSLocalizedString("sync_finished", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.hexStringToColor("#0dac67"))
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
        lastSync = Date().timeIntervalSince1970
        let userDefaults = UserDefaults.standard;
        userDefaults.set(Date().timeIntervalSince1970,forKey:LAST_SYNC_DATE_KEY)
        userDefaults.synchronize()
    }

    // MARK: - UIAlertViewDelegate
    /**
    See UIAlertViewDelegate
    */
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int){
        if(alertView.tag == alertUpdateTag) {
            if(buttonIndex == 1) {
                let tabVC:UITabBarController = self.window?.rootViewController as! UITabBarController
                let otaCont:NevoOtaViewController = NevoOtaViewController()
                let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
                tabVC.present(navigation, animated: true, completion: nil)
            }
        }else{
            disConnectAlert = nil
        }

    }

    // MARK: - ConnectionController protocol
    func  getFirmwareVersion() -> NSString{
        return isConnected() ? self.mConnectionController!.getFirmwareVersion() : NSString()
    }

    func  getSoftwareVersion() -> NSString{
        return isConnected() ? self.mConnectionController!.getSoftwareVersion() : NSString()
    }

    func getWatchNameInfo() -> [String:Int] {
        return [watchName:watchID];
    }
    
    func getWatchModel() -> [String:Int] {
        return [watchModel:watchModelNumber];
    }
    
    func setWatchInfo(_ id:Int,model:Int) {
        //1-Nevo,2-Nevo Solar,3-Lunar,0xff-Nevo
        switch id {
        case 1:
            watchID = 1
            watchName = "Nevo"
            break
        case 2:
            watchID = 2
            watchName = "Nevo Solar"
            break
        case 3:
            watchID = 3
            watchName = "Lunar"
            break
        default:
            watchID = 1
            watchName = "Nevo"
            break
        }
        
        //1 - Paris,2 - New York,3 - ShangHai
        switch model {
        case 1:
            watchModelNumber = 1
            watchModel = "Paris"
            break
        case 2:
            watchModelNumber = 2
            watchModel = "New York"
            break
        case 3:
            watchModelNumber = 3
            watchModel = "ShangHai"
            break
        default:
            watchModelNumber = 1
            watchModel = "Paris"
            break
        }
    }
    
    func connect() {
        self.mConnectionController?.connect()
    }

    func disconnect() {
        self.mConnectionController?.disconnect()
    }

    func forgetSavedAddress() {
        self.mConnectionController?.forgetSavedAddress()
    }

    func hasSavedAddress()->Bool {
        return self.mConnectionController!.hasSavedAddress()
    }

    func restoreSavedAddress() {
        self.mConnectionController?.restoreSavedAddress()
    }

    func isConnected() -> Bool{
        return mConnectionController!.isConnected()

    }

    func sendRequest(_ r:Request) {
        if(isConnected()){
            SyncQueue.sharedInstance.post( { (Void) -> (Void) in

                self.mConnectionController?.sendRequest(r)

            } )
        }else {
            //tell caller
            SwiftEventBus.post(EVENT_BUS_CONNECTION_STATE_CHANGED_KEY, sender:false)
        }
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
                XCGLogger.defaultInstance().debug("Invaild packet............\(packet.getPackets().count)")
                mPacketsbuffer = []
                return;
            }
            SwiftEventBus.post(EVENT_BUS_RAWPACKET_DATA_KEY, sender: packet)

            //We just received a full response, so we can safely send the next request
            SyncQueue.sharedInstance.next()

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
                    if alarm.type == 1 && alarm.status && alarm.dayOfWeek == date.weekday{
                        let newAlarm:NewAlarm = NewAlarm(alarmhour: alarmDay.hour, alarmmin: alarmDay.minute, alarmNumber: index+7, alarmWeekday: 0)
                        self.setNewAlarm(newAlarm)
                    }else{
                        if alarm.status {
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
            
            if(packet.getHeader() == GetWatchName.HEADER()) {
                let watchpacket = packet.copy() as WatchNamePacket
                self.setWatchInfo(watchpacket.getWatchID(), model: watchpacket.getModelNumber())
                //start sync data
                self.syncActivityData()
            }

            if(packet.getHeader() == ReadDailyTrackerInfo.HEADER()) {
                let thispacket = packet.copy() as DailyTrackerInfoNevoPacket
                currentDay = 0
                savedDailyHistory = thispacket.getDailyTrackerInfo()
                XCGLogger.defaultInstance().debug("History Total Days:\(self.savedDailyHistory.count),Today is \(GmtNSDate2LocaleNSDate(Date()))")
                if savedDailyHistory.count > 0 {
                    self.getDailyTracker(currentDay)
                }
            }

            if(packet.getHeader() == ReadDailyTracker.HEADER()) {
                let thispacket:DailyTrackerNevoPacket = packet.copy() as DailyTrackerNevoPacket
                let today:Date  = Date()
                let dateFormatter:DateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                let currentDateStr:NSString = dateFormatter.string(from: today) as NSString

                let timeStr:NSString = NSString(format: "\(thispacket.getDateTimer())" as NSString)
                if(timeStr.length < 8 ) {
                    return
                }
                let year:NSString = timeStr.substring(with: NSMakeRange(0,4)) as NSString
                let month:NSString = timeStr.substring(with: NSMakeRange(4,2)) as NSString
                let day:NSString = timeStr.substring(with: NSMakeRange(6,2)) as NSString
                let timerInterval:Date = Date.date(year: year.integerValue, month: month.integerValue, day: day.integerValue)
                let timerInter:TimeInterval = timerInterval.timeIntervalSince1970

                let stepsArray = UserSteps.getCriteria("WHERE createDate = \(timeStr)")
                let stepsModel:UserSteps = UserSteps(keyDict: [
                    "id":0,
                    "steps":thispacket.getDailySteps(),
                    "goalsteps":thispacket.getStepsGoal(),
                    "distance":thispacket.getDailyDist(),
                    "hourlysteps":AppTheme.toJSONString(thispacket.getHourlySteps() as AnyObject!),
                    "hourlydistance":AppTheme.toJSONString(thispacket.getHourlyDist() as AnyObject!),
                    "calories":thispacket.getDailyCalories() ,
                    "hourlycalories":AppTheme.toJSONString(thispacket.getHourlyCalories() as AnyObject!),
                    "inZoneTime":thispacket.getInZoneTime(),
                    "outZoneTime":thispacket.getOutZoneTime(),
                    "inactivityTime":thispacket.getDailyRunningDuration()+thispacket.getDailyWalkingDuration(),
                    "goalreach":Double(thispacket.getDailySteps())/Double(thispacket.getStepsGoal()),
                    "date":timerInter,
                    "createDate":timeStr,
                    "walking_distance":thispacket.getDailyWalkingDistance(),
                    "walking_duration":thispacket.getDailyWalkingDuration(),
                    "walking_calories":thispacket.getDailyCalories(),
                    "running_distance":thispacket.getRunningDistance(),
                    "running_duration":thispacket.getDailyRunningDuration(),
                    "running_calories":thispacket.getDailyCalories()])
                
                //upload steps data to validic
                UPDATE_VALIDIC_REQUEST.updateToValidic(NSArray(arrayLiteral: stepsModel))
                
                if(stepsArray.count>0) {
                    let step:UserSteps = stepsArray[0] as! UserSteps
                    if(step.steps < thispacket.getDailySteps()) {
                        XCGLogger.defaultInstance().debug("Data that has been saved····")
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
                let model:UserSleep = UserSleep(keyDict: [
                    "id": 0,
                    "date":timerInterval.timeIntervalSince1970,
                    "totalSleepTime":thispacket.getDailySleepTime(),
                    "hourlySleepTime":"\(AppTheme.toJSONString(thispacket.getHourlySleepTime() as AnyObject!))",
                    "totalWakeTime":0,
                    "hourlyWakeTime":"\(AppTheme.toJSONString(thispacket.getHourlyWakeTime() as AnyObject!))" ,
                    "totalLightTime":0,
                    "hourlyLightTime":"\(AppTheme.toJSONString(thispacket.getHourlyLightTime() as AnyObject!))",
                    "totalDeepTime":0,
                    "hourlyDeepTime":"\(AppTheme.toJSONString(thispacket.getHourlyDeepTime() as AnyObject!))"])
                
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
                            model.update()
                        })
                    }
                }else {
                    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                        model.add({ (id, completion) -> Void in
                        })
                    })
                }


                //TODO:crash  数组越界
                do {
                    try savedDailyHistory[Int(currentDay)].TotalSteps = thispacket.getDailySteps()
                    savedDailyHistory[Int(currentDay)].HourlySteps = thispacket.getHourlySteps()
                    savedDailyHistory[Int(currentDay)].TotalCalories = thispacket.getDailyCalories()
                    savedDailyHistory[Int(currentDay)].HourlyCalories = thispacket.getHourlyCalories()
                }catch let error as NSError{
                    NSLog("array error:\(error.description)")
                }
                
                
                
                XCGLogger.defaultInstance().debug("Day:\(GmtNSDate2LocaleNSDate(self.savedDailyHistory[Int(self.currentDay)].Date)), Daily Steps:\(self.savedDailyHistory[Int(self.currentDay)].TotalSteps)")

                XCGLogger.defaultInstance().debug("Day:\(GmtNSDate2LocaleNSDate(self.savedDailyHistory[Int(self.currentDay)].Date)), Hourly Steps:\(self.savedDailyHistory[Int(self.currentDay)].HourlySteps)")

                //save to health kit
                let hk = NevoHKImpl()
                hk.requestPermission()

                let now:Date = Date()
                let saveDay:Date = savedDailyHistory[Int(currentDay)].Date as Date
                let nowDate:Date = Date.date(year: now.year, month: now.month, day: now.day, hour: now.hour, minute: 0, second: 0)
                let saveDate:Date = Date.date(year: saveDay.year, month: saveDay.month, day: saveDay.day, hour: saveDay.hour, minute: 0, second: 0)

                // to HK Running
                for index:Int in 0 ..< thispacket.getHourlyRunningDistance().count {
                    if(thispacket.getHourlyRunningDistance()[index] > 0) {
                        hk.writeDataPoint(RunningToHK(distance:Double(thispacket.getHourlyRunningDistance()[index]), date:Date.date(year: saveDay.year, month: saveDay.month, day: saveDay.day, hour: index, minute: 0, second: 0)), resultHandler: { (result, error) in

                        })
                    }
                }

                // to HK Calories
                for index:Int in 0 ..< thispacket.getHourlyCalories().count {
                    if savedDailyHistory[Int(currentDay)].HourlyCalories[index] > 0 && index == now.hour &&
                        (nowDate != saveDate){

                        hk.writeDataPoint(CaloriesToHK(calories: Double(savedDailyHistory[Int(currentDay)].HourlyCalories[index]), date: Date.date(year: saveDay.year, month: saveDay.month, day: saveDay.day, hour: index, minute: 0, second: 0)), resultHandler: { (result, error) in
                            if (result != true) {
                                XCGLogger.defaultInstance().debug("Save Hourly Calories error\(index),\(error)")
                            }else{
                                XCGLogger.defaultInstance().debug("Save Hourly Calories OK")
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
                                XCGLogger.defaultInstance().debug("Save Hourly steps error\(i),\(error)")
                            }else{
                                XCGLogger.defaultInstance().debug("Save Hourly steps OK")
                            }
                        })
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
                    currentDay = 0
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
                SwiftEventBus.post(EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY, sender:["STEPS":dailySteps,"GOAL":dailyStepGoal,"PERCENT":percent])
            }
            
            //find Phone
            if (TestMode.shareInstance(packet.getPackets()).isTestModel()) {
                AppTheme.playSound()
            }
            
            mPacketsbuffer = []
        }
    }

    func connectionStateChanged(_ isConnected : Bool) {
        //send local notification
        SwiftEventBus.post(EVENT_BUS_CONNECTION_STATE_CHANGED_KEY, sender:isConnected)

        if(isConnected) {
            if(self.hasSavedAddress()){
                let banner = Banner(title: NSLocalizedString("Connected", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.hexStringToColor("#0dac67"))
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
            }

            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.connected)

            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                //setp1: cmd 0x01, set RTC, for every connected Nevo
                self.mPacketsbuffer = []
                self.setRTC()
            })

        }else {
            if(self.hasSavedAddress()){
                let banner = Banner(title: NSLocalizedString("Disconnected", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.red)
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
            }

            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.disconnected)
            SyncQueue.sharedInstance.clear()
            mPacketsbuffer = []
        }
    }

    func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:NSString) {
        let mcuver = AppTheme.GET_SOFTWARE_VERSION()
        let blever = AppTheme.GET_FIRMWARE_VERSION()

        XCGLogger.defaultInstance().debug("Build in software version: \(mcuver), firmware version: \(blever)")

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
                    let tabVC:UITabBarController = self.window?.rootViewController as! UITabBarController

                    let actionSheet:UIAlertController = UIAlertController(title: titleString, message: msg, preferredStyle: UIAlertControllerStyle.alert)
                    actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                    let alertAction1:UIAlertAction = UIAlertAction(title: cancelString, style: UIAlertActionStyle.cancel, handler: { ( alert) -> Void in

                    })
                    actionSheet.addAction(alertAction1)

                    let alertAction2:UIAlertAction = UIAlertAction(title: buttonString, style: UIAlertActionStyle.default, handler: { ( alert) -> Void in
                        let otaCont:NevoOtaViewController = NevoOtaViewController()
                        let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
                        tabVC.present(navigation, animated: true, completion: nil)

                    })
                    actionSheet.addAction(alertAction2)
                    tabVC.present(actionSheet, animated: true, completion: nil)
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
            let banner = Banner(title: NSLocalizedString("bluetooth_turned_off_enable", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.red)
            banner.dismissesOnTap = true
            banner.show(duration: 1.5)
        }
    }

    func scanAndConnect(){
        if(self.hasSavedAddress()) {
            let banner = Banner(title: NSLocalizedString("search_for_nevo", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 1.5)
        }
    }
}
