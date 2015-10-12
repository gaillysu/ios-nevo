//
//  AppTheme.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 18/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import AudioToolbox

/**
This class holds all app-wide constants.
Colors, fonts etc...
*/
class AppTheme {

    #if DEBUG
    class func DLog(message: String, filename: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        NSLog("[\((filename as NSString).lastPathComponent):\(line)] \(function) - \(message)")
    }
    #else
    class func DLog(message: String, filename: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
    }
    #endif
    /**
    This color should be used app wide on all actionable elements
    sRGB value : #ff9933
    */
    class func NEVO_SOLAR_YELLOW() -> UIColor {
        return UIColor(red: 255/255.0, green: 153/255.0, blue: 51/255.0, alpha: 1)
    }

    class func NEVO_SOLAR_GRAY() -> UIColor {
        return UIColor(red: 186/255.0, green: 185/255.0, blue: 182/255.0, alpha: 1)
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

    class func SYSTEMFONTOFSIZE(mSize size:CGFloat = 25) -> UIFont {
        return UIFont.systemFontOfSize(size)
    }
    class func FONT_RALEWAY_BOLD(mSize size:CGFloat = 26) -> UIFont {
        return UIFont(name:"Raleway-Bold", size: size)!
    }

    class func FONT_RALEWAY_LIGHT(mSize size:CGFloat = 26) -> UIFont {
        return UIFont(name:"Raleway-Light", size: size)!
    }

    class func FONT_RALEWAY_THIN(mSize size:CGFloat = 26) -> UIFont {
        return UIFont(name:"Raleway-Thin", size: size)!//Uniform
    }

    class func PALETTE_BAGGROUND_COLOR() -> UIColor {
        return UIColor(red: 10/255.0, green: 255/255.0, blue: 178/255.0, alpha: 1)//Uniform
    }

    /**
    Access to resources image

    :param: imageName resource name picture

    :returns: Return to obtain images of the object
    */
    class func GET_RESOURCES_IMAGE(imageName:String) -> UIImage {
        let imagePath:String = NSBundle.mainBundle().pathForResource(imageName, ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!

    }

    /**
     Determine whether the iPhone4s
    :returns: If it returns true or false
    */
    class func GET_IS_iPhone4S() -> Bool {
        let isiPhone4S:Bool = (UIScreen.instancesRespondToSelector(Selector("currentMode")) ? CGSizeEqualToSize(CGSizeMake(640, 960), UIScreen.mainScreen().currentMode!.size) : false)
        return isiPhone4S
    }


