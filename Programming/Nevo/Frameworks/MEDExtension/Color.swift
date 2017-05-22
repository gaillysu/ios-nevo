//
//  Color.swift
//  Drone
//
//  Created by Karl Chow on 4/27/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIColor_Hex_Swift

extension UIColor {
    
    open class var nevoGray:UIColor {
        return UIColor("#BCBCBC")
    }
    
    open class var darkRed:UIColor {
        return UIColor("#C60000")
    }
    
    open class var darkGreen:UIColor {
        return UIColor("#00B000")
    }
    
    open class var transparent:UIColor {
        return UIColor(red: 0/255.0 , green: 0/255.0, blue: 0/255.0, alpha: 0.0)
    }
    
    open class var baseColor:UIColor {
        return UIColor("#A08455")
    }
    
    open class var PALETTE_BAGGROUND_COLOR:UIColor {
        return UIColor(red: 10/255.0, green: 255/255.0, blue: 178/255.0, alpha: 1)
    }
    
    open class var getRandomColor:UIColor {
        let r = CGFloat(arc4random_uniform(150) + 50)
        let g = CGFloat(arc4random_uniform(150) + 50)
        let b = CGFloat(arc4random_uniform(150) + 50)
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
    }
    
    open class func getNevoTabBarColor() -> UIColor {
        return UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0)
    }
    
    open class func getBarSeparatorColor() -> UIColor {
        return UIColor("#FFFAFA")
    }
    
    open class func NEVO_CUSTOM_COLOR(Red reds:CGFloat = 186, Green greens:CGFloat = 185, Blue blue:CGFloat = 182) -> UIColor {
        return UIColor(red: reds/255.0 , green: greens/255.0, blue: blue/255.0, alpha: 1)
    }
    
    
    
    open class func getTintColor() -> UIColor {
        return UIColor("#B37EBD");
    }
    
    open class func getGreyColor() -> UIColor {
        return UIColor("#54575a");
    }
    
    open class func getLightBaseColor() -> UIColor {
        return UIColor("#3A3739")
    }
    
    open class func getCalendarColor() -> UIColor {
        return UIColor("#E5E4E2")
    }
    
    open class func getBarColor() -> UIColor {
        return UIColor("#EFEFEF")
    }
    
    open class func getWakeSleepColor () -> UIColor{
        return UIColor(red: 253/255.0, green: 230/255.0, blue: 156.0/255.0, alpha: 1.0)
    }
    
    open class func getLightSleepColor () -> UIColor{
        return UIColor(red: 251.0/255.0, green: 193.0/255.0, blue: 11.0/255.0, alpha: 1.0)
    }
    
    open class func getDeepSleepColor () -> UIColor{
        return UIColor(red: 249.0/255.0, green: 160.0/255.0, blue: 1.0/255.0, alpha: 1.0)
    }
    
    open class func getStepsColor () -> UIColor{
        return UIColor(red: 179.0/255.0, green: 179.0/255.0, blue: 179.0/255.0, alpha: 1.0)
    }
}
