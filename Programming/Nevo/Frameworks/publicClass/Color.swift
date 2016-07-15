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
        return UIColor(rgba: "#7ED8D1")
        
    }
    
    public class func getTintColor() -> UIColor {
        return UIColor(rgba: "#5D447A");
    }
    
    public class func getGreyColor() -> UIColor {
        return UIColor(rgba: "#54575a");
    }
    
    public class func getLightBaseColor() -> UIColor {
        return UIColor(rgba: "#3A3739")
    }

    public class func transparent() -> UIColor {
        return UIColor(red: 0/255.0 , green: 0/255.0, blue: 0/255.0, alpha: 0.0)
    }

}