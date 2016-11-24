//
//  Color.swift
//  Drone
//
//  Created by Karl Chow on 4/27/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIColor_Hex_Swift

extension UIColor{
    
    public class func getBaseColor() -> UIColor {
        if !AppTheme.isTargetLunaR_OR_Nevo(){
            return UIColor(rgba: "#7ED8D1")
        }else{
            return UIColor(rgba: "#A08455")
        }
        
    }
    
    public class func getTintColor() -> UIColor {
        return UIColor(rgba: "#B37EBD");
    }
    
    public class func getGreyColor() -> UIColor {
        return UIColor(rgba: "#54575a");
    }
    
    public class func getLightBaseColor() -> UIColor {
        return UIColor(rgba: "#3A3739")
    }
    
    public class func getWhiteBaseColor() -> UIColor {
        return UIColor(rgba: "#C7C7CC")
    }

    public class func getNevoBaseColor() -> UIColor {
        return UIColor(rgba: "#A08455")
    }
    
    public class func getCalendarColor() -> UIColor {
        return UIColor(rgba: "#E5E4E2")
    }
    
    public class func getBarColor() -> UIColor {
        return UIColor(rgba: "#EFEFEF")
    }
    
    public class func transparent() -> UIColor {
        return UIColor(red: 0/255.0 , green: 0/255.0, blue: 0/255.0, alpha: 0.0)
    }

    public class func getLunarTabBarColor() -> UIColor {
        return UIColor(red: 96/255.0, green: 99/255.0, blue: 101/255.0, alpha: 1.0)
    }
    
    public class func getNevoTabBarColor() -> UIColor {
        return UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0)
    }
}
