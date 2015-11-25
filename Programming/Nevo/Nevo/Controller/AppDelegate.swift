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
    let SYNC_INTERVAL:NSTimeInterval = 0*30*60 //unit is second in iOS, every 30min, do sync
    let LAST_SYNC_DATE_KEY = "LAST_SYNC_DATE_KEY"
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

        //Start the logo for the first time
        if(!NSUserDefaults.standardUserDefaults().boolForKey("everLaunched")){
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "everLaunched")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstLaunch")
        }else{
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstLaunch")
        }

        mConnectionController = ConnectionControllerImpl()
        mConnectionController?.setDelegate(self)

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

    /**
     Format from the alarm data

     :param: alarmArray Alarm dictionary

     :returns: Returns the Alarm
     */
    func getLoclAlarm(alarmArray:NSDictionary)->Alarm{
        let alarm_index:Int = (alarmArray.objectForKey(AlarmClockController.SAVED_ALARM_INDEX_KEY) as! NSNumber).integerValue
        let alarm_hour:Int = (alarmArray.objectForKey(AlarmClockController.SAVED_ALARM_HOUR_KEY) as! NSNumber).integerValue
        let alarm_min:Int = (alarmArray.objectForKey(AlarmClockController.SAVED_ALARM_MIN_KEY) as! NSNumber).integerValue
        let alarm_enabled:Bool = (alarmArray.objectForKey(AlarmClockController.SAVED_ALARM_ENABLED_KEY) as! NSNumber).boolValue
        let alarm:Alarm = Alarm(index: alarm_index, hour: alarm_hour, minute: alarm_min, enable: alarm_enabled)
        return alarm
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
        var lastSync = 0.0
        if let lastSyncSaved = NSUserDefaults.standardUserDefaults().objectForKey(LAST_SYNC_DATE_KEY) as? Double {
            lastSync = lastSyncSaved
        }

        if( NSDate().timeIntervalSince1970-lastSync > SYNC_INTERVAL) {
            //We haven't synched for a while, let's sync now !
            AppTheme.DLog("*** Sync started ! ***")
            self.getDailyTrackerInfo()
        }

    }

    /**
     When the sync process is finished, le't refresh the date of sync
     */
    func syncFinished() {

        AppTheme.DLog("*** Sync finished ***")

        let userDefaults = NSUserDefaults.standardUserDefaults();

        userDefaults.setObject(NSDate().timeIntervalSince1970,forKey:LAST_SYNC_DATE_KEY)

        userDefaults.synchronize()
    }

    /**
     return true, if it is not the first run
     return false ,if it is running the tutorial screen
     */
    func hasLoadHomeController() ->Bool{
        for delegate in mDelegates {
            if delegate is HomeController
            {
                return true
            }
        }
        return false
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

        if(buttonIndex==1){
            //GOTO OTA SCREEN
            for delegate in mDelegates {
                if delegate is HomeController{
                    (delegate as! HomeController).gotoOTAScreen()
                    break
                }
            }
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
    func packetReceived(packet: RawPacket){

        mPacketsbuffer.append(packet.getRawData())
        if(packet.isLastPacket())
        {
            let packet:NevoPacket = NevoPacket(packets:mPacketsbuffer)
            if(!packet.isVaildPacket())
            {
                AppTheme.DLog("Invaild packet............\(packet.getPackets().count)")
                mPacketsbuffer = []
                return;
            }

            for delegate in mDelegates {
                delegate.packetReceived(packet)
            }

            //We just received a full response, so we can safely send the next request
            SyncQueue.sharedInstance.next()

            if(packet.getHeader() == SetRTCRequest.HEADER())
            {
                //setp2:start set user profile
                self.SetProfile()
            }
            if(packet.getHeader() == SetProfileRequest.HEADER())
            {
                //step3:
                self.WriteSetting()
            }

            if(packet.getHeader() == WriteSettingRequest.HEADER())
            {
                //step4:
                self.SetCardio()
            }

            if(packet.getHeader() == SetCardioRequest.HEADER())
            {
                //step5: sync the notification setting, if remove nevo's battery, the nevo notification reset, so here need sync it
                var mNotificationSettingArray:[NotificationSetting] = []
                let allType:[NotificationType] = [NotificationType.CALL, NotificationType.SMS, NotificationType.EMAIL, NotificationType.FACEBOOK, NotificationType.CALENDAR, NotificationType.WECHAT, NotificationType.WHATSAPP]
                for notType in allType{
                    let notificatiosetting:NotificationSetting = NotificationSetting(type:notType, color: 0)
                    let color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(notificatiosetting.getType().rawValue))
                    let states = EnterNotificationController.getMotorOnOff(notificatiosetting.getType().rawValue)
                    notificatiosetting.updateValue(color, states: states)
                    mNotificationSettingArray.append(notificatiosetting)
                }
                //start sync notification setting on the phone side
                SetNortification(mNotificationSettingArray)
            }

            if(packet.getHeader() == SetNortificationRequest.HEADER())
            {
                //copy from AlarmClockController
                let mAlarmhour:Int = 8
                let mAlarmmin:Int = 30
                let mAlarmenable:Bool = false
                var alarm:[Alarm] = []

                let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                //If we have any previously saved hour, min and/or enabled/ disabled, we'll use those variables first
                let forKey:[String] = [AlarmClockController.SAVED_ALARM_ARRAY0,AlarmClockController.SAVED_ALARM_ARRAY1,AlarmClockController.SAVED_ALARM_ARRAY2]
                for(var index:Int = 0;index<forKey.count;index++){
                    if let alarmArray = userDefaults.objectForKey(forKey[index]) as? NSDictionary {
                        alarm.append(getLoclAlarm(alarmArray))
                    }else{
                        alarm.append(Alarm(index: index,hour: mAlarmhour,minute: mAlarmmin,enable: mAlarmenable))
                    }
                }
                setAlarm(alarm)
            }

            if(packet.getHeader() == SetAlarmRequest.HEADER())
            {
                //start sync data
                self.syncActivityData()
            }

            if(packet.getHeader() == ReadDailyTrackerInfo.HEADER())
            {
                let thispacket = packet.copy() as DailyTrackerInfoNevoPacket
                currentDay = 0
                savedDailyHistory = thispacket.getDailyTrackerInfo()
                AppTheme.DLog("History Total Days:\(savedDailyHistory.count),Today is \(GmtNSDate2LocaleNSDate(NSDate()))")
                if savedDailyHistory.count > 0
                {
                    self.getDailyTracker(currentDay)
                }
            }

            if(packet.getHeader() == ReadDailyTracker.HEADER()){
                let thispacket:DailyTrackerNevoPacket = packet.copy() as DailyTrackerNevoPacket

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

                //save sleep data for every hour.
                //save format: first write wake, then write sleep(light&deep)
                let today:NSDate  = NSDate()
                let dateFormatter:NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                let currentDateStr:NSString = dateFormatter.stringFromDate(today)

                if(currentDateStr.integerValue == thispacket.getDateTimer()){
                    let dataArray:[[Int]] = [thispacket.getHourlySleepTime(),thispacket.getHourlyWakeTime(),thispacket.getHourlyLightTime(),thispacket.getHourlyDeepTime()]
                    if(todaySleepData.count==0){
                        todaySleepData.addObject(dataArray)
                    }else{
                        todaySleepData.insertObject(dataArray, atIndex: 1)
                    }
                }

                if(currentDateStr.integerValue-1 == thispacket.getDateTimer()){
                    let dataArray:[[Int]] = [thispacket.getHourlySleepTime(),thispacket.getHourlyWakeTime(),thispacket.getHourlyLightTime(),thispacket.getHourlyDeepTime()]
                    if(todaySleepData.count==0){
                        todaySleepData.addObject(dataArray)
                    }else{
                        todaySleepData.insertObject(dataArray, atIndex: 0)
                    }
                }

                let daysleepSave:DaySleepSaveModel = DaySleepSaveModel()
                daysleepSave.steps = thispacket.getDailySteps()
                daysleepSave.created = thispacket.getDateTimer()
                daysleepSave.HourlySleepTime = AppTheme.toJSONString(thispacket.getHourlySleepTime())
                daysleepSave.HourlyWakeTime = AppTheme.toJSONString(thispacket.getHourlyWakeTime())
                daysleepSave.HourlyLightTime = AppTheme.toJSONString(thispacket.getHourlyLightTime())
                daysleepSave.HourlyDeepTime = AppTheme.toJSONString(thispacket.getHourlyDeepTime())

                AppTheme.DLog("---------------\(thispacket.getDateTimer())")


                 //Test the new database writing situation
                /**
                let sleepSave:SleepModel = SleepModel()
                sleepSave.created = thispacket.getDateTimer()
                sleepSave.Id = 99666
                sleepSave.UserId = 66666
                sleepSave.TotalSleepTime = 122
                sleepSave.HourlySleepTime = AppTheme.toJSONString(thispacket.getHourlySleepTime()) as String
                sleepSave.TotalWakeTime = 123
                sleepSave.HourlyWakeTime = AppTheme.toJSONString(thispacket.getHourlyWakeTime()) as String
                sleepSave.TotalLightTime = 124
                sleepSave.HourlyLightTime = AppTheme.toJSONString(thispacket.getHourlyLightTime()) as String
                sleepSave.TotalDeepTime = 125
                sleepSave.HourlyDeepTime = AppTheme.toJSONString(thispacket.getHourlyDeepTime()) as String

                let sleepQuyerModel:NSArray = SleepModel.getCriteria("WHERE created = \(thispacket.getDateTimer())")
                if(sleepQuyerModel.count > 0){
                    for array in sleepQuyerModel{
                        let sleepModel:UserDatabaseHelper = array as! UserDatabaseHelper
                        sleepSave.pk = sleepModel.pk
                        let ave:Bool = sleepSave.update()
                    }
                }else{
                    let ave:Bool = sleepSave.add()
                }
                */

                //Query the database is this record
                let quyerModel = DaySleepSaveModel.findFirstByCriteria("WHERE created = \(thispacket.getDateTimer())")
                if(quyerModel != nil){
                    AppTheme.DLog("Data that has been saved····")
                    daysleepSave.update()
                    //Analyzing whether the same data database is not updated if they are equal, otherwise the update the database
                }else{
                    //Don't have any database if the sleep time is zero
                    if(thispacket.getDailySleepTime() != 0){
                        let isSave:Bool = daysleepSave.save()  //If not, save database
                    }
                }

                //end save
                currentDay++
                if(currentDay < UInt8(savedDailyHistory.count)){
                    self.getDailyTracker(currentDay)
                }else{
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
            if (TestMode.shareInstance(packet.getPackets()).isTestModel()){
                AppTheme.playSound()
            }
            
            mPacketsbuffer = []
        }
    }

    func connectionStateChanged(isConnected : Bool) {
        //send local notification
        if isConnected {
            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.connected)
        }else {
            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.disconnected)
        }

        for delegate in mDelegates {
            delegate.connectionStateChanged(isConnected)
        }

        if( isConnected )
        {
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                //setp1: cmd 0x01, set RTC, for every connected Nevo
                self.mPacketsbuffer = []
                self.setRTC()
            })

        }
        else
        {
            SyncQueue.sharedInstance.clear()
            mPacketsbuffer = []
        }
    }

    func firmwareVersionReceived(whichfirmware:DfuFirmwareTypes, version:NSString)
    {
        let mcuver = GET_SOFTWARE_VERSION()
        let blever = GET_FIRMWARE_VERSION()

        AppTheme.DLog("Build in software version: \(mcuver), firmware version: \(blever)")

        if ((whichfirmware == DfuFirmwareTypes.SOFTDEVICE  && version.integerValue < mcuver)
            || (whichfirmware == DfuFirmwareTypes.APPLICATION  && version.integerValue < blever))

        {
            //for tutorial screen, don't popup update dialog
            if !mAlertUpdateFW  && hasLoadHomeController()
            {
                mAlertUpdateFW = true

                let alert :UIAlertView = UIAlertView(title: NSLocalizedString("Firmware Upgrade", comment: ""), message: NSLocalizedString("FirmwareAlertMessage", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ok", comment: ""))
                alert.show()
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