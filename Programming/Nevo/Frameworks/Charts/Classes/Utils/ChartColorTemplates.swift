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

    public class func getWakeSleepColor () -> UIColor{
        return UIColor(red: 253/255.0, green: 230/255.0, blue: 156.0/255.0, alpha: 1.0)
    }

    public class func getLightSleepColor () -> UIColor{
        return UIColor(red: 251.0/255.0, green: 193.0/255.0, blue: 11.0/255.0, alpha: 1.0)
    }
    
    public class func getDeepSleepColor () -> UIColor{
        return UIColor(red: 249.0/255.0, green: 160.0/255.0, blue: 1.0/255.0, alpha: 1.0)
    }

    public class func getStepsColor () -> UIColor{
        return UIColor(red: 179.0/255.0, green: 179.0/255.0, blue: 179.0/255.0, alpha: 1.0)
    }

}