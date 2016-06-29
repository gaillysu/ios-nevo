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

let nevoDBDFileURL:String = "nevoDBName";
let nevoDBNames:String = "nevo.sqlite";
let umengAppKey:String = "56cd052d67e58ed65f002a2f"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,ConnectionControllerDelegate,UIAlertViewDelegate {

    var window: UIWindow?
    //Let's sync every days
    let SYNC_INTERVAL:NSTimeInterval = 1*30*60 //unit is second in iOS, every 30min, do sync
    let LAST_SYNC_DATE_KEY = "LAST_SYNC_DATE_KEY"
    var lastSync = 0.0
    private var mDelegates:[SyncControllerDelegate] = []
    private var mConnectionController : ConnectionControllerImpl?
    private var mPacketsbuffer:[NSData] = []
    private let mHealthKitStore:HKHealthStore = HKHealthStore()
    private var savedDailyHistory:[NevoPacket.DailyHistory] = []
    private var currentDay:UInt8 = 0
    private var mAlertUpdateFW = false

    private var todaySleepData:NSMutableArray = NSMutableArray(capacity: 2)
    private var disConnectAlert:UIAlertView?
    private let alertUpdateTag:Int = 9000

    let dbQueue:FMDatabaseQueue = FMDatabaseQueue(path: AppDelegate.dbPath())
    let network = NetworkReachabilityManager(host: "drone.karljohnchow.com")

    class func getAppDelegate()->AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        // Override point for customization after application launch
        UINavigationBar.appearance().tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        UITabBar.appearance().backgroundImage = UIImage()
        //UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().translucent = false

        //Start the logo for the first time
        if(!NSUserDefaults.standardUserDefaults().boolForKey("LaunchedDatabase")){
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "LaunchedDatabase")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstDatabase")
            /**
            *  Initialize the database
            */
            Presets.defaultPresetsGoal()
            UserAlarm.defaultAlarm()
            UserNotification.defaultNotificationColor()
        }else{
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstDatabase")
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
        let userDefaults = NSUserDefaults.standardUserDefaults();
        lastSync = userDefaults.doubleForKey(LAST_SYNC_DATE_KEY)
        
        //cancel all notifications  PM-13:00, PM 19:00
        LocalNotification.sharedInstance().cancelNotification([NevoAllKeys.LocalStartSportKey(),NevoAllKeys.LocalEndSportKey()])

        //Rate our app Pop-up
        iRate.sharedInstance().messageTitle = NSLocalizedString("Rate Nevo", comment: "")
        iRate.sharedInstance().message = NSLocalizedString("If you like Nevo, please take the time, etc", comment:"");
        iRate.sharedInstance().cancelButtonLabel = NSLocalizedString("No, Thanks", comment:"");
        iRate.sharedInstance().remindButtonLabel = NSLocalizedString("Remind Me Later", comment:"");
        iRate.sharedInstance().rateButtonLabel = NSLocalizedString("Rate It Now", comment:"");
        iRate.sharedInstance().applicationBundleID = "com.nevowatch.Nevo"
        iRate.sharedInstance().onlyPromptIfLatestVersion = false
        iRate.sharedInstance().previewMode = true
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in }
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    func application(application: UIApplication , didReceiveLocalNotification notification: UILocalNotification ) {
        if (disConnectAlert == nil) {
            disConnectAlert = UIAlertView(title: NSLocalizedString("BLE_LOST_TITLE", comment: ""), message: NSLocalizedString("BLE_CONNECTION_LOST", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("Ok", comment: ""))
            disConnectAlert?.show()
        }
    }

    // MARK: -dbPath
    class func dbPath()->String{
        var docsdir:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
        let filemanage:NSFileManager = NSFileManager.defaultManager()
        //nevoDBDFileURL
        docsdir = docsdir.stringByAppendingFormat("%@%@/", "/",nevoDBDFileURL)
        var isDir : ObjCBool = false
        let exit:Bool = filemanage.fileExistsAtPath(docsdir, isDirectory:&isDir )
        if (!exit || !isDir) {
            do{
                try filemanage.createDirectoryAtPath(docsdir, withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError{
                NSLog("failed: \(error.localizedDescription)")
            }
        }
        let dbpath:String = docsdir.stringByAppendingString(nevoDBNames)
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
    func getRequestNetwork(requestURL:String,parameters:AnyObject,resultHandler:((result:AnyObject?,error:NSError?) -> Void)){
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

    func setGoal(goal:Goal) {
        sendRequest(SetGoalRequest(goal: goal))
    }

    func setAlarm(alarm:[Alarm]) {
        sendRequest(SetAlarmRequest(alarm:alarm))
    }

    func setNewAlarm(alarm:NewAlarm) {
        sendRequest(SetNewAlarmRequest(alarm:alarm))
    }

    func setSleepStartAlarm(sleepAlarm:ConfigSleepAlarm) {
        sendRequest(SetSleepRequest(sleepAlarm: sleepAlarm))
    }

    func SetNortification(settingArray:[NotificationSetting]) {
        AppTheme.DLog("SetNortification")
        sendRequest(SetNortificationRequest(settingArray: settingArray))
    }
    /**
     @ledpattern, define Led light pattern, 0 means off all led, 0xFFFFFF means light on all led( include color and white)
     0x7FF means light on all white led (bit0~bit10), 0x3F0000 means light on all color led (bit16~bit21)
     other value, light on the related led
     @motorOnOff, vibrator true or flase
     */
    func SetLedOnOffandVibrator(ledpattern:UInt32,  motorOnOff:Bool) {
        sendRequest(LedLightOnOffNevoRequest(ledpattern: ledpattern, motorOnOff: motorOnOff))
    }

    func startConnect(forceScan:Bool,delegate:SyncControllerDelegate){
        AppTheme.DLog("New delegate : \(delegate)")
        var res:Bool = true
        for value in mDelegates{
            if(value.isEqual(delegate)) {
                res = false
            }
        }

        if(res) {
            mDelegates.append(delegate)
        }
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

    func  getDailyTracker(trackerno:UInt8){
        sendRequest(ReadDailyTracker(trackerno:trackerno))
    }

    func getGoal(){
        sendRequest(GetStepsGoalRequest())
    }


    func ReadBatteryLevel() {
        sendRequest(ReadBatteryLevelNevoRequest())
    }

    func GET_TodaySleepData()->NSArray{
        return todaySleepData;
    }

    // MARK: -AppDelegate syncActivityData
    /**
     This function will syncrhonise activity data with the watch.
     It is a long process and hence shouldn't be done too often, so we save the date of previous sync.
     The watch should be emptied after all data have been saved.
     */
    func syncActivityData() {

        if( NSDate().timeIntervalSince1970-lastSync > SYNC_INTERVAL) {
            //We haven't synched for a while, let's sync now !
            AppTheme.DLog("*** Sync started ! ***")
            self.getDailyTrackerInfo()
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
        lastSync = NSDate().timeIntervalSince1970
        let userDefaults = NSUserDefaults.standardUserDefaults();
        userDefaults.setObject(NSDate().timeIntervalSince1970,forKey:LAST_SYNC_DATE_KEY)
        userDefaults.synchronize()
    }

    /**
     Remove MyNevoDelegate
     */
    func removeMyNevoDelegate(){
        for i in 0 ..< mDelegates.count{
            if mDelegates[i] is MyNevoController{
                mDelegates.removeAtIndex(i)
            }
        }
    }

    // MARK: - UIAlertViewDelegate
    /**
    See UIAlertViewDelegate
    */
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if(alertView.tag == alertUpdateTag) {
            if(buttonIndex == 1) {
                let tabVC:UITabBarController = self.window?.rootViewController as! UITabBarController
                let otaCont:NevoOtaViewController = NevoOtaViewController()
                let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
                tabVC.presentViewController(navigation, animated: true, completion: nil)
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

    func sendRequest(r:Request) {
        if(isConnected()){
            SyncQueue.sharedInstance.post( { (Void) -> (Void) in

                self.mConnectionController?.sendRequest(r)

            } )
        }else {
            //tell caller
            for delegate in mDelegates {
                delegate.connectionStateChanged(false)
            }
        }
    }

    // MARK: - ConnectionControllerDelegate
    /**
     Called when a packet is received from the device
     */
    func packetReceived(packet: RawPacket) {

        mPacketsbuffer.append(packet.getRawData())
        if(packet.isLastPacket()) {
            let packet:NevoPacket = NevoPacket(packets:mPacketsbuffer)
            if(!packet.isVaildPacket()) {
                AppTheme.DLog("Invaild packet............\(packet.getPackets().count)")
                mPacketsbuffer = []
                return;
            }

            for delegate in mDelegates {
                delegate.packetReceived(packet)
            }

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
                let notificationTypeArray:[NotificationType] = [NotificationType.CALL, NotificationType.EMAIL, NotificationType.FACEBOOK, NotificationType.SMS, NotificationType.WECHAT]
                for notificationType in notificationTypeArray {
                    for model in notArray{
                        let notification:UserNotification = model as! UserNotification
                        if(notification.NotificationType == notificationType.rawValue){
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
                var alarmArray:[Alarm] = []
                let array:NSArray = UserAlarm.getAll()

                if(AppDelegate.getAppDelegate().getSoftwareVersion().integerValue > 18){
                    for index in 0 ..< mDelegates.count{
                        let date:NSDate = NSDate()
                        let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: index, alarmWeekday: 0)
                        if(AppDelegate.getAppDelegate().isConnected()){
                            AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                        }
                    }

                    var sleepAlarmCount:Int = 7
                    var dayAlarmCount:Int = 0
                    for alarm in array{
                        let alarmModel:UserAlarm =  alarm as! UserAlarm
                        if(alarmModel.type == 1 && alarmModel.status) {
                            let date:NSDate = NSDate(timeIntervalSince1970: alarmModel.timer)
                            let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: sleepAlarmCount, alarmWeekday: alarmModel.dayOfWeek)

                            if(AppDelegate.getAppDelegate().isConnected()){
                                AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                            }

                            sleepAlarmCount+=1
                        }else if (alarmModel.type == 0 && alarmModel.status){
                            let date:NSDate = NSDate(timeIntervalSince1970: alarmModel.timer)
                            let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: dayAlarmCount, alarmWeekday: alarmModel.dayOfWeek)

                            if(AppDelegate.getAppDelegate().isConnected()){
                                AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                            }

                            dayAlarmCount += 1
                        }
                    }

                    //start sync data
                    self.syncActivityData()

                }else{
                    for index in 0 ..< array.count{
                        let useralarm:UserAlarm = array[index] as! UserAlarm
                        let date:NSDate = NSDate(timeIntervalSince1970: useralarm.timer)
                        if(useralarm.status) {
                            let alarm:Alarm = Alarm(index:index, hour: date.hour, minute: date.minute, enable: useralarm.status)
                            alarmArray.append(alarm)
                        }
                    }

                    for index in 0 ..< 3{
                        let date:NSDate = NSDate()
                        let alarm:Alarm = Alarm(index:index, hour: date.hour, minute: date.minute, enable: false)
                        alarmArray.append(alarm)
                    }
                    setAlarm(alarmArray)
                }
            }

            if(packet.getHeader() == SetAlarmRequest.HEADER()) {
                if(AppDelegate.getAppDelegate().getSoftwareVersion().integerValue <= 18){
                    //start sync data
                    self.syncActivityData()
                }
            }

            if(packet.getHeader() == ReadDailyTrackerInfo.HEADER()) {
                let thispacket = packet.copy() as DailyTrackerInfoNevoPacket
                currentDay = 0
                savedDailyHistory = thispacket.getDailyTrackerInfo()
                AppTheme.DLog("History Total Days:\(savedDailyHistory.count),Today is \(GmtNSDate2LocaleNSDate(NSDate()))")
                if savedDailyHistory.count > 0 {
                    self.getDailyTracker(currentDay)
                }
            }

            if(packet.getHeader() == ReadDailyTracker.HEADER()) {
                let thispacket:DailyTrackerNevoPacket = packet.copy() as DailyTrackerNevoPacket
                let today:NSDate  = NSDate()
                let dateFormatter:NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                let currentDateStr:NSString = dateFormatter.stringFromDate(today)

                let timeStr:NSString = NSString(format: "\(thispacket.getDateTimer())")
                if(timeStr.length < 8 ) {
                    return
                }
                let year:NSString = timeStr.substringWithRange(NSMakeRange(0,4)) as NSString
                let month:NSString = timeStr.substringWithRange(NSMakeRange(4,2)) as NSString
                let day:NSString = timeStr.substringWithRange(NSMakeRange(6,2)) as NSString
                let timerInterval:NSDate = NSDate.date(year: year.integerValue, month: month.integerValue, day: day.integerValue)
                let timerInter:NSTimeInterval = timerInterval.timeIntervalSince1970

                let stepsArray = UserSteps.getCriteria("WHERE createDate = \(timeStr)")
                let stepsModel:UserSteps = UserSteps(keyDict: [
                    "id":0,
                    "steps":thispacket.getDailySteps(),
                    "goalsteps":thispacket.getStepsGoal(),
                    "distance":thispacket.getDailyDist(),
                    "hourlysteps":AppTheme.toJSONString(thispacket.getHourlySteps()),
                    "hourlydistance":AppTheme.toJSONString(thispacket.getHourlyDist()),
                    "calories":thispacket.getDailyCalories() ,
                    "hourlycalories":AppTheme.toJSONString(thispacket.getHourlyCalories()),
                    "inZoneTime":thispacket.getInZoneTime(),
                    "outZoneTime":thispacket.getOutZoneTime(),
                    "inactivityTime":thispacket.getInactivityTime(),
                    "goalreach":Double(thispacket.getDailySteps())/Double(thispacket.getStepsGoal()),
                    "date":timerInter,
                    "createDate":timeStr,
                    "walking_distance":thispacket.getDailyWalkingDistance(),
                    "walking_duration":thispacket.getDailyWalkingTimer(),
                    "walking_calories":thispacket.getDailyCalories(),
                    "running_distance":thispacket.getRunningDistance(),
                    "running_duration":thispacket.getDailyRunningTimer(),
                    "running_calories":thispacket.getDailyCalories()])
                
                //upload steps data to validic
                UPDATE_VALIDIC_REQUEST.updateToValidic(NSArray(arrayLiteral: stepsModel))
                
                if(stepsArray.count>0) {
                    let step:UserSteps = stepsArray[0] as! UserSteps
                    if(step.steps < thispacket.getDailySteps()) {
                        AppTheme.DLog("Data that has been saved····")
                        stepsModel.id = step.id
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), { () -> Void in
                            stepsModel.update()
                        })
                    }
                }else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), { () -> Void in
                        stepsModel.add({ (id, completion) -> Void in
                        })
                    })
                }

                //save sleep data for every hour.
                //save format: first write wake, then write sleep(light&deep)
                if(currentDateStr.integerValue == thispacket.getDateTimer()){
                    let dataArray:[[Int]] = [thispacket.getHourlySleepTime(),thispacket.getHourlyWakeTime(),thispacket.getHourlyLightTime(),thispacket.getHourlyDeepTime()]
                    if(todaySleepData.count==0){
                        todaySleepData.addObject(dataArray)
                    }else{
                        todaySleepData.insertObject(dataArray, atIndex: 1)
                    }
                }

                let yesterdayDateStr:NSString = dateFormatter.stringFromDate(NSDate.yesterday())
                if(yesterdayDateStr.integerValue == thispacket.getDateTimer()) {
                    let dataArray:[[Int]] = [thispacket.getHourlySleepTime(),thispacket.getHourlyWakeTime(),thispacket.getHourlyLightTime(),thispacket.getHourlyDeepTime()]
                    if(todaySleepData.count==0) {
                        todaySleepData.addObject(dataArray)
                    }else {
                        todaySleepData.insertObject(dataArray, atIndex: 0)
                    }
                }

                let sleepArray = UserSleep.getCriteria("WHERE date = \(timerInterval.timeIntervalSince1970)")
                let model:UserSleep = UserSleep(keyDict: [
                    "id": 0,
                    "date":timerInterval.timeIntervalSince1970,
                    "totalSleepTime":0,
                    "hourlySleepTime":"\(AppTheme.toJSONString(thispacket.getHourlySleepTime()))",
                    "totalWakeTime":0,
                    "hourlyWakeTime":"\(AppTheme.toJSONString(thispacket.getHourlyWakeTime()))" ,
                    "totalLightTime":0,
                    "hourlyLightTime":"\(AppTheme.toJSONString(thispacket.getHourlyLightTime()))",
                    "totalDeepTime":0,
                    "hourlyDeepTime":"\(AppTheme.toJSONString(thispacket.getHourlyDeepTime()))"])
                
                //upload sleep data to validic
                //UPDATE_VALIDIC_REQUEST.updateSleepDataToValidic(NSArray(arrayLiteral: stepsModel))
                
                if(sleepArray.count>0) {
                    let sleep:UserSleep = sleepArray[0] as! UserSleep
                    model.id = sleep.id
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), { () -> Void in
                        model.update()
                    })
                }else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), { () -> Void in
                        model.add({ (id, completion) -> Void in
                        })
                    })
                }


                savedDailyHistory[Int(currentDay)].TotalSteps = thispacket.getDailySteps()
                savedDailyHistory[Int(currentDay)].HourlySteps = thispacket.getHourlySteps()
                savedDailyHistory[Int(currentDay)].TotalCalories = thispacket.getDailyCalories()
                savedDailyHistory[Int(currentDay)].HourlyCalories = thispacket.getHourlyCalories()
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Daily Steps:\(savedDailyHistory[Int(currentDay)].TotalSteps)")

                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Hourly Steps:\(savedDailyHistory[Int(currentDay)].HourlySteps)")

                //save to health kit
                let hk = NevoHKImpl()
                hk.requestPermission()

                let now:NSDate = NSDate()
                let saveDay:NSDate = savedDailyHistory[Int(currentDay)].Date
                let nowDate:NSDate = NSDate.date(year: now.year, month: now.month, day: now.day, hour: now.hour, minute: 0, second: 0)
                let saveDate:NSDate = NSDate.date(year: saveDay.year, month: saveDay.month, day: saveDay.day, hour: saveDay.hour, minute: 0, second: 0)

                // to HK Running
                for index:Int in 0 ..< thispacket.getHourlyRunningDistance().count {
                    if(thispacket.getHourlyRunningDistance()[index] > 0) {
                        hk.writeDataPoint(RunningToHK(distance:Double(thispacket.getHourlyRunningDistance()[index]), date:NSDate.date(year: saveDay.year, month: saveDay.month, day: saveDay.day, hour: index, minute: 0, second: 0)), resultHandler: { (result, error) in

                        })
                    }
                }

                // to HK Calories
                for index:Int in 0 ..< thispacket.getHourlyCalories().count {
                    if savedDailyHistory[Int(currentDay)].HourlyCalories[index] > 0 && index == now.hour &&
                        !nowDate.isEqualToDate(saveDate){

                        hk.writeDataPoint(CaloriesToHK(calories: Double(savedDailyHistory[Int(currentDay)].HourlyCalories[index]), date: NSDate.date(year: saveDay.year, month: saveDay.month, day: saveDay.day, hour: index, minute: 0, second: 0)), resultHandler: { (result, error) in
                            if (result != true) {
                                AppTheme.DLog("Save Hourly Calories error\(index),\(error)")
                            }else{
                                AppTheme.DLog("Save Hourly Calories OK")
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
                        !nowDate.isEqualToDate(saveDate){
                        hk.writeDataPoint(HourlySteps(numberOfSteps: savedDailyHistory[Int(currentDay)].HourlySteps[i],date: savedDailyHistory[Int(currentDay)].Date,hour:i,update: false), resultHandler: { (result, error) -> Void in
                            if (result != true) {
                                AppTheme.DLog("Save Hourly steps error\(i),\(error)")
                            }else{
                                AppTheme.DLog("Save Hourly steps OK")
                            }
                        })
                    }
                }

                //end save
                currentDay += 1
                if(currentDay < UInt8(savedDailyHistory.count)) {
                    self.getDailyTracker(currentDay)
                }else {
                    currentDay = 0
                    self.syncFinished()
                    for delegate in mDelegates {
                        delegate.syncFinished()
                    }
                }
            }

            if(packet.getHeader() == GetStepsGoalRequest.HEADER()) {
                _ = packet.copy() as DailyStepsNevoPacket
                //refresh current hourly steps changing in the healthkit
            }
            
            //find Phone
            if (TestMode.shareInstance(packet.getPackets()).isTestModel()) {
                AppTheme.playSound()
            }
            
            mPacketsbuffer = []
        }
    }

    func connectionStateChanged(isConnected : Bool) {
        //send local notification

        for delegate in mDelegates {
            delegate.connectionStateChanged(isConnected)
        }

        if(isConnected) {
            if(self.hasSavedAddress()){
                let banner = Banner(title: NSLocalizedString("Connected", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.hexStringToColor("#0dac67"))
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
            }

            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.connected)

            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                //setp1: cmd 0x01, set RTC, for every connected Nevo
                self.mPacketsbuffer = []
                self.setRTC()
            })

        }else {
            if(self.hasSavedAddress()){
                let banner = Banner(title: NSLocalizedString("Disconnected", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.redColor())
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
            }

            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.disconnected)
            SyncQueue.sharedInstance.clear()
            mPacketsbuffer = []
        }
    }

    func firmwareVersionReceived(whichfirmware:DfuFirmwareTypes, version:NSString) {
        let mcuver = AppTheme.GET_SOFTWARE_VERSION()
        let blever = AppTheme.GET_FIRMWARE_VERSION()

        AppTheme.DLog("Build in software version: \(mcuver), firmware version: \(blever)")

        if ((whichfirmware == DfuFirmwareTypes.SOFTDEVICE  && version.integerValue < mcuver)
            || (whichfirmware == DfuFirmwareTypes.APPLICATION  && version.integerValue < blever)) {
            //for tutorial screen, don't popup update dialog
            if !mAlertUpdateFW {
                mAlertUpdateFW = true
                let titleString:String = NSLocalizedString("Update", comment: "")
                let msg:String = NSLocalizedString("An_update_is_available_for_your_watch", comment: "")
                let buttonString:String = NSLocalizedString("Update", comment: "")
                let cancelString:String = NSLocalizedString("Cancel", comment: "")

                if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){
                    let tabVC:UITabBarController = self.window?.rootViewController as! UITabBarController

                    let actionSheet:UIAlertController = UIAlertController(title: titleString, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                    let alertAction1:UIAlertAction = UIAlertAction(title: cancelString, style: UIAlertActionStyle.Cancel, handler: { ( alert) -> Void in

                    })
                    actionSheet.addAction(alertAction1)

                    let alertAction2:UIAlertAction = UIAlertAction(title: buttonString, style: UIAlertActionStyle.Default, handler: { ( alert) -> Void in
                        let otaCont:NevoOtaViewController = NevoOtaViewController()
                        let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
                        tabVC.presentViewController(navigation, animated: true, completion: nil)

                    })
                    actionSheet.addAction(alertAction2)
                    tabVC.presentViewController(actionSheet, animated: true, completion: nil)
                }else{
                    let actionSheet:UIAlertView = UIAlertView(title: titleString, message: msg, delegate: self, cancelButtonTitle: cancelString, otherButtonTitles: buttonString)
                    actionSheet.layer.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
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
    func receivedRSSIValue(number:NSNumber){
        for delegate in mDelegates {
            if delegate is MyNevoController{
                delegate.receivedRSSIValue(number)
            }
        }
    }

    func bluetoothEnabled(enabled:Bool) {
        if(!enabled && self.hasSavedAddress()) {
            let banner = Banner(title: NSLocalizedString("bluetooth_turned_off_enable", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.redColor())
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

protocol SyncControllerDelegate:NSObjectProtocol {

    /**
     Called when a packet is received from the device
     */
    func packetReceived(packet: NevoPacket)
    /**
     Called when a peripheral connects or disconnects
     */
    func connectionStateChanged(isConnected : Bool)
    /**
     *  Receiving the current device signal strength value
     */
    func receivedRSSIValue(number:NSNumber)
    /**
     *  Data synchronization is complete callback
     */
    func syncFinished()
}