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
    fileprivate var isLunaRFirstPair:Bool = false
    
    fileprivate var isSync:Bool = true; // syc state
    fileprivate var getWacthNameTimer:Timer?
    //Default Hong Kong
    fileprivate var longitude:Double = 114.1670679
    fileprivate var latitude:Double = 22.2782551
    
    var isFirsttimeLaunch: Bool {
        get {
            let result = UserDefaults.standard.bool(forKey: "kLunarIsNotFirstTimeLaunch")
            UserDefaults.standard.set(true, forKey: "kLunarIsNotFirstTimeLaunch")
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
        UINavigationBar.appearance().lt_setBackgroundColor(UIColor.getLunarTabBarColor())
        
        UINavigationBar.appearance().tintColor = UIColor.getBaseColor()
        
        UITabBar.appearance().backgroundColor = UIColor.getGreyColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white,NSFontAttributeName:UIFont(name: "Raleway", size: 20)!]
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        IQKeyboardManager.sharedManager().enable = true
        
        // 在这里授权以保证在接收到数据的时候可以写入
        NevoHKManager.manager.requestPermission()
        
        updateDataBase()
        
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
    
    func updateDataBase() {
        let config = Realm.Configuration(
            // 设置新的架构版本。这个版本号必须高于之前所用的版本号（如果您之前从未设置过架构版本，那么这个版本号设置为 0）
            schemaVersion: 2,
            // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
            migrationBlock: { migration, oldSchemaVersion in
                // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
                if (oldSchemaVersion < 2) {
                    // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
                }
        })
        // 告诉 Realm 为默认的 Realm 数据库使用这个新的配置对象
        Realm.Configuration.defaultConfiguration = config
    }
    
    func isSyncState()-> Bool {
        return isSync
    }
    
    func getMconnectionController()->ConnectionControllerImpl?{
        return mConnectionController
    }
    
    func setWactnID(_ id:Int) {
        let info: [String : Int] = [EVENT_BUS_WATCHID_DIDCHANGE_KEY : id]
        SwiftEventBus.post(EVENT_BUS_WATCHID_DIDCHANGE_KEY, sender: nil, userInfo: info)
        XCGLogger.default.debug("setWactnID")
        UserDefaults.standard.set(id, forKey: WATCHKEY_SETID)
        UserDefaults.standard.synchronize()
    }
    
    func getWactnID()->Int {
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
                setNewAlarm()
            }

            
            if(packet.getHeader() == SetAlarmRequest.HEADER()) {
                //start sync data
                self.syncActivityData()
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
            
            if(packet.getHeader() == ReadDailyTracker.HEADER()) {
                let thispacket:LunaRDailyTrackerPacket = packet.copy() as LunaRDailyTrackerPacket
                
                let timerDate:Date = thispacket.getDate()
                let timeString:String = String(format: "%@" ,timerDate.stringFromFormat("yyyyMMdd"))
                if(timeString.length() < 8) {
                    return
                }
                
                //save steps data for every hour.
                let hourlyStepsValue = self.saveStepsToDataBase(thispacket: thispacket, date: timerDate,dateString: timeString)
                
                //save sleep data for every hour.
                //save format: first write wake, then write sleep(light&deep)
                self.saveSleepToDataBase(thispacket: thispacket, date: timerDate, dateString: timeString)
                
                //save solar harvest data for every hour.
                self.saveSolarHarvest(thispacket: thispacket, date: timerDate)
                
                //save data to apple HealthKit
                self.saveToHealthKit(thispacket: thispacket, date: timerDate,hourlySteps:hourlyStepsValue)
                
                //end save
                currentDay += 1
                if(currentDay < UInt8(savedDailyHistory.count)) {
                    if currentDay == 1 {
                        SwiftEventBus.post(EVENT_BUS_BEGIN_BIG_SYNCACTIVITY, sender:nil)
                    }
                    self.getDailyTracker(currentDay)
                }else {
                    self.getLunaRTotalAppId()
                    //currentDay = 0
                    isSync = false
                    self.syncFinished()
                    SwiftEventBus.post(EVENT_BUS_END_BIG_SYNCACTIVITY, sender:nil)
                }
            }
            
            if(packet.getHeader() == GetTotalNotificationAppReuqest.HEADER()) {
                let thispacket = packet.copy() as GetotalAppIDPacket
                let currentAppNumber:Int = thispacket.getTotalAppsNumber()

                for i in 0..<currentAppNumber {
                    let appIDRequest:GetNotificationAppIDRequest = GetNotificationAppIDRequest(number: i)
                    self.sendRequest(appIDRequest)
                }
                
                if currentAppNumber == 0 {
                    LunaRNotfication()
                }
            }
            
            if(packet.getHeader() == GetNotificationAppIDRequest.HEADER()) {
                let thispacket = packet.copy() as GetNotificationAppIDPacket
                let appidString:String = thispacket.getApplicationID()
                XCGLogger.default.debug("getApplicationID:\(appidString),LEDPattern:\(thispacket.getLEDPattern())")
                self.saveNotificationAppID(appid: appidString,isNewApp:false)
            }
            
            
            if packet.getHeader() == DeleteAllNotificationAppIDRequest.HEADER() {
                let thispacket = packet.copy() as DeleteAllAppIDPacket
                XCGLogger.default.debug("DeleteAllAppIDPacket,state:\(thispacket.getDeleteStatus())")
                LunaRNotfication()
            }
            
            if packet.getHeader() == SetNotificationAppIDRequest.HEADER() {
                XCGLogger.default.debug("SetNotificationAppIDRequest")
                if isLunaRFirstPair {
                    self.setRTC()
                }
            }
            
            if packet.getHeader() == NewAppIDNotificationRequest.HEADER() {
                let thispacket = packet.copy() as ReceiveNewNotificationPacket
                let appidString:String = thispacket.getApplicationID()
                XCGLogger.default.debug("getApplicationID:\(appidString)")
                self.saveNotificationAppID(appid: appidString,isNewApp:true)
            }

            if(packet.getHeader() == GetStepsGoalRequest.HEADER()) {
                //refresh current hourly steps changing in the healthkit
                let thispacket = packet.copy() as LunaRStepsGoalPacket
                let dailySteps:Int = thispacket.getDailySteps()
                let dailyStepGoal:Int = thispacket.getDailyStepsGoal()
                let percent :Float = Float(dailySteps)/Float(dailyStepGoal)
                SwiftEventBus.post(EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY, sender:["STEPS":dailySteps,"GOAL":dailyStepGoal,"PERCENT":percent] as AnyObject)
                if getFirmwareVersion() >= Float(buildin_firmware_version) {
                    XCGLogger.default.debug("DailyStepsNevoPacket,steps:\(dailySteps),stepGoal:\(dailyStepGoal),getRTC:\(thispacket.getDateTimer().stringFromFormat("yyyy-MM-dd HH:mm:ss"))")
                }
            }
            
            //new find Phone
            if (packet.getHeader() == FindPhonePacket.HEADER()) {
                AppTheme.playSound()
            }
            
            mPacketsbuffer = []
        }
    }
    
    func connectionStateChanged(_ isConnected : Bool, fromAddress : UUID!,isFirstPair:Bool) {
        //send local notification
        SwiftEventBus.post(EVENT_BUS_CONNECTION_STATE_CHANGED_KEY, sender:isConnected as AnyObject)
        
        if(isConnected) {
            self.connectedBanner()
            
            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.connected)
            
            XCGLogger.default.debug("Connected")
            //setp1: cmd 0x01, set RTC, for every connected Nevo
            self.mPacketsbuffer = []
            
            if isFirstPair {
                isLunaRFirstPair = true
                self.deleteAllLunaRNotfication()
            }else{
                isLunaRFirstPair = false
                
                self.getWatchNameRequest()
                
                self.getWacthNameTimer = Timer.after(5, {
                    XCGLogger.default.debug("Timer.after+++++🐅🐅🐅🐅🐅🐅🐅+++++Timer.after")
                    self.setRTC()
                })
            }
        }else {
            self.disConnectedBanner()
            isSync = false
            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.disconnected)
            SyncQueue.sharedInstance.clear()
            mPacketsbuffer = []
        }
    }
    
    func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:Float) {
        let blever = buildin_firmware_version
        
        XCGLogger.default.debug("Build in firmware version: \(blever)")
        
        if (whichfirmware == DfuFirmwareTypes.application  && version < Float(blever)) {
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
                self.setSolar()
                
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
    
    func setSolar() {
        if let solar = Solar(latitude: latitude, longitude: longitude), let sunrise = solar.sunrise, let sunset = solar.sunset {
            self.setSunriseAndSunset(sunrise: sunrise, sunset: sunset)
        } else {
            let solar = Solar(latitude: 22.2782551, longitude: 114.1670679)     // HK as Default, every optional must have a value, not nil.
            self.setSunriseAndSunset(sunrise: solar!.sunrise!, sunset: solar!.sunset!)
        }
    }
    
    func getSunriseAndSunsetTime() -> (sunriseDate: Date?, sunsetDate: Date?, additionString: String) {
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
            let solar = Solar(latitude: 22.2782551, longitude: 114.1670679)
            return (solar?.sunrise, solar?.sunset, "")
        }
    }
    
    func getSunriseAndSunsetTime(date: Date) -> (sunriseDate: Date?, sunsetDate: Date?, additionString: String) {
        if let solar = Solar(forDate: date, withTimeZone: TimeZone.current, latitude: latitude, longitude: longitude) {
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
            let solar = Solar(forDate: date, withTimeZone: TimeZone.current, latitude: 22.2782551, longitude: 114.1670679)
            return (solar?.sunrise, solar?.sunset, "")
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
    
    func saveNotificationAppID(appid:String,isNewApp:Bool) {
        let array = appid.characters.split(separator: ".")
        let object = MEDUserNotification.getFilter("appid = '\(appid)'")
        if object.count == 0 {
            let userNotification:MEDUserNotification = MEDUserNotification()
            userNotification.key = appid
            let lastValue = array.last
            if lastValue != nil {
                userNotification.appName = String(format: "%@", lastValue.debugDescription)
            }else{
                userNotification.appName = "Notification"
            }
            userNotification.colorValue = UIColor.getRandomColor().hexString(false);
            userNotification.colorName = "Color"
            userNotification.notificationType  = NotificationType.other.rawValue as String
            userNotification.receiveDate = Date().timeIntervalSince1970
            userNotification.appid = appid
            _ = userNotification.add()
        }else{
            if !isNewApp {
                let userNotification:MEDUserNotification = object[0] as! MEDUserNotification
                if !userNotification.isAddWatch {
                    let realm = try! Realm()
                    try! realm.write {
                        userNotification.isAddWatch = true
                    }
                }
            }
        }
    }
    
    func saveToHealthKit(thispacket:LunaRDailyTrackerPacket,date:Date,hourlySteps:[Int]) {
        //TODO:crash  有可能数组会越界
        if Int(currentDay)<savedDailyHistory.count {
            savedDailyHistory[Int(currentDay)].TotalSteps = thispacket.getTotalSteps()
            savedDailyHistory[Int(currentDay)].HourlySteps = hourlySteps
            savedDailyHistory[Int(currentDay)].TotalCalories = thispacket.getTotalCalories()
            savedDailyHistory[Int(currentDay)].HourlyCalories = thispacket.getHourlyCalories()
            
            //save to health kit
            let hk = NevoHKManager.manager
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
    }
}
