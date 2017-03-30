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
import RealmSwift


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

    fileprivate var isSync:Bool = true; // syc state
    fileprivate var getWacthNameTimer:Timer?
    
    var longitude:Double = 0
    var latitude:Double = 0
    
    var isFirsttimeLaunch: Bool {
        get {
            let result = UserDefaults.standard.bool(forKey: "kIsNotFirstTimeLaunch")
            UserDefaults.standard.set(true, forKey: "kIsNotFirstTimeLaunch")
            return !result
        }
    }

    let network = NetworkReachabilityManager(host: "nevowatch.com")
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
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black,NSFontAttributeName:UIFont(name: "Raleway", size: 20)!]
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
        updateDataBase()
        
        IQKeyboardManager.sharedManager().enable = true
        
        //Start the logo for the first time
        if(!UserDefaults.standard.bool(forKey: "LaunchedDatabase")){
            UserDefaults.standard.set(true, forKey: "LaunchedDatabase")
            UserDefaults.standard.set(true, forKey: "firstDatabase")
            //search not watch = -1
            self.setWatchInfo(-1, model: -1)
        }else{
            UserDefaults.standard.set(false, forKey: "firstDatabase")
        }

        MEDUserGoal.defaultUserGoal()
        MEDUserNotification.defaultNotificationColor()
        MEDUserAlarm.defaultAlarm()
        
        /**
        Initialize the BLE Manager
        */
        self.setUpBTManager()
        //let userDefaults = UserDefaults.standard;
        //lastSync = userDefaults.double(forKey: LAST_SYNC_DATE_KEY)
        
        adjustLaunchLogic()
        
        return true
    }

    func updateDataBase() {
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 2) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
    }

    func isSyncState()-> Bool {
        return isSync
    }
    
    func getMconnectionController()->ConnectionControllerImpl?{
        return mConnectionController
    }
    
    func setUpBTManager() {
        if mConnectionController == nil {
            self.mConnectionController = ConnectionControllerImpl()
            self.mConnectionController?.setDelegate(self)
        }else{
            self.mConnectionController?.setDelegate(self)
        }
    }
    
    func cleanUpBTManager() {
        if mConnectionController != nil {
            mConnectionController?.stopScan()
            mConnectionController?.disconnect()
            mConnectionController = nil
        }
    }
    
    func setWatchID(_ id:Int) {
        let info: [String : Int] = [EVENT_BUS_WATCHID_DIDCHANGE_KEY : id]
        SwiftEventBus.post(EVENT_BUS_WATCHID_DIDCHANGE_KEY, sender: nil, userInfo: info)
        
        UserDefaults.standard.set(id, forKey: WATCHKEY_SETID)
        UserDefaults.standard.synchronize()
    }
    
    func getWatchID()->Int {
        if let watchID = UserDefaults.standard.object(forKey: WATCHKEY_SETID) {
            return watchID as! Int
        }
        return -1
    }
    
    func setWatchName(_ name:String) {
        UserDefaults.standard.set(name, forKey: WATCHKEY_SETNAME)
        UserDefaults.standard.synchronize()
    }
    
    func getWatchName() ->String {
        if let watchID = UserDefaults.standard.object(forKey: WATCHKEY_SETNAME) {
            return watchID as! String
        }
        return "";
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
            
            if(packet.getHeader() == ReadBatteryLevelNevoRequest.HEADER()){
                let thispacket:BatteryLevelNevoPacket = packet.copy() as BatteryLevelNevoPacket
                if(thispacket.isReadBatteryCommand(packet.getPackets())){
                    let batteryValue:Int = thispacket.getBatteryLevel()
                    SwiftEventBus.post(EVENT_BUS_BATTERY_STATUS_CHANGED, sender:batteryValue);
                }
            }
            
            if(packet.getHeader() == GetWatchName.HEADER()) {
                let watchpacket = packet.copy() as WatchNamePacket
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
                self.SetCardio()
            }

            if(packet.getHeader() == SetCardioRequest.HEADER()) {
                //step5: sync the notification setting, if remove nevo's battery, the nevo notification reset, so here need sync it
                var mNotificationSettingArray:[NotificationSetting] = []
                let notArray = MEDUserNotification.getAll()
                let notificationTypeArray:[NotificationType] = [NotificationType.call, NotificationType.email, NotificationType.facebook, NotificationType.sms, NotificationType.wechat]
                for notificationType in notificationTypeArray {
                    for model in notArray{
                        let notification:MEDUserNotification = model as! MEDUserNotification
                        if(notification.notificationType == notificationType.rawValue as String){
                            let setting:NotificationSetting = NotificationSetting(type: notificationType, clock: notification.clock, color: "",colorName: "", states:notification.isAddWatch,packet:notification.appid,appName:notification.appName)
                            mNotificationSettingArray.append(setting)
                            break
                        }
                    }
                }
                //start sync notification setting on the phone side
                XCGLogger.default.debug("SetNortification++++++++++++++")
                SetNortification(mNotificationSettingArray)
            }

            if(packet.getHeader() == SetNortificationRequest.HEADER()) {
                
                self.setNewAlarm()
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
                let timerInterval:Date = thispacket.getDateTimer()
                let timeStr:String = thispacket.getDateTimer().stringFromFormat("yyyyMMdd", locale: DateFormatter().locale)
                
                if self.getWatchID()>1 {
                    saveSolarHarvest(thispacket: thispacket, date: thispacket.getDateTimer())
                }
                
                XCGLogger.default.debug("dateString====:\(timeStr)")
                //save steps
                let hourlySteps = self.saveStepsToDataBase(thispacket: thispacket, date: timerInterval, dateString: timeStr)
                
                //save sleep data for every hour.
                //save format: first write wake, then write sleep(light&deep)
                self.saveSleepToDataBase(thispacket: thispacket, date: timerInterval, dateString: timeStr)


                //TODO:crash  数组越界
                if Int(currentDay)<savedDailyHistory.count {
                    savedDailyHistory[Int(currentDay)].TotalSteps = thispacket.getDailySteps()
                    savedDailyHistory[Int(currentDay)].HourlySteps = thispacket.getHourlySteps()
                    savedDailyHistory[Int(currentDay)].TotalCalories = thispacket.getDailyCalories()
                    savedDailyHistory[Int(currentDay)].HourlyCalories = thispacket.getHourlyCalories()
                    
                    //save to health kit
                    let hk = NevoHKManager.manager
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
                if getFirmwareVersion() >= Float(buildin_firmware_version) {
                    XCGLogger.default.debug("DailyStepsNevoPacket,steps:\(dailySteps),stepGoal:\(dailyStepGoal),getRTC:\(thispacket.getDateTimer().stringFromFormat("yyyy-MM-dd HH:mm:ss"))")
                }
                //XCGLogger.default.debug("DailyStepsNevoPacket,steps:\(dailySteps),stepGoal:\(dailyStepGoal),getRTC:\(thispacket.getDateTimer().stringFromFormat("yyyy-MM-dd hh:mm:ss"))")
                SwiftEventBus.post(EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY, sender:["STEPS":dailySteps,"GOAL":dailyStepGoal,"PERCENT":percent] as AnyObject)
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

    func connectionStateChanged(_ isConnected : Bool, fromAddress : UUID!,isFirstPair:Bool) {
        //send local notification
        SwiftEventBus.post(EVENT_BUS_CONNECTION_STATE_CHANGED_KEY, sender:isConnected as AnyObject)

        if(isConnected) {
            if(self.hasSavedAddress()){
                let banner = MEDBanner(title: NSLocalizedString("Connected", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor("#0dac67"))
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
                    //如果超时说明是一个普通的Nevo,Watch Info 要重新配置
                    self.setWatchInfo(1, model: 1)
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

    func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:Float) {
        let mcuver = Float(buildin_software_version)
        let blever = Float(buildin_firmware_version)

        XCGLogger.default.debug("Build in software version: \(mcuver), firmware version: \(blever)")

        if ((whichfirmware == DfuFirmwareTypes.softdevice  && version < mcuver)
            || (whichfirmware == DfuFirmwareTypes.application  && version < blever)) {
            //for tutorial screen, don't popup update dialog 
            if !mAlertUpdateFW {
                mAlertUpdateFW = true
                let titleString:String = NSLocalizedString("Update", comment: "")
                let msg:String = NSLocalizedString("An_update_is_available_for_your_watch", comment: "")
                let buttonString:String = NSLocalizedString("Update", comment: "")
                let cancelString:String = NSLocalizedString("Cancel", comment: "")

                let tabVC = self.window?.rootViewController
                
                let actionSheet:MEDAlertController = MEDAlertController(title: titleString, message: msg, preferredStyle: UIAlertControllerStyle.alert)
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
        NSLog("AuthorizationStatus:\(LocationManager.instanceLocation.gpsAuthorizationStatus)")
        if LocationManager.instanceLocation.gpsAuthorizationStatus>2 {
            LocationManager.instanceLocation.startLocation()
            LocationManager.instanceLocation.didChangeAuthorization = { status in
                let states:CLAuthorizationStatus = status as CLAuthorizationStatus
                XCGLogger.default.debug("Location didChangeAuthorization:\(states.rawValue)")
            }
            
            LocationManager.instanceLocation.didUpdateLocations = { location in
                let locationArray = location as [CLLocation]
                XCGLogger.default.debug("Location didUpdateLocations:\(locationArray)")
                self.longitude = locationArray.last!.coordinate.longitude
                self.latitude = locationArray.last!.coordinate.latitude
                NSLog("longitude:\(self.longitude),latitude:\(self.latitude)")
//                self.setSolar()
            }
            
            LocationManager.instanceLocation.didFailWithError = { error in
                XCGLogger.default.debug("Location didFailWithError:\(error)")
            }
        }else{
            let banner:MEDBanner = MEDBanner(title: NSLocalizedString("Location Error", comment: ""), subtitle: NSLocalizedString("LunaR needs your location to set the sunset and sunrise time. ", comment: ""), image: nil, backgroundColor: UIColor.getBaseColor(), didTapBlock: {
                
            })
            banner.show()
        }
    }
    
    func getLongitude() -> Double {
        return longitude;
    }
    
    func getLatitude() -> Double {
        return latitude;
    }
    
    func saveSolarHarvest(thispacket:DailyTrackerNevoPacket,date:Date)  {
        let login = MEDUserProfile.getAll()
        if login.count>0 {
            let userProfile:MEDUserProfile = login[0] as! MEDUserProfile
            let uidString:String = "\(userProfile.uid)"
            let keys:String = date.stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)+uidString
            let solar = SolarHarvest.getFilter("key = '\(keys)'")
            if solar.count == 0 {
                let solarTime:SolarHarvest = SolarHarvest()
                solarTime.key = keys
                solarTime.date = date.timeIntervalSince1970
                solarTime.solarTotalTime = thispacket.getTotalHarvestTime()
                solarTime.solarHourlyTime = "\(AppTheme.toJSONString(thispacket.getHourlyHarestTime() as AnyObject!))"
                solarTime.uid = userProfile.uid
                _ = solarTime.add()
            }else{
                let solarTime:SolarHarvest = solar[0] as! SolarHarvest
                let realm = try! Realm()
                try! realm.write {
                    solarTime.date = date.timeIntervalSince1970
                    solarTime.solarTotalTime = thispacket.getTotalHarvestTime()
                    solarTime.solarHourlyTime = "\(AppTheme.toJSONString(thispacket.getHourlyHarestTime() as AnyObject!))"
                    solarTime.uid = userProfile.uid;
                }
            }
        }else{
            let keys:String = date.stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)
            let solarTime:SolarHarvest = SolarHarvest()
            solarTime.key = keys
            solarTime.date = date.timeIntervalSince1970
            solarTime.solarTotalTime = thispacket.getTotalHarvestTime()
            solarTime.solarHourlyTime = "\(AppTheme.toJSONString(thispacket.getHourlyHarestTime() as AnyObject!))"
            solarTime.uid = 0
            _ = solarTime.add()
        }
    }
    
    
    func saveStepsToDataBase(thispacket:DailyTrackerNevoPacket,date:Date,dateString:String) ->[Int] {
        let login = MEDUserProfile.getAll()
        
        let stepsModel:MEDUserSteps = MEDUserSteps()
        stepsModel.totalSteps = thispacket.getDailySteps()
        stepsModel.goalsteps = thispacket.getStepsGoal()
        stepsModel.distance = thispacket.getDailyDist()
        stepsModel.hourlysteps = "\(AppTheme.toJSONString(thispacket.getHourlySteps() as AnyObject!))"
        stepsModel.hourlydistance = "\(AppTheme.toJSONString(thispacket.getHourlyDist() as AnyObject!))"
        stepsModel.totalCalories = Double(thispacket.getDailyCalories())

        
        let distanceWalkVlaue = thispacket.getHourlyDist()
        let distanceRunVlaue = thispacket.getHourlyRunningDistance()
        var hourlyDistanceValue:[Int] = [Int](repeating: 0, count: 24)
        for (index,value) in distanceWalkVlaue.enumerated() {
            let distanceValue:Int = distanceRunVlaue[index]
            hourlyDistanceValue.replaceSubrange(index..<index+1, with: [distanceValue+value])
        }
        stepsModel.hourlydistance = "\(AppTheme.toJSONString(hourlyDistanceValue as AnyObject!))"
        stepsModel.totalCalories = Double(thispacket.getDailyCalories())
        stepsModel.hourlycalories = "\(AppTheme.toJSONString(thispacket.getHourlyCalories() as AnyObject!))"
        stepsModel.inactivityTime = thispacket.getInactivityTime()
        stepsModel.goalreach = Double(thispacket.getDailySteps())/Double(thispacket.getStepsGoal())
        stepsModel.date = date.timeIntervalSince1970
        stepsModel.createDate = "\(dateString)"
        stepsModel.walking_distance = thispacket.getDailyWalkingDistance()
        stepsModel.walking_duration = thispacket.getDailyWalkingDuration()
        stepsModel.walking_calories = thispacket.getDailyCalories()
        stepsModel.running_distance = thispacket.getRunningDistance()
        stepsModel.running_duration = thispacket.getDailyRunningDuration()
        stepsModel.running_calories = thispacket.getDailyCalories()

        
        if login.count>0 {
            let userProfile:MEDUserProfile = login[0] as! MEDUserProfile
            let uidString:String = "\(userProfile.uid)"
            let keys:String = date.stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)+uidString
            stepsModel.uid = userProfile.uid
            stepsModel.key = keys
            
            let dateString:String = date.stringFromFormat("yyy-MM-dd")
            var caloriesValue:Int = 0
            var milesValue:Double = 0
            DataCalculation.calculationData((stepsModel.walking_duration+stepsModel.running_duration), steps: stepsModel.totalSteps, completionData: { (miles, calories) in
                caloriesValue = Int(calories)
                milesValue = miles
            })
            
            let activeTime: Int = stepsModel.walking_duration+stepsModel.running_duration
            
            MEDStepsNetworkManager.createSteps(uid: userProfile.uid, steps: stepsModel.hourlysteps, date: dateString, activeTime: activeTime, calories: caloriesValue, distance: milesValue, completion: { (success: Bool) in
                
            })
            
            let stepsArray = MEDUserSteps.getFilter("key == '\(keys)'")
            if stepsArray.count>0 {
                let steps:MEDUserSteps = stepsArray[0] as! MEDUserSteps
                let localStepsArray:[Int] = AppTheme.jsonToArray(steps.hourlysteps) as! [Int]
                var localValue:Int = 0
                
                for value in localStepsArray {
                    localValue+=value
                }
                
                let currentStepsArray:[Int] = thispacket.getHourlySteps()
                var currentStepsValue:Int = 0
                for value in currentStepsArray {
                    currentStepsValue+=value
                }
                
                if currentStepsValue>localValue {
                    stepsModel.isUpload = true
                    _ = stepsModel.add()
                }
            }else{
                stepsModel.isUpload = false
                _ = stepsModel.add()
            }
        }else{
            let keys:String = date.stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)
            //let stepsArray = MEDUserSteps.getFilter("key == '\(keys)'")
            stepsModel.uid = 0
            stepsModel.key = keys
            stepsModel.isUpload = false
            _ = stepsModel.add()
        }
        return thispacket.getHourlySteps();
    }
    
    func saveSleepToDataBase(thispacket:DailyTrackerNevoPacket,date:Date,dateString:String) {
        let login = MEDUserProfile.getAll()
        
        let sleepModel:MEDUserSleep = MEDUserSleep()
        sleepModel.date = date.timeIntervalSince1970
        sleepModel.totalSleepTime = thispacket.getDailySleepTime()
        sleepModel.hourlySleepTime = "\(AppTheme.toJSONString(thispacket.getHourlySleepTime() as AnyObject!))"
        sleepModel.totalWakeTime = thispacket.getDailyWakeTime()
        sleepModel.hourlyWakeTime = "\(AppTheme.toJSONString(thispacket.getHourlyWakeTime() as AnyObject!))"
        sleepModel.totalLightTime = thispacket.getDailyLightTime()
        sleepModel.hourlyLightTime = "\(AppTheme.toJSONString(thispacket.getHourlyLightTime() as AnyObject!))"
        sleepModel.totalDeepTime = thispacket.getDailyDeepTime()
        sleepModel.hourlyDeepTime = "\(AppTheme.toJSONString(thispacket.getHourlyDeepTime() as AnyObject!))"
        
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
            }else{
                sleepModel.isUpload = true
                _ = sleepModel.add()
            }
        }else{
            let keys:String = date.stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)
            sleepModel.uid = 0
            sleepModel.key = keys
            sleepModel.isUpload = false
            _ = sleepModel.add()
        }
    }
    
}

