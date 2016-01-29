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

let nevoDBDFileURL:String = "nevoDBName";
let nevoDBNames:String = "nevo.sqlite";

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,ConnectionControllerDelegate {

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


    let dbQueue:FMDatabaseQueue = FMDatabaseQueue(path: AppDelegate.dbPath())

    class func getAppDelegate()->AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //UINavigationBar.appearance().tintColor = UIColor.blackColor()
        //UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        //UITabBar.appearance().barTintColor = UIColor.clearColor()

        UINavigationBar.appearance().tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        //Start the logo for the first time
        if(!NSUserDefaults.standardUserDefaults().boolForKey("LaunchedDatabase")){
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "LaunchedDatabase")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstDatabase")
            Presets.defaultPresetsGoal()
            UserAlarm.defaultAlarm()
            UserNotification.defaultNotificationColor()
        }else{
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstDatabase")
        }
        
        mConnectionController = ConnectionControllerImpl()
        mConnectionController?.setDelegate(self)
        

        UITabBar.appearance().backgroundImage = UIImage()
        //UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().translucent = false

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
            disConnectAlert = UIAlertView(title: NSLocalizedString("BLE_LOST_TITLE", comment: ""), message: NSLocalizedString("BLE_CONNECTION_LOST", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ok", comment: ""))
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
        mDelegates.append(delegate)
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
                let banner = Banner(title: "Syncing data", subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
            }
        }

    }

    /**
     When the sync process is finished, le't refresh the date of sync
     */
    func syncFinished() {
        let banner = Banner(title: "Sync finished", subtitle: nil, image: nil, backgroundColor: AppTheme.hexStringToColor("#0dac67"))
        banner.dismissesOnTap = true
        banner.show(duration: 3.0)

        lastSync = NSDate().timeIntervalSince1970
        AppTheme.DLog("*** Sync finished ***")
        //let userDefaults = NSUserDefaults.standardUserDefaults();
        //userDefaults.setObject(NSDate().timeIntervalSince1970,forKey:LAST_SYNC_DATE_KEY)
        //userDefaults.synchronize()
    }

    /**
     Remove MyNevoDelegate
     */
    func removeMyNevoDelegate(){
        for(var i:Int = 0; i < mDelegates.count; i++){
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

        disConnectAlert = nil

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

    func forgetSavedAddress() {
        self.mConnectionController?.forgetSavedAddress()
    }

    func hasSavedAddress()->Bool {
        return self.mConnectionController!.hasSavedAddress()
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
                let notificationTypeArray:[NotificationType] = [NotificationType.CALL, NotificationType.EMAIL, NotificationType.FACEBOOK, NotificationType.SMS, NotificationType.WHATSAPP]
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
                for(var index:Int = 0; index < array.count; index++){
                    let useralarm:UserAlarm = array[index] as! UserAlarm
                    let date:NSDate = NSDate(timeIntervalSince1970: useralarm.timer)
                    let alarm:Alarm = Alarm(index:index, hour: date.hour, minute: date.minute, enable: useralarm.status)
                    alarmArray.append(alarm)
                }

                setAlarm(alarmArray)
            }

            if(packet.getHeader() == SetAlarmRequest.HEADER()) {
                //start sync data
                self.syncActivityData()
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
                let year:NSString = timeStr.substringWithRange(NSMakeRange(0,4)) as NSString
                let month:NSString = timeStr.substringWithRange(NSMakeRange(4,2)) as NSString
                let day:NSString = timeStr.substringWithRange(NSMakeRange(6,2)) as NSString
                let timerInterval:NSDate = NSDate.date(year: year.integerValue, month: month.integerValue, day: day.integerValue)
                let timerInter:NSTimeInterval = timerInterval.timeIntervalSince1970

                let stepsArray = UserSteps.getCriteria("WHERE createDate = \(timeStr)")
                if(stepsArray.count>0) {
                    let step:UserSteps = stepsArray[0] as! UserSteps
                    if(step.steps < thispacket.getDailySteps()) {
                        AppTheme.DLog("Data that has been saved····")
                        let stepsModel:UserSteps = UserSteps(keyDict: [
                            "id":step.id,
                            "steps":thispacket.getDailySteps(),
                            "goalsteps":thispacket.getStepsGoal(),
                            "distance":thispacket.getDailyDist(),
                            "hourlysteps":AppTheme.toJSONString(thispacket.getHourlySteps()),
                            "hourlydistance":AppTheme.toJSONString(thispacket.getHourlyDist()),
                            "calories":thispacket.getDailyCalories(),
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
                        stepsModel.update()
                    }
                }else {
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
                    stepsModel.add({ (id, completion) -> Void in

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

                if(currentDateStr.integerValue-1 == thispacket.getDateTimer()) {
                    let dataArray:[[Int]] = [thispacket.getHourlySleepTime(),thispacket.getHourlyWakeTime(),thispacket.getHourlyLightTime(),thispacket.getHourlyDeepTime()]
                    if(todaySleepData.count==0) {
                        todaySleepData.addObject(dataArray)
                    }else {
                        todaySleepData.insertObject(dataArray, atIndex: 0)
                    }
                }

                let sleepArray = UserSleep.getCriteria("WHERE date = \(timerInterval.timeIntervalSince1970)")
                if(sleepArray.count>0) {
                    let sleep:UserSleep = sleepArray[0] as! UserSleep
                    let model:UserSleep = UserSleep(keyDict: [
                        "id": sleep.id,
                        "date":timerInterval.timeIntervalSince1970,
                        "totalSleepTime":0,
                        "hourlySleepTime":"\(AppTheme.toJSONString(thispacket.getHourlySleepTime()))",
                        "totalWakeTime":0,
                        "hourlyWakeTime":"\(AppTheme.toJSONString(thispacket.getHourlyWakeTime()))" ,
                        "totalLightTime":0,
                        "hourlyLightTime":"\(AppTheme.toJSONString(thispacket.getHourlyLightTime()))",
                        "totalDeepTime":0,
                        "hourlyDeepTime":"\(AppTheme.toJSONString(thispacket.getHourlyDeepTime()))"])
                    model.update()
                }else {
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
                    model.add({ (id, completion) -> Void in

                    })
                }


                savedDailyHistory[Int(currentDay)].TotalSteps = thispacket.getDailySteps()
                savedDailyHistory[Int(currentDay)].HourlySteps = thispacket.getHourlySteps()
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Daily Steps:\(savedDailyHistory[Int(currentDay)].TotalSteps)")

                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Hourly Steps:\(savedDailyHistory[Int(currentDay)].HourlySteps)")

                //save to health kit
                let hk = NevoHKImpl()
                hk.requestPermission()

                let now:NSDate = NSDate()
                let cal:NSCalendar = NSCalendar.currentCalendar()
                let dd:NSDateComponents = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day ,NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second,], fromDate: now)
                let dd2:NSDateComponents = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day ,NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second,], fromDate: savedDailyHistory[Int(currentDay)].Date)

                for (var i:Int = 0; i<savedDailyHistory[Int(currentDay)].HourlySteps.count; i++){
                    //only save vaild hourly steps for every day, include today.
                    //exclude update current hour step, due to current hour not end
                    //for example: at 10:20~ 10:25AM, walk 100 steps, 10:50~10:59, walk 300 steps
                    //user can't see the 10:00AM record data at 10:XX clock
                    //user can see 10:00AM data when 11:20 do a big sync, the value should be 400 steps
                    //that is to say, user can't see current hour 's step in healthkit, he can see it by waiting one hour
                    if savedDailyHistory[Int(currentDay)].HourlySteps[i] > 0 &&
                        !(i == dd.hour && dd.year == dd2.year && dd.month == dd2.month && dd.day == dd2.day){
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
                currentDay++
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
                var thispacket = packet.copy() as DailyStepsNevoPacket
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
                banner.show(duration: 3.0)
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
                banner.show(duration: 3.0)
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
                let alert :UIAlertView = UIAlertView(title: NSLocalizedString("Firmware Upgrade", comment: ""), message: NSLocalizedString("FirmwareAlertMessage", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ok", comment: ""))
                //alert.show()
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
            banner.show(duration: 3.0)
        }
    }

    func scanAndConnect(){
        if(self.hasSavedAddress()) {
            let banner = Banner(title: NSLocalizedString("search_for_nevo", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
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