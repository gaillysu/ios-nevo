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
import CoreLocation
import Solar
import Timepiece
import RealmSwift
import Kingfisher


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
    fileprivate var savedDailyHistory:[LunaRPacket.TotalHistory] = []
    fileprivate var currentDay:UInt8 = 0
    fileprivate var mAlertUpdateFW = false
    
    fileprivate var watchID:Int = 1 {
        didSet {
            let info: [String : Int] = [EVENT_BUS_WATCHID_DIDCHANGE_KEY : watchID]
            SwiftEventBus.post(EVENT_BUS_WATCHID_DIDCHANGE_KEY, sender: nil, userInfo: info)
        }
    }
    fileprivate var watchName:String = "Nevo"
    fileprivate var watchModelNumber:Int = 1
    fileprivate var watchModel:String = "Paris"
    fileprivate var isSync:Bool = true; // syc state
    fileprivate var getWacthNameTimer:Timer?
    
    fileprivate var longitude:Double = 0
    fileprivate var latitude:Double = 0
    
    var isFirsttimeLaunch: Bool {
        get {
            let result = UserDefaults.standard.bool(forKey: "kLunarIsNotFirstTimeLaunch")
            UserDefaults.standard.set(true, forKey: "kLunarIsNotFirstTimeLaunch")
            return !result
        }
    }
    
    let dbQueue:FMDatabaseQueue = FMDatabaseQueue(path: AppDelegate.dbPath())
    let network = NetworkReachabilityManager(host: "drone.karljohnchow.com")
    
    class func getAppDelegate()->AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        // Override point for customization after application launch
        UINavigationBar.appearance().tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundColor = UIColor.getBarColor()
        UINavigationBar.appearance().lt_setBackgroundColor(UIColor.getBarColor())
        //set navigationBar font style and font color
        UINavigationBar.appearance().lt_setBackgroundColor(UIColor.getLunarTabBarColor())
        
        UINavigationBar.appearance().tintColor = UIColor.getBaseColor()
        
        UITabBar.appearance().backgroundColor = UIColor.getGreyColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white,NSFontAttributeName:UIFont(name: "Raleway", size: 20)!]
        
        UIApplication.shared.statusBarStyle = .lightContent

        IQKeyboardManager.sharedManager().enable = true
    
        DispatchQueue.global(qos: .background).async {
            WorldClockDatabaseHelper().setup()
        }
        
        MEDUserGoal.defaultUserGoal()
        
        MEDUserNotification.defaultNotificationColor()
        
        MEDUserAlarm.defaultAlarm()
        
        let kingfisherCache = KingfisherManager.shared.cache
        /// Default cache period is 7 days, but the app's icon changes rarely, in case one day there is on network or cache for user... so set 30 days! 
        kingfisherCache.maxCachePeriodInSecond = TimeInterval(60 * 60 * 24 * 30)
        
        /**
         Initialize the BLE Manager
         */
        self.mConnectionController = ConnectionControllerImpl()
        self.mConnectionController?.setDelegate(self)
        
        self.adjustLaunchLogic()
        
        let userDefaults = UserDefaults.standard;
        //lastSync = userDefaults.double(forKey: LAST_SYNC_DATE_KEY)
        
        //start Location
        self.startLocation()
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
            let packet:LunaRPacket = LunaRPacket(packets:mPacketsbuffer)
            if(!packet.isVaildPacket()) {
                XCGLogger.default.debug("Invaild packet............\(packet.getPackets().count)")
                mPacketsbuffer = []
                return;
            }
            SwiftEventBus.post(EVENT_BUS_RAWPACKET_DATA_KEY, sender: packet)
            
            //We just received a full response, so we can safely send the next request
            SyncQueue.sharedInstance.next()
            
            if(packet.getHeader() == GetWatchName.HEADER()) {
                let watchpacket = packet.copy() as LunaRWatchNamePacket
                self.setWatchInfo(watchpacket.getWatchID(), model: watchpacket.getModelNumber())
                //start sync data
                //self.syncActivityData()
                if let timer = getWacthNameTimer?.isValid {
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
                self.setSolar()
            }
            
            if(packet.getHeader() == SetSunriseAndSunsetRequest.HEADER()) {
                //step5: sync the notification setting, if remove nevo's battery, the nevo notification reset, so here need sync it
                //let deleAll:DeleteAllNotificationAppIDRequest = DeleteAllNotificationAppIDRequest()
                //self.sendRequest(deleAll)
                SetNortification()
            }
            
            if packet.getHeader() == DeleteAllNotificationAppIDRequest.HEADER() {
                let thispacket = packet.copy() as DeleteAllAppIDPacket
                XCGLogger.default.debug("DeleteAllAppIDPacket,state:\(thispacket.getDeleteStatus())")
                LunaRNotfication()
            }
            
            if(packet.getHeader() == SetNortificationRequest.HEADER()) {
                let lunarAlarm:[MEDUserAlarm] = MEDUserAlarm.getAll() as! [MEDUserAlarm]
                let weakAlarm:[MEDUserAlarm] = lunarAlarm.filter({$0.type == 0})
                let sleepAlarm:[MEDUserAlarm] = lunarAlarm.filter({$0.type == 1})
                
                for index in 0 ..< 14{
                    let date:Date = Date()
                    let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: index, alarmWeekday: 0)
                    if(self.isConnected()){
                        self.setNewAlarm(newAlarm)
                    }
                }
                
                let date:Date = Date()
                for (index,Value) in weakAlarm.enumerated() {
                    let alarm:MEDUserAlarm = Value
                    let alarmDay:Date = Date(timeIntervalSince1970: alarm.timer)
                    if alarm.status {
                        let newAlarm:NewAlarm = NewAlarm(alarmhour: alarmDay.hour, alarmmin: alarmDay.minute, alarmNumber: index, alarmWeekday: alarm.alarmWeek)
                        self.setNewAlarm(newAlarm)
                    }
                }
                
                for (index,Value) in sleepAlarm.enumerated() {
                    let alarm:MEDUserAlarm = Value
                    let alarmDay:Date = Date(timeIntervalSince1970: alarm.timer)
                    print("alarmDay:\(alarmDay),alarm:\(alarm.type,alarm.status,alarm.alarmWeek,date.weekday)")
                    if alarm.type == 1 && alarm.status && alarm.alarmWeek == date.weekday{
                        let newAlarm:NewAlarm = NewAlarm(alarmhour: alarmDay.hour, alarmmin: alarmDay.minute, alarmNumber: index+7, alarmWeekday: 0)
                        self.setNewAlarm(newAlarm)
                    }else{
                        if alarm.status && alarm.alarmWeek >= date.weekday{
                            let newAlarm:NewAlarm = NewAlarm(alarmhour: alarmDay.hour, alarmmin: alarmDay.minute, alarmNumber: index+7, alarmWeekday: alarm.alarmWeek)
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
            }
            
            if packet.getHeader() == NewAppIDNotificationRequest.HEADER() {
                let thispacket = packet.copy() as ReceiveNewNotificationPacket
                let appidString:String = thispacket.getApplicationID()
                let object = MEDUserNotification.getFilter("appid = '\(appidString)'")
                if object.count == 0 {
                    let userNotification:MEDUserNotification = MEDUserNotification()
                    userNotification.key = appidString
                    userNotification.appName = "···"
                    userNotification.receiveDate = Date().timeIntervalSince1970
                    userNotification.appid = appidString
                    _ = userNotification.add()
                }
                XCGLogger.default.debug("getApplicationID:\(appidString)")
            }
            
            if(packet.getHeader() == ReadDailyTrackerInfo.HEADER()) {
                let thispacket = packet.copy() as LunaRDailyTrackerInfoPacket
                currentDay = 0
                savedDailyHistory = thispacket.getTotalTrackerInfo()
                XCGLogger.default.debug("History Total Days:\(self.savedDailyHistory.count),Today is \(GmtNSDate2LocaleNSDate(Date()))")
                if savedDailyHistory.count > 0 {
                    self.getDailyTracker(currentDay)
                }
            }
            
            if(packet.getHeader() == GetStepsGoalRequest.HEADER()) {
                //refresh current hourly steps changing in the healthkit
                let thispacket = packet.copy() as LunaRStepsGoalPacket
                let dailySteps:Int = thispacket.getDailySteps()
                let dailyStepGoal:Int = thispacket.getDailyStepsGoal()
                let percent :Float = Float(dailySteps)/Float(dailyStepGoal)
                SwiftEventBus.post(EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY, sender:["STEPS":dailySteps,"GOAL":dailyStepGoal,"PERCENT":percent] as AnyObject)
                
            }
            
            if (packet.getHeader() == GetTotalNotificationAppReuqest.HEADER()){
                let thispacket = packet.copy() as GetotalAppIDPacket
                XCGLogger.default.debug("GetotalAppIDPacket,number:\(thispacket.getTotalAppsNumber()))")
            }
            
            if(packet.getHeader() == ReadDailyTracker.HEADER()) {
                let thispacket:LunaRDailyTrackerPacket = packet.copy() as LunaRDailyTrackerPacket
                
                let timeStr:String = String(format: "%@" ,thispacket.getDate().stringFromFormat("yyyyMMdd"))
                if(timeStr.length() < 8 ) {
                    return
                }
                
                let timerInterval:Date = thispacket.getDate()
                
                //save steps data for every hour.
                let hourlyStepsValue = self.saveStepsToDataBase(thispacket: thispacket, date: timerInterval,dateString: timeStr)
                
                //save sleep data for every hour.
                //save format: first write wake, then write sleep(light&deep)
                self.saveSleepToDataBase(thispacket: thispacket, date: timerInterval, dateString: timeStr)
                
                //save solar harvest data for every hour.
                self.saveSolarHarvest(thispacket: thispacket, date: timerInterval)
                
                //TODO:crash  有可能数组会越界
                if Int(currentDay)<savedDailyHistory.count {
                    savedDailyHistory[Int(currentDay)].TotalSteps = thispacket.getTotalSteps()
                    savedDailyHistory[Int(currentDay)].HourlySteps = hourlyStepsValue
                    savedDailyHistory[Int(currentDay)].TotalCalories = thispacket.getTotalCalories()
                    savedDailyHistory[Int(currentDay)].HourlyCalories = thispacket.getHourlyCalories()
                    
                    //save to health kit
                    let hk = NevoHKImpl()
                    hk.requestPermission()
                    
                    let now:Date = Date()
                    let saveDay:Date = savedDailyHistory[Int(currentDay)].Date as Date
                    let nowDate:Date = Date.date(year: now.year, month: now.month, day: now.day, hour: now.hour, minute: 0, second: 0)
                    let saveDate:Date = Date.date(year: saveDay.year, month: saveDay.month, day: saveDay.day, hour: saveDay.hour, minute: 0, second: 0)
                    
                    // to HK Running
                    for index:Int in 0 ..< thispacket.getHourlyRunDist().count {
                        let runValue = thispacket.getHourlyRunDist()[index]
                        if(runValue > 0) {
                            hk.writeDataPoint(RunningToHK(distance:Double(runValue), date:Date.date(year: saveDay.year, month: saveDay.month, day: saveDay.day, hour: index, minute: 0, second: 0)), resultHandler: { (result, error) in
                                
                            })
                        }
                    }
                    
                    // to HK Calories
                    for index:Int in 0 ..< thispacket.getHourlyCalories().count {
                        if savedDailyHistory[Int(currentDay)].HourlyCalories[index] > 0 && index == now.hour &&
                            (nowDate != saveDate){
                            
                            hk.writeDataPoint(CaloriesToHK(calories: Double(savedDailyHistory[Int(currentDay)].HourlyCalories[index]), date: Date.date(year: saveDay.year, month: saveDay.month, day: saveDay.day, hour: index, minute: 0, second: 0)), resultHandler: { (result, error) in
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
                let thispacket = packet.copy() as LunaRStepsGoalPacket
                let dailySteps:Int = thispacket.getDailySteps()
                let dailyStepGoal:Int = thispacket.getDailyStepsGoal()
                let percent :Float = Float(dailySteps)/Float(dailyStepGoal)
                SwiftEventBus.post(EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY, sender:["STEPS":dailySteps,"GOAL":dailyStepGoal,"PERCENT":percent] as AnyObject)
                XCGLogger.default.debug("DailyStepsNevoPacket,steps:\(dailySteps),stepGoal:\(dailyStepGoal),getRTC:\(thispacket.getDateTimer().stringFromFormat("yyyy-MM-dd HH:mm:ss"))")
            }
            
            //new find Phone
            if (packet.getHeader() == FindPhonePacket.HEADER()) {
                AppTheme.playSound()
            }
            
            //old find Phone
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
                
                // is this necessary? i have to change the rootViewController's Class during launch, maybe...
                //                    let tabVC:UITabBarController = self.window?.rootViewController as! UITabBarController
                let tabVC = self.window?.rootViewController
                
                let actionSheet:ActionSheetView = ActionSheetView(title: titleString, message: msg, preferredStyle: UIAlertControllerStyle.alert)
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

extension AppDelegate {

    func startLocation() {
        NSLog("AuthorizationStatus:\(LOCATION_MANAGER.gpsAuthorizationStatus)")
        if LOCATION_MANAGER.gpsAuthorizationStatus>2 {
            LOCATION_MANAGER.startLocation()
            LOCATION_MANAGER.didChangeAuthorization = { status in
                let states:CLAuthorizationStatus = status as CLAuthorizationStatus
                XCGLogger.default.debug("Location didChangeAuthorization:\(states.rawValue)")
            }
            
            LOCATION_MANAGER.didUpdateLocations = { location in
                let locationArray = location as [CLLocation]
                XCGLogger.default.debug("Location didUpdateLocations:\(locationArray)")
                self.longitude = locationArray.last!.coordinate.longitude
                self.latitude = locationArray.last!.coordinate.latitude
                NSLog("longitude:\(self.longitude),latitude:\(self.latitude)")
                self.setSolar()
                
            }
            
            LOCATION_MANAGER.didFailWithError = { error in
                XCGLogger.default.debug("Location didFailWithError:\(error)")
            }
        }
    }
    
    func setSolar() {
        if longitude != 0 && latitude != 0 {
            let solar = Solar(latitude: latitude,
                              longitude: longitude)
            let sunrise = solar!.sunrise
            let sunset = solar!.sunset
            self.setSunriseAndSunset(sunrise: sunrise!, sunset: sunset!)
        }
    }
    
    func getLongitude() -> Double {
        return longitude;
    }
    
    func getLatitude() -> Double {
        return latitude;
    }
    
    func saveSolarHarvest(thispacket:LunaRDailyTrackerPacket,date:Date)  {
        let login = MEDUserProfile.getAll()
        if login.count>0 {
            let userProfile:MEDUserProfile = login[0] as! MEDUserProfile
            let uidString:String = "\(userProfile.uid)"
            let keys:String = date.stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)+uidString
            let solar = SolarHarvest.getFilter("key = \(keys)")
            if solar.count == 0 {
                let solarTime:SolarHarvest = SolarHarvest()
                solarTime.key = keys
                solarTime.date = date.timeIntervalSince1970
                solarTime.solarTotalTime = thispacket.getTotalSolarHarvestingTime()
                solarTime.solarHourlyTime = "\(AppTheme.toJSONString(thispacket.getHourlyHarvestTime() as AnyObject!))"
                solarTime.uid = userProfile.uid
                _ = solarTime.add()
            }else{
                let solarTime:SolarHarvest = solar[0] as! SolarHarvest
                solarTime.date = date.timeIntervalSince1970
                solarTime.solarTotalTime = thispacket.getTotalSolarHarvestingTime()
                solarTime.solarHourlyTime = "\(AppTheme.toJSONString(thispacket.getHourlyHarvestTime() as AnyObject!))"
                solarTime.uid = userProfile.uid;
                _ = solarTime.update()
            }
        }else{
            let keys:String = date.stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)
            let solarTime:SolarHarvest = SolarHarvest()
            solarTime.key = keys
            solarTime.date = date.timeIntervalSince1970
            solarTime.solarTotalTime = thispacket.getTotalSolarHarvestingTime()
            solarTime.solarHourlyTime = "\(AppTheme.toJSONString(thispacket.getHourlyHarvestTime() as AnyObject!))"
            solarTime.uid = 0
            _ = solarTime.add()
        }
    }
    
    func saveStepsToDataBase(thispacket:LunaRDailyTrackerPacket,date:Date,dateString:String) ->[Int] {
        let login = MEDUserProfile.getAll()
        
        let stepsModel:MEDUserSteps = MEDUserSteps()
        stepsModel.totalSteps = thispacket.getTotalSteps()
        stepsModel.goalsteps = thispacket.getStepsGoal()
        stepsModel.distance = thispacket.getTotalDistance()
        let stepsWalkValue = thispacket.getHourlyWalkSteps()
        let stepsRunValue = thispacket.getHourlyRunSteps()
        var hourlyStepsValue:[Int] = [Int](repeating: 0, count: 24)
        for (index,value) in stepsWalkValue.enumerated() {
            let runValue:Int = stepsRunValue[index]
            hourlyStepsValue.replaceSubrange(index..<index+1, with: [value+runValue])
        }
        XCGLogger.default.debug("hourlyStepsValue:\(hourlyStepsValue)")
        stepsModel.hourlysteps = "\(AppTheme.toJSONString(hourlyStepsValue as AnyObject!))"
        
        let distanceWalkVlaue = thispacket.getHourlyWalkDist()
        let distanceRunVlaue = thispacket.getHourlyRunDist()
        var hourlyDistanceValue:[Int] = [Int](repeating: 0, count: 24)
        for (index,value) in distanceWalkVlaue.enumerated() {
            let distanceValue:Int = distanceRunVlaue[index]
            hourlyDistanceValue.replaceSubrange(index..<index+1, with: [distanceValue+value])
        }
        stepsModel.hourlydistance = "\(AppTheme.toJSONString(hourlyDistanceValue as AnyObject!))"
        stepsModel.totalCalories = Double(thispacket.getTotalCalories())
        stepsModel.hourlycalories = "\(AppTheme.toJSONString(thispacket.getHourlyCalories() as AnyObject!))"
        stepsModel.inactivityTime = thispacket.getInactivityTime()
        stepsModel.goalreach = Double(thispacket.getTotalSteps())/Double(thispacket.getStepsGoal())
        stepsModel.date = date.timeIntervalSince1970
        stepsModel.createDate = "\(dateString)"
        stepsModel.walking_distance = thispacket.getTotalWalkDistance()
        stepsModel.walking_duration = thispacket.getTotalWalkTime()
        stepsModel.running_distance = thispacket.getTotalRunDistance()
        stepsModel.running_duration = thispacket.getTotalRunTime()
        
        if login.count>0 {
            let userProfile:MEDUserProfile = login[0] as! MEDUserProfile
            let uidString:String = "\(userProfile.uid)"
            let keys:String = date.stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)+uidString
            stepsModel.uid = userProfile.uid
            stepsModel.key = keys
            
            let dateString:String = date.stringFromFormat("yyy-MM-dd")
            var caloriesValue:Int = 0
            var milesValue:Double = 0
            StepGoalSetingController.calculationData((stepsModel.walking_duration+stepsModel.running_duration), steps: stepsModel.totalSteps, completionData: { (miles, calories) in
                caloriesValue = Int(calories)
                milesValue = miles
            })
            
            let activeTime: Int = stepsModel.walking_duration+stepsModel.running_duration
            
            MEDStepsNetworkManager.createSteps(uid: userProfile.uid, steps: stepsModel.hourlysteps, date: dateString, activeTime: activeTime, calories: caloriesValue, distance: milesValue, completion: { (success: Bool) in
                if success {
                    stepsModel.isUpload = true
                    _ = stepsModel.add()
                }else{
                    stepsModel.isUpload = false
                    _ = stepsModel.add()
                }
            })
            
            //let stepsArray = MEDUserSteps.getFilter("key == '\(keys)'")
        }else{
            let keys:String = date.stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)
            //let stepsArray = MEDUserSteps.getFilter("key == '\(keys)'")
            stepsModel.uid = 0
            stepsModel.key = keys
            stepsModel.isUpload = false
            _ = stepsModel.add()
        }
        return hourlyStepsValue;
    }
    
    func saveSleepToDataBase(thispacket:LunaRDailyTrackerPacket,date:Date,dateString:String) {
        let login = MEDUserProfile.getAll()
        
        let sleepModel:MEDUserSleep = MEDUserSleep()
        sleepModel.date = date.timeIntervalSince1970
        sleepModel.totalSleepTime = thispacket.getTotalSleepTime()
        sleepModel.hourlySleepTime = "\(AppTheme.toJSONString(thispacket.getHourlySleepTime() as AnyObject!))"
        sleepModel.totalWakeTime = thispacket.getTotalWakeTime()
        sleepModel.hourlyWakeTime = "\(AppTheme.toJSONString(thispacket.getHourlyWakeSleepTime() as AnyObject!))"
        sleepModel.totalLightTime = thispacket.getTotalWakeTime()
        sleepModel.hourlyLightTime = "\(AppTheme.toJSONString(thispacket.getHourlyLightSleepTime() as AnyObject!))"
        sleepModel.totalDeepTime = thispacket.getTotalDeepTime()
        sleepModel.hourlyDeepTime = "\(AppTheme.toJSONString(thispacket.getHourlyDeepSleepTime() as AnyObject!))"
        
        if login.count>0 {
            let userProfile:MEDUserProfile = login[0] as! MEDUserProfile
            let uidString:String = "\(userProfile.uid)"
            let keys:String = date.stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)+uidString
            sleepModel.uid = userProfile.uid
            sleepModel.key = keys
            
            let dateString:String = date.stringFromFormat("yyy-MM-dd")
            
            MEDSleepNetworkManager.createSleep(uid: userProfile.uid, deepSleep: sleepModel.hourlyDeepTime, lightSleep: sleepModel.hourlyLightTime, wakeTime: sleepModel.hourlyWakeTime, date: dateString, completion: { (success:Bool) in
                
            })
            
            let sleepArray = MEDUserSleep.getFilter("key = '\(keys)'")
            if sleepArray.count>0 {
                let sleep:MEDUserSleep = sleepArray[0] as! MEDUserSleep
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
                    sleepModel.isUpload = true
                    _ = sleepModel.add()
                }
            }
        }else{
            let keys:String = date.stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)
            sleepModel.uid = 0
            sleepModel.key = keys
            _ = sleepModel.add()
        }
    }
}
