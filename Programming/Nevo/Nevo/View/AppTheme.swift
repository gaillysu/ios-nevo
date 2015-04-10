//
//  AppTheme.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 18/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

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
            var categorys:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            categorys.identifier = "alert";
            var localUns:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge|UIUserNotificationType.Sound|UIUserNotificationType.Alert, categories: NSSet(objects: categorys) as Set<NSObject>)
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

}