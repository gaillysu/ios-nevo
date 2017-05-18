//
//  AppTheme.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 18/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import AudioToolbox
import RegexKitLite
import XCGLogger

let buildin_firmware_version = AppTheme.GET_FIRMWARE_VERSION();
let buildin_software_version = AppTheme.GET_SOFTWARE_VERSION();

enum ActionType {
    case get
    case set
}
/**
This class holds all app-wide constants.
Colors, fonts etc...
*/
class AppTheme {
    /**
    This color should be used app wide on all actionable elements
    sRGB value : #ff9933
    */
    class func NEVO_SOLAR_YELLOW() -> UIColor {
        
        return UIColor("#A08455")
    }

    class func NEVO_SOLAR_GRAY() -> UIColor {
        
        return UIColor("#E5E4E2")
    }
    
    class func NEVO_SOLAR_DARK_GRAY() -> UIColor {
        
        return UIColor("#BCBCBC")
    }
    
    /**
    Custom colors

    :param: reds   The red channel value
    :param: greens The green channel value
    :param: blue   The blue channel value

    :returns: Custom colors
    */
    class func NEVO_CUSTOM_COLOR(Red reds:CGFloat = 186, Green greens:CGFloat = 185, Blue blue:CGFloat = 182) -> UIColor {
        return UIColor(red: reds/255.0 , green: greens/255.0, blue: blue/255.0, alpha: 1)
    }
    
    class func PALETTE_BAGGROUND_COLOR() -> UIColor {
        return UIColor(red: 10/255.0, green: 255/255.0, blue: 178/255.0, alpha: 1)//Uniform
    }

    /**
    Access to resources image

    :param: imageName resource name picture

    :returns: Return to obtain images of the object
    */
    class func GET_RESOURCES_IMAGE(_ imageName:String, typeName:String) -> UIImage {
        let imagePath:String = Bundle.main.path(forResource: imageName, ofType: typeName)!
        return UIImage(contentsOfFile: imagePath)!

    }