    /**
    Local notifications

    :param: string Inform the content
    */
    class func LocalNotificationBody(string:NSString, delay:Double=0) -> UILocalNotification {
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            let categorys:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            categorys.identifier = "alert";
            //UIUserNotificationType.Badge|UIUserNotificationType.Sound|UIUserNotificationType.Alert
            let localUns:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge,UIUserNotificationType.Sound,UIUserNotificationType.Alert], categories: Set(arrayLiteral: categorys))
            UIApplication.sharedApplication().registerUserNotificationSettings(localUns)
        }

        
        let notification:UILocalNotification=UILocalNotification()
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.fireDate = NSDate().dateByAddingTimeInterval(delay)
        notification.alertBody=string as String;
        notification.applicationIconBadgeNumber = 0;
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.category = "invite"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        return notification
    }

    class func CUSTOMBAR_BACKGROUND_COLOR() ->UIColor {
        return UIColor(red: 48/255.0, green: 48/255.0, blue: 48/255.0, alpha: 1)
    }

    /**
    *	@brief	The archive All current data
    *
    */
    class func KeyedArchiverName(name:NSString,andObject object:AnyObject) ->Bool{
        var objectArray:[AnyObject] = [object.copy()]
        let senddate:NSDate = NSDate()
        let dateformatter:NSDateFormatter = NSDateFormatter()

        dateformatter.dateFormat = "YYYY/MM/dd"// HH:mm:ss
        let locationString:NSString = dateformatter.stringFromDate(senddate)
        objectArray.append(locationString)
        NSLog("locationString:%@",locationString);

        let pathArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)
        let Path:NSString = (pathArray as NSArray).objectAtIndex(0) as! NSString

        let filename:NSString = Path.stringByAppendingPathComponent(name as String)
        let iswrite:Bool = NSKeyedArchiver.archiveRootObject(objectArray, toFile: filename as String)
        return iswrite
    }

    /**
    *	@brief	Load the archived data
    *
    */
    class func LoadKeyedArchiverName(name:NSString) ->AnyObject{
        let pathArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)
        let Path:NSString = (pathArray as NSArray).objectAtIndex(0) as! NSString

        let filename:NSString = Path.stringByAppendingPathComponent(name as String)

        let flierManager:Bool = NSFileManager.defaultManager().fileExistsAtPath(filename as String)
        if(flierManager){
            var objectArr:AnyObject?
            objectArr = NSKeyedUnarchiver.unarchiveObjectWithFile(filename as String)!
            return objectArr!
        }
        return []
    }

    /**
    Calculate the height of the Label to display text

    :param: string Need to display the source text
    :param: object The control position and size the source object

    :returns: Returns the modified position and size of the source object
    */
    class func getLabelSize(string:String , andObject object:CGRect, andFont font:UIFont) ->CGRect{
        var frame:CGRect = object
        let loclString:NSString = string as NSString
        //NSStringDrawingOptions.UsesLineFragmentOrigin|NSStringDrawingOptions.UsesFontLeading,
        var labelSize:CGSize = loclString.boundingRectWithSize(CGSizeMake(frame.size.width, 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
        labelSize.height = ceil(labelSize.height);
        labelSize.width = ceil(labelSize.width);

        var messageframe:CGRect  = frame;
        messageframe.size.height = labelSize.height;
        frame = messageframe;
        return frame
    }
    
    class func getWidthLabelSize(string:String , andObject object:CGRect, andFont font:UIFont) ->CGRect{
        var frame:CGRect = object
        let loclString:NSString = string as NSString
        //NSStringDrawingOptions.UsesLineFragmentOrigin|NSStringDrawingOptions.UsesFontLeading
        var labelSize:CGSize = loclString.boundingRectWithSize(CGSizeMake(1000, frame.size.height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
        labelSize.height = ceil(labelSize.height);
        labelSize.width = ceil(labelSize.width);
        
        var messageframe:CGRect  = frame;
        messageframe.size.width = labelSize.width;
        frame = messageframe;
        return frame
    }

    /**
    Phone the current language

    :returns: Language
    */
    class func getPreferredLanguage()->NSString{

        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

        let allLanguages:NSArray = defaults.objectForKey("AppleLanguages") as! NSArray

        let preferredLang:NSString = allLanguages.objectAtIndex(0) as! NSString
        return preferredLang;
    
    }

    /**
    To obtain the version number on AppStore

    :param: resulVersion It contains a string version and a Double type version
    */
    class func getAppStoreVersion(resulVersion:((stringVersion:NSString?,version:Double?) -> Void)){
        let url:NSString = NSString(string: "https://itunes.apple.com/lookup?id=977526892")
        let manager:AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        manager.requestSerializer.timeoutInterval = 30;
        manager.GET((url as String), parameters:nil, success: { (operation,responseObject) -> Void in
            let arr: NSDictionary! = responseObject as! NSDictionary
            let versionString: NSString = ((arr.objectForKey("results") as! NSArray).objectAtIndex(0) as! NSDictionary).objectForKey("version") as! NSString
            let string:NSString = versionString.stringByReplacingOccurrencesOfString(".", withString: "")
            let version:Float = string.floatValue
            resulVersion(stringVersion: versionString,version:Double(version))
            }) { (operation,error) -> Void in
                resulVersion(stringVersion:"",version:0.0)
        }
    }

    /**
    Access to the local version number

    :returns: <#return value description#>
    */
    class func getLoclAppStoreVersion()->String{
        let loclString:String = (NSBundle.mainBundle().infoDictionary! as NSDictionary).objectForKey("CFBundleShortVersionString") as! String
        return loclString
    }

    /**
    Go to AppStore updating links
    */
    class func toOpenUpdateURL() {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/app/nevo-watch/id977526892?mt=8")!)
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
    class func toJSONString(object:AnyObject!)->NSString{

        do{
            let data = try NSJSONSerialization.dataWithJSONObject(object, options: NSJSONWritingOptions.PrettyPrinted)
            var strJson=NSString(data: data, encoding: NSUTF8StringEncoding)
            strJson = strJson?.stringByReplacingOccurrencesOfString("\n", withString: "")
            strJson = strJson?.stringByReplacingOccurrencesOfString(" ", withString: "")
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
    class func jsonToArray(object:String)->NSArray{
        do{
            let data:NSData = object.dataUsingEncoding(NSUTF8StringEncoding)!
            let array:AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            let JsonToArray = array as! NSArray
            return JsonToArray
        }catch{
            return NSArray()
        }
    }

    /**
    *Hexadecimal color string into UIColor (HTML color values)
    */
    class func hexStringToColor(stringToConvert:String)->UIColor{
        var cString:NSString = stringToConvert.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        if (cString.length < 6){ return UIColor.blackColor()}
        // strip 0X if it appears
        if (cString.hasPrefix("0X")){ cString = cString.substringFromIndex(2)}
        if (cString.hasPrefix("#")){ cString = cString.substringFromIndex(1)}
        if (cString.length != 6){ return UIColor.blackColor()}
        // Separate into r, g, b substrings

        var range:NSRange = NSRange()
        range.location = 0;
        range.length = 2;
        let rString:NSString = cString.substringWithRange(range)
        range.location = 2;
        let gString:NSString = cString.substringWithRange(range)
        range.location = 4;
        let bString:NSString  = cString.substringWithRange(range)
        // Scan values
        var r:UInt32 = 0
        var g:UInt32 = 0
        var b:UInt32 = 0
        NSScanner(string: rString as String).scanHexInt(&r)
        NSScanner(string: gString as String).scanHexInt(&g)
        NSScanner(string: bString as String).scanHexInt(&b)
        return UIColor(red: CGFloat(r)/255.0, green:  CGFloat(g)/255.0, blue:  CGFloat(b)/255.0, alpha: 1)
    }
}