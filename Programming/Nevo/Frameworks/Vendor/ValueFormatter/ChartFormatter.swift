//
//  ChartFormatter.swift
//  Nevo
//
//  Created by Cloud on 2017/1/5.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit
import Charts

class ChartFormatter: NSObject, IValueFormatter, IAxisValueFormatter {
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String{
        return "\(Int(value)):00"
    }
    
    public func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String{
    
        return ""
    }
}