    /**
     Determine whether the iPhone5s
    :returns: If it returns true or false
    */
    class func GET_IS_iPhone5S() -> Bool {
        let isiPhone5S:Bool = (UIScreen.instancesRespond(to: #selector(getter: RunLoop.currentMode)) ? CGSize(width: 640, height: 1136).equalTo(UIScreen.main.currentMode!.size) : false)
        return isiPhone5S
    }

    /**
     Determine whether the iPhone4s
     :returns: If it returns true or false
     */
    class func GET_IS_iPhone4S() -> Bool {
        let isiPhone4S:Bool = (UIScreen.instancesRespond(to: #selector(getter: RunLoop.currentMode)) ? CGSize(width: 640, height: 960).equalTo(UIScreen.main.currentMode!.size) : false)
        return isiPhone4S
    }


    /**
    Local notifications

    :param: string Inform the content
    */
    class func LocalNotificationBody(_ string:NSString, delay:Double=0) -> UILocalNotification {
        if (UIDevice.current.systemVersion as NSString).floatValue >= 8.0 {
            let categorys:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            categorys.identifier = "alert";
            //UIUserNotificationType.Badge|UIUserNotificationType.Sound|UIUserNotificationType.Alert
            let localUns:UIUserNotificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.badge,UIUserNotificationType.sound,UIUserNotificationType.alert], categories: Set(arrayLiteral: categorys))
            UIApplication.shared.registerUserNotificationSettings(localUns)
        }

        
        let notification:UILocalNotification=UILocalNotification()
        notification.timeZone = TimeZone.current
        notification.fireDate = Date().addingTimeInterval(delay)
        notification.alertBody=string as String;
        notification.applicationIconBadgeNumber = 0;
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.category = "invite"
        UIApplication.shared.scheduleLocalNotification(notification)
        return notification
    }

    class func CUSTOMBAR_BACKGROUND_COLOR() ->UIColor {
        return UIColor(red: 48/255.0, green: 48/255.0, blue: 48/255.0, alpha: 1)
    }

    class func KeyedArchiverName(_ name:String,andObject object:Any) -> Bool{
        let pathArray = NSSearchPathForDirectoriesInDomains(.libraryDirectory,.userDomainMask,true)
        let rootPath = pathArray[0].appending("/Caches/med_cache/")
        let filePath = rootPath.appending("\(name).data")
        if !FileManager.default.fileExists(atPath: rootPath) {
            do {
                try FileManager.default.createDirectory(atPath: rootPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Archiver error:\(error)")
            }
        }
        return NSKeyedArchiver.archiveRootObject(object, toFile: filePath)
    }

    /**
     * 解档的数据是原始对象, 要获得原始数据需要自行转换
     */
    class func LoadKeyedArchiverName(_ name:String) -> Any?{
        
        let pathArray = NSSearchPathForDirectoriesInDomains(.libraryDirectory,.userDomainMask,true)
        let path = pathArray[0]
        let filename = path.appending("/Caches/med_cache/\(name).data")
        if FileManager.default.fileExists(atPath: filename) {
            let objectArr = NSKeyedUnarchiver.unarchiveObject(withFile: filename)
            return objectArr
        }
        
        return nil
    }

    /**
    Access to the local version number

    :returns: <#return value description#>
    */
    class func getLoclAppStoreVersion()->String{
        let loclString:String = (Bundle.main.infoDictionary! as NSDictionary).object(forKey: "CFBundleShortVersionString") as! String
        return loclString
    }

    /**
    Go to AppStore updating links
    */
    class func toOpenUpdateURL() {
        UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/app/nevo-watch/id977526892?mt=8")!)
    }


    /**
    Play the prompt
    */
    class func playSound(){
        let shake_sound_male_id:SystemSoundID  = UInt32(1005);//系统声音的id 取值范围为：1000-2000
        AudioServicesPlaySystemSound(shake_sound_male_id)
        //let path:String = NSBundle.mainBundle().pathForResource("shake_sound_male", ofType: "wav")!
        //if path.isEmpty {
            //注册声音到系统
            //AudioServicesCreateSystemSoundID((NSURL.fileURLWithPath(path) as! CFURLRef),shake_sound_male_id);
            //AudioServicesPlaySystemSound(shake_sound_male_id);
        //}
        //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //手机震动
    }

    /**
    Put the object into a json string

    :param: object 转换对象

    :returns: 返回转换后的json字符串
    */
    class func toJSONString(_ object:AnyObject!)->NSString{

        do{
            let data = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
            var strJson=NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            strJson = strJson?.replacingOccurrences(of: "\n", with: "") as NSString?
            strJson = strJson?.replacingOccurrences(of: " ", with: "") as NSString?
            return strJson!
        }catch{
            return ""
        }
    }

    /**
    Json string into an array

    :param: object 转换对象

    :returns: 返回转换后的数组
    */
    class func jsonToArray(_ object:String)->NSArray{
        do{
            let data:Data = object.data(using: String.Encoding.utf8)!
            let array = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let JsonToArray = array as! NSArray
            return JsonToArray
        }catch{
            return NSArray()
        }
    }

    class func navigationbar(_ navigation:UINavigationController, reset:Bool) {
        
        if(navigation.navigationBar.responds(to: #selector(UINavigationBar.setBackgroundImage(_:for:barMetrics:)))){
            let list:NSArray = navigation.navigationBar.subviews as NSArray
            for obj in list{
                if((obj as AnyObject).isKind(of: UIImageView.classForCoder())){
                    let imageView:UIImageView = obj as! UIImageView
                    imageView.isHidden = true
                    if reset {
                        imageView.removeFromSuperview()
                    }
                }
            }
            if !reset {
                navigation.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                navigation.navigationBar.shadowImage = UIImage()
                let imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: -20, width: 420, height: 64))
                imageView.backgroundColor = UIColor.getBarColor()
                navigation.navigationBar.addSubview(imageView)
                navigation.navigationBar.sendSubview(toBack: imageView)
            }
        }
    }

    /**
     Get the FW build-in version by parse the file name
     BLE file: imaze_20150512_v29.hex ,keyword:_v, .hex
     return: 29
     */
    class func GET_FIRMWARE_VERSION() ->Int
    {
        var buildinFirmwareVersion:Int  = 0
        let fileArray:NSArray = GET_FIRMWARE_FILES("Firmwares")
        
        for tmpfile in fileArray {
            let selectedFile:URL = tmpfile as! URL
            let fileName:NSString? = (selectedFile.path as NSString).lastPathComponent as NSString?
            let fileExtension:String? = selectedFile.pathExtension

            if fileExtension == "hex" {
                let ran:NSRange = fileName!.range(of: "_v")
                let ran2:NSRange = fileName!.range(of: ".hex")
                let string:String = fileName!.substring(with: NSRange(location: ran.location + ran.length,length: ran2.location-ran.location-ran.length))
                buildinFirmwareVersion = Int(string)!
                break
            }
            
        }

        return buildinFirmwareVersion
    }
    /**
     Get the FW build-in version by parse the file name
     MCU file: iMaze_v12.bin ,keyword:_v, .bin
     return: 12
     */
    class func GET_SOFTWARE_VERSION() ->Int {
        var buildinSoftwareVersion:Int  = 0
        let fileArray = GET_FIRMWARE_FILES("Firmwares")
        for tmpfile in fileArray {
            let selectedFile = tmpfile as! URL
            let fileName:NSString? = (selectedFile.path as NSString).lastPathComponent as NSString?
            let fileExtension:String? = selectedFile.pathExtension

            if fileExtension == "bin" {
                let ran:NSRange = fileName!.range(of: "_v")
                let ran2:NSRange = fileName!.range(of: ".bin")
                let string:String = fileName!.substring(with: NSRange(location: ran.location + ran.length,length: ran2.location-ran.location-ran.length))
                buildinSoftwareVersion = Int(string)!
                break
            }
        }

        return buildinSoftwareVersion
    }
    /**
     Get or get the resource path of the array

     :param: folderName Resource folder name

     :returns: Return path array
     */
    class func GET_FIRMWARE_FILES(_ folderName:String) -> NSArray {

        let AllFilesNames:NSMutableArray = NSMutableArray()
        let appPath:NSString  = Bundle.main.resourcePath! as NSString
        let firmwaresDirectoryPath:NSString = appPath.appendingPathComponent(folderName) as NSString

        var  fileNames:[String] = []
        do {
            fileNames = try FileManager.default.contentsOfDirectory(atPath: firmwaresDirectoryPath as String)
            XCGLogger.default.debug("number of files in directory \(fileNames.count)");
            for fileName in fileNames {
                XCGLogger.default.debug("Found file in directory: \(fileName)");
                let filePath:String = firmwaresDirectoryPath.appendingPathComponent(fileName)
                let fileURL:URL = URL(fileURLWithPath: filePath)
                AllFilesNames.add(fileURL)
            }
            return AllFilesNames.copy() as! NSArray
        }catch{
            XCGLogger.default.debug("error in opening directory path: \(firmwaresDirectoryPath)");
            return NSArray()
        }
    }

    class func on_ios_simulator(_ fun: () -> Void){
        #if (arch(x86_64) || arch(i386)) && os(iOS)
            
        #else
            fun()
        #endif
    }

    class func getWakeSleepColor () -> UIColor{
        return UIColor(red: 253/255.0, green: 230/255.0, blue: 156.0/255.0, alpha: 1.0)
    }
    
    class func getLightSleepColor () -> UIColor{
        return UIColor(red: 251.0/255.0, green: 193.0/255.0, blue: 11.0/255.0, alpha: 1.0)
    }
    
    class func getDeepSleepColor () -> UIColor{
        return UIColor(red: 249.0/255.0, green: 160.0/255.0, blue: 1.0/255.0, alpha: 1.0)
    }
    
    class func getStepsColor () -> UIColor{
        return UIColor(red: 179.0/255.0, green: 179.0/255.0, blue: 179.0/255.0, alpha: 1.0)
    }
    
    class func isEmail(_ email:String)->Bool{
        return !email.isMatched(byRegex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
    }
    
    class func isPassword(_ password:String)->Bool{
        return password.isMatched(byRegex: "^[a-zA-Z]w{5,17}$")
    }
    
    class func isNull(_ object:String)->Bool{
        return object.isEmpty
    }
    
    /// - returns: LunaR -> false, Nevo -> true
    class func isTargetLunaR_OR_Nevo()->Bool {
        let infoDictionary:[String : AnyObject] = Bundle.main.infoDictionary! as [String : AnyObject]
        let app_Name:String = infoDictionary["CFBundleName"] as! String
        if app_Name == "LunaR" {
            return false
        }else{
            return true
        }
    }
    
    class func timerFormatValue(value:Double)->String {
        let hours:Int = Int(value).hours.value
        let minutes:Int = Int((value-Double(hours))*60).minutes.value
        if hours == 0 {
            return String(format:"%d m",minutes)
        }
        return String(format:"%d h %d m",hours,minutes)
    }
    
    //return 0->Metrics,1->imperial,default value = 0
    class func getUserSelectedUnitValue()->Int {
        if let row = MEDSettings.int(forKey: "UserSelectedUnit") {
            return row
        }else{
            return 0
        }
    }
    
    class func realmISFirstCopy(findKey:ActionType)->Bool {
        if findKey == .get {
            if let value = UserDefaults.standard.object(forKey: "ISFirstCopy") {
                let index:Bool = value as! Bool
                return index
            }else{
                return false
            }
        }
        
        if findKey == .set {
            UserDefaults.standard.set(true, forKey: "ISFirstCopy")
            return true
        }
        return false
    }
    
    static func openBluetoothSystem() {
        let url:URL = URL(string: "App-Prefs:root=Bluetooth")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: Dictionary(), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
