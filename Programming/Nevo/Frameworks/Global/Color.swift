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
            return UIColor("#7ED8D1")
        }else{
            return UIColor("#A08455")
        }
        
    }
    
    public class func getTintColor() -> UIColor {
        return UIColor("#B37EBD");
    }
    
    public class func getGreyColor() -> UIColor {
        return UIColor("#54575a");
    }
    
    public class func getLightBaseColor() -> UIColor {
        return UIColor("#3A3739")
    }
    
    public class func getWhiteBaseColor() -> UIColor {
        return UIColor("#C7C7CC")
    }

    public class func getNevoBaseColor() -> UIColor {
        return UIColor("#A08455")
    }
    
    public class func getCalendarColor() -> UIColor {
        return UIColor("#E5E4E2")
    }
    
    public class func getBarColor() -> UIColor {
        return UIColor("#EFEFEF")
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
    
    public class func getRandomColor() -> UIColor {
        let r = CGFloat(arc4random_uniform(150) + 50)
        let g = CGFloat(arc4random_uniform(150) + 50)
        let b = CGFloat(arc4random_uniform(150) + 50)
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
    }
}
