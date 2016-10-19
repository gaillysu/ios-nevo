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
        return UIColor(rgba: "#A08455")
    }

    class func NEVO_SOLAR_GRAY() -> UIColor {
        
        return UIColor(rgba: "#E5E4E2")
    }
    
    class func NEVO_SOLAR_DARK_GRAY() -> UIColor {
        
        return UIColor(rgba: "#BCBCBC")
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
    class func GET_RESOURCES_IMAGE(_ imageName:String) -> UIImage {
        let imagePath:String = Bundle.main.path(forResource: imageName, ofType: "png")!
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

    /**
    *	@brief	The archive All current data
    *
    */
    class func KeyedArchiverName(_ name:NSString,andObject object:AnyObject) ->Bool{
        var objectArray:[AnyObject] = [object]
        let senddate:Date = Date()
        let dateformatter:DateFormatter = DateFormatter()

        dateformatter.dateFormat = "YYYY/MM/dd"// HH:mm:ss
        let locationString:NSString = dateformatter.string(from: senddate) as NSString
        objectArray.append(locationString)
        NSLog("locationString:%@",locationString);

        let pathArray = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)
        let Path:NSString = (pathArray as NSArray).object(at: 0) as! NSString

        let filename:NSString = Path.appendingPathComponent(name as String) as NSString
        let iswrite:Bool = NSKeyedArchiver.archiveRootObject(objectArray, toFile: filename as String)
        return iswrite
    }

    /**
     解档的数据是包含时间戳的数据数组,要获得原始数据需要自行转换,归档的数据类型都是以弱类型归档解档可自行转换
     index 1 = time stamp  index 0 = data

     :param: name Archiver Name

     :returns: Archiver data
     */
    class func LoadKeyedArchiverName(_ name:NSString) ->AnyObject{
        let pathArray = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)
        let Path:NSString = (pathArray as NSArray).object(at: 0) as! NSString

        let filename:NSString = Path.appendingPathComponent(name as String) as NSString

        let flierManager:Bool = FileManager.default.fileExists(atPath: filename as String)
        if(flierManager){
            let objectArr = NSKeyedUnarchiver.unarchiveObject(withFile: filename as String)!
            return objectArr as AnyObject
        }
        return [] as AnyObject
    }

    /**
    Calculate the height of the Label to display text

    :param: string Need to display the source text
    :param: object The control position and size the source object

    :returns: Returns the modified position and size of the source object
    */
    class func getLabelSize(_ string:String , andObject object:CGRect, andFont font:UIFont) ->CGRect{
        var frame:CGRect = object
        let loclString:NSString = string as NSString
        //NSStringDrawingOptions.UsesLineFragmentOrigin|NSStringDrawingOptions.UsesFontLeading,
        var labelSize:CGSize = loclString.boundingRect(with: CGSize(width: frame.size.width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
        labelSize.height = ceil(labelSize.height);
        labelSize.width = ceil(labelSize.width);

        var messageframe:CGRect  = frame;
        messageframe.size.height = labelSize.height;
        frame = messageframe;
        return frame
    }
    
    class func getWidthLabelSize(_ string:String , andObject object:CGRect, andFont font:UIFont) ->CGRect{
        let frame:CGRect = object
        let loclString:NSString = string as NSString
        //NSStringDrawingOptions.UsesLineFragmentOrigin|NSStringDrawingOptions.UsesFontLeading
        var labelSize:CGSize = loclString.boundingRect(with: CGSize(width: 1000, height: frame.size.height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
        labelSize.height = ceil(labelSize.height);
        labelSize.width = ceil(labelSize.width);
        
        var messageframe:CGRect  = object;
        messageframe.size.width = labelSize.width;
        return messageframe
    }

    /**
    Phone the current language

    :returns: Language
    */
    class func getPreferredLanguage()->NSString{

        let defaults:UserDefaults = UserDefaults.standard

        let allLanguages:NSArray = defaults.object(forKey: "AppleLanguages") as! NSArray

        let preferredLang:NSString = allLanguages.object(at: 0) as! NSString
        return preferredLang;
    
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

    class func navigationbar(_ navigation:UINavigationController) {
        
        if(navigation.navigationBar.responds(to: #selector(UINavigationBar.setBackgroundImage(_:for:barMetrics:)))){
            let list:NSArray = navigation.navigationBar.subviews as NSArray
            for obj in list{
                if((obj as AnyObject).isKind(of: UIImageView.classForCoder())){
                    let imageView:UIImageView = obj as! UIImageView
                    imageView.isHidden = true
                }
            }
            navigation.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigation.navigationBar.shadowImage = UIImage()
            let imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: -20, width: 420, height: 64))
            imageView.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 247.0, Green: 247.0, Blue: 247.0)
            navigation.navigationBar.addSubview(imageView)
            navigation.navigationBar.sendSubview(toBack: imageView)
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
        let fileArray = GET_FIRMWARE_FILES("Firmwares")
        for tmpfile in fileArray {
            let selectedFile:URL = tmpfile as! URL
            let fileName:NSString? = (selectedFile.path as NSString).lastPathComponent as NSString?
            let fileExtension:String? = selectedFile.pathExtension

            if fileExtension == "hex"
            {
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
}
