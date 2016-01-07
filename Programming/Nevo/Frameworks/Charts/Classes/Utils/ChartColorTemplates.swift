//
//  ChartColorTemplates.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit

public class ChartColorTemplates: NSObject
{
    
    public class func getLightSleepColor () -> UIColor{
        return UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0)
    }
    
    public class func getDeepSleepColor () -> UIColor{
        return UIColor(red: 252/255.0, green: 182/255.0, blue: 0/255.0, alpha: 1.0)
    }

    public class func getStepsColor () -> UIColor{
        return UIColor(red: 179.0/255.0, green: 179.0/255.0, blue: 179.0/255.0, alpha: 1.0)
    }

}