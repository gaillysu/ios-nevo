//
//  AnalysisLineChartCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/9.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Charts
import Timepiece

class AnalysisLineChartCell: UICollectionViewCell,ChartViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    private var sortArray:NSMutableArray = NSMutableArray()
    
    private var xVals:[String] = []
    private var yVals:[ChartDataEntry] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initChartView()
    }

    private func initChartView() {
        lineChartView.delegate = self;
        
        lineChartView.descriptionText = "";
        lineChartView.noDataTextDescription = "You need to provide data for the chart.";
        
        lineChartView.dragEnabled = false;
        lineChartView.setScaleEnabled(false)
        lineChartView.pinchZoomEnabled = false;
        lineChartView.legend.enabled = false
        lineChartView.rightAxis.enabled = true
        lineChartView.drawGridBackgroundEnabled = false;
        
        lineChartView.rightAxis.enabled = false;
        
        let xAxis:ChartXAxis = lineChartView.xAxis
        xAxis.labelTextColor = UIColor.blackColor();
        xAxis.axisLineColor = AppTheme.NEVO_SOLAR_GRAY()
        xAxis.drawLimitLinesBehindDataEnabled = false;
        xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 7)!
        
        let marker:BalloonMarker = BalloonMarker(color: AppTheme.NEVO_SOLAR_YELLOW(), font: UIFont.systemFontOfSize(12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
        marker.minimumSize = CGSizeMake(80.0, 40.0);
        lineChartView.marker = marker;
        
        lineChartView.legend.form = ChartLegend.Form.Line
        lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInOutCirc)
    }
    
    func setTitle(title:String) {
        titleLabel.text = title
    }
    
    func setContentValue(title:String) {
        titleLabel.text = title
    }
    
    func updateChartData(dataArray:NSArray,chartType:Int,rowIndex:Int,completionData:((totalValue:Float,totalCalores:Int,totalTime:Int) -> Void)) {
        lineChartView.data = nil
        xVals = []
        yVals = []
        
        switch chartType {
        case 0:
            var totalSteps:Int = 0
            var totalCalores:Int = 0
            var totalTime:Int = 0
            for value in dataArray {
                let usersteps:UserSteps = value as! UserSteps
                totalSteps += usersteps.steps
                totalCalores += Int(usersteps.calories)
                totalTime += (usersteps.walking_duration+usersteps.running_duration)
            }
            completionData(totalValue: Float(totalSteps), totalCalores: totalCalores, totalTime: totalTime)
            self.setStepsDataCount(dataArray, type: chartType,rowIndex:rowIndex)
        case 1:
            var totalValue:Int = 0
            for value in dataArray {
                let usersteps:UserSleep = value as! UserSleep
                let sleepTime:[Int] = AppTheme.jsonToArray(usersteps.hourlySleepTime) as! [Int]
                for value2 in sleepTime {
                    totalValue+=value2
                }
            }
            completionData(totalValue: Float(totalValue)/60.0, totalCalores: 0, totalTime: 0)
            self.setSleepDataCount(dataArray, type: chartType,rowIndex:rowIndex)
        case 2:
            self.setSloarDataCount(dataArray, type: chartType,rowIndex:rowIndex)
        default: break
        }
    }
    
    func setStepsDataCount(countArray:NSArray,type:Int,rowIndex:Int) {
        sortArray.removeAllObjects()
        sortArray.addObjectsFromArray(countArray as [AnyObject])
        
        var maxValue:Int = 0
        for i:Int in 0 ..< countArray.count {
            /**
             *  Data sorting,Small to large sort
             */
            for j:Int in i ..< countArray.count {
                let iSteps:UserSteps = sortArray.objectAtIndex(i) as! UserSteps;
                let jSteps:UserSteps = sortArray.objectAtIndex(j) as! UserSteps;
                let iStepsDate:Double = iSteps.date
                let jStepsDate:Double = jSteps.date
                let iStepsValue:Int = iSteps.steps
                
                //Calculate the maximum
                if iStepsValue>maxValue {
                    maxValue = iStepsValue
                }
                //Time has sorted
                if (iStepsDate > jStepsDate){
                    let temp:UserSteps = sortArray.objectAtIndex(i) as! UserSteps;
                    sortArray.replaceObjectAtIndex(i, withObject: sortArray[j])
                    sortArray.replaceObjectAtIndex(j, withObject: temp)
                }
            }
            //chart the maximum
            if i == countArray.count-1 {
                self.setChartViewLeftAxis(Double(maxValue+500), unitString: "")
            }
        }
        
        if sortArray.count == 0 {
            self.setChartViewLeftAxis(Double(maxValue+500), unitString: "")
        }
        
        for i:Int in 0..<sortArray.count {
            let usersteps:UserSteps = sortArray[i] as! UserSteps
            let date:NSDate = "\(usersteps.createDate)".dateFromFormat("yyyyMMdd")!
            let dateString:String = date.stringFromFormat("dd/MM")
            let stepsArray = AppTheme.jsonToArray(usersteps.hourlysteps)
            var steps:Double = 0
            for value in stepsArray {
                steps += Double((value as! NSNumber).doubleValue)
            }
            yVals.append(ChartDataEntry(value: steps, xIndex: i))
            xVals.append(dateString)
        }
        
        self.setYvalueData(rowIndex,completionData: nil)
        
        let set1:LineChartDataSet = LineChartDataSet(yVals: yVals, label: "")
        set1.lineDashLengths = [0.0, 0];
        set1.highlightLineDashLengths = [0.0, 0.0];
        set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
        set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
        set1.valueTextColor = UIColor.blackColor()
        set1.lineWidth = 1.0;
        set1.circleRadius = 0.0;
        //set1?.drawCirclesEnabled = false;
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false;
        set1.valueFont = UIFont.systemFontOfSize(9.0)
        
        let gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_GRAY().CGColor,AppTheme.NEVO_SOLAR_YELLOW().CGColor];
        let gradient:CGGradientRef = CGGradientCreateWithColors(nil, gradientColors, nil)!
        set1.fillAlpha = 1;
        set1.fill = ChartFill.fillWithLinearGradient(gradient, angle: 80.0)
        set1.drawFilledEnabled = true
        set1.mode = LineChartDataSet.Mode.CubicBezier
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: [set1])
        data.setDrawValues(false)
        lineChartView.data = data;
        //lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInOutCirc)
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
    }

    func setSleepDataCount(countArray:NSArray,type:Int,rowIndex:Int) {
        sortArray.removeAllObjects()
        sortArray.addObjectsFromArray(countArray as [AnyObject])
        var weakeYVals:[ChartDataEntry] = []
        var lightYVals:[ChartDataEntry] = []
        var deepYVals:[ChartDataEntry] = []
        
        var maxValue:Int = 0
        for i:Int in 0 ..< countArray.count {
            /**
             *  Data sorting,Small to large sort
             */
            for j:Int in i ..< countArray.count {
                let iSleeps:UserSleep = sortArray.objectAtIndex(i) as! UserSleep;
                let jSleep:UserSleep = sortArray.objectAtIndex(j) as! UserSleep;
                let iSleepDate:Double = iSleeps.date
                let jSleepDate:Double = jSleep.date
                //Time has sorted
                if (iSleepDate > jSleepDate){
                    let temp:UserSleep = sortArray.objectAtIndex(i) as! UserSleep;
                    sortArray.replaceObjectAtIndex(i, withObject: sortArray[j])
                    sortArray.replaceObjectAtIndex(j, withObject: temp)
                }
            }
        }
        
        for (index,sleeps) in sortArray.enumerate() {
            
            var sleepValue:Int = 0
            var weakeValue:Int = 0
            var lightValue:Int = 0
            var deepValue:Int = 0
            
            let mSleeps:UserSleep = sleeps as! UserSleep
            let sleepsValue1:[Int] = AppTheme.jsonToArray(mSleeps.hourlySleepTime) as! [Int]
            let sleepsValue2:[Int] = AppTheme.jsonToArray(mSleeps.hourlyWakeTime) as! [Int]
            let sleepsValue3:[Int] = AppTheme.jsonToArray(mSleeps.hourlyLightTime) as! [Int]
            let sleepsValue4:[Int] = AppTheme.jsonToArray(mSleeps.hourlyDeepTime) as! [Int]
            
            let date:NSDate = NSDate(timeIntervalSince1970: mSleeps.date)
            let dateString:String = date.stringFromFormat("dd/MM")
            
            if index>0 {
                let kSleeps:UserSleep = sortArray[index-1] as! UserSleep
                let value1:[Int] = AppTheme.jsonToArray(kSleeps.hourlySleepTime) as! [Int]
                let value2:[Int] = AppTheme.jsonToArray(kSleeps.hourlyWakeTime) as! [Int]
                let value3:[Int] = AppTheme.jsonToArray(kSleeps.hourlyLightTime) as! [Int]
                let value4:[Int] = AppTheme.jsonToArray(kSleeps.hourlyDeepTime) as! [Int]
                
                for (index2,value) in value1.enumerate() {
                    if index2>18 {
                        sleepValue += value
                        weakeValue += value2[index2]
                        lightValue += value3[index2]
                        deepValue += value4[index2]
                    }
                }
            }
            
            for (index2,value) in sleepsValue1.enumerate() {
                if index2<12 {
                    sleepValue += value
                    weakeValue += sleepsValue2[index2]
                    lightValue += sleepsValue3[index2]
                    deepValue += sleepsValue4[index2]
                }
            }
            //Calculate the maximum
            if sleepValue>maxValue {
                maxValue = sleepValue
            }
            
            //chart the maximum
            if index == countArray.count-1 {
                self.setChartViewLeftAxis(Double(maxValue/60+2), unitString: " hours")
            }
            
            xVals.append(dateString)
            weakeYVals.append(ChartDataEntry(value: Double(weakeValue)/60, xIndex: index))
            lightYVals.append(ChartDataEntry(value: Double(lightValue)/60, xIndex: index))
            deepYVals.append(ChartDataEntry(value: Double(deepValue)/60, xIndex: index))
            yVals.append(ChartDataEntry(value: 0, xIndex: index))
        }
        
        if sortArray.count == 0 {
            self.setChartViewLeftAxis(Double(maxValue+7), unitString: " hours")
        }
        
        if rowIndex == 0 || rowIndex == 1{
            if xVals.count<7 {
                for index:Int in xVals.count..<7 {
                    weakeYVals.append(ChartDataEntry(value: 0, xIndex: index))
                    lightYVals.append(ChartDataEntry(value: 0, xIndex: index))
                    deepYVals.append(ChartDataEntry(value: 0, xIndex: index))
                }
            }
        }
        
        self.setYvalueData(rowIndex) { (yvalsIndex, replace) in
            if replace {
                let weakeDataentry:ChartDataEntry = weakeYVals[yvalsIndex]
                let lightDataentry:ChartDataEntry = lightYVals[yvalsIndex]
                let deepDataentry:ChartDataEntry = deepYVals[yvalsIndex]
                weakeYVals.replaceRange(rowIndex..<rowIndex+1, with: [ChartDataEntry(value: weakeDataentry.value, xIndex: yvalsIndex)])
                lightYVals.replaceRange(rowIndex..<rowIndex+1, with: [ChartDataEntry(value: lightDataentry.value, xIndex: yvalsIndex)])
                deepYVals.replaceRange(rowIndex..<rowIndex+1, with: [ChartDataEntry(value: deepDataentry.value, xIndex: yvalsIndex)])
                NSLog("xVals:\(self.xVals[yvalsIndex]) [weake:\(weakeDataentry) count:\(weakeYVals.count)],[light:\(lightDataentry) count:\(lightYVals.count)],[deep:\(deepDataentry) count:\(deepYVals.count)]")
            }else{
                weakeYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), atIndex: yvalsIndex)
                lightYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), atIndex: yvalsIndex)
                deepYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), atIndex: yvalsIndex)
            }
        }
        
        let dataArray:[[ChartDataEntry]] = [weakeYVals,lightYVals,deepYVals]
        var dataSets:[LineChartDataSet] = [];
        
        for (index,values) in dataArray.enumerate() {
            let set1:LineChartDataSet = LineChartDataSet(yVals: values, label: "")
            set1.lineDashLengths = [0.0, 0];
            set1.highlightLineDashLengths = [0.0, 0.0];
            set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
            set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
            set1.valueTextColor = UIColor.blackColor()
            set1.lineWidth = 1.0;
            set1.circleRadius = 0.0;
            set1.drawValuesEnabled = false
            set1.drawCircleHoleEnabled = false;
            set1.valueFont = UIFont.systemFontOfSize(9.0)
            //set1.mode = LineChartDataSet.Mode.CubicBezier
            
            let gradientColors:[NSUIColor] = [UIColor.lightGrayColor(),AppTheme.NEVO_SOLAR_YELLOW(),AppTheme.NEVO_SOLAR_GRAY()];
            set1.fillAlpha = 0.5;
            set1.fill = ChartFill.fillWithColor(gradientColors[index])
            //fillWithLinearGradient(gradient, angle: 90.0)
            set1.drawFilledEnabled = true;
            dataSets.append(set1)
        }
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        lineChartView.data = data;
        lineChartView.legend.form = ChartLegend.Form.Line
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
    }
    
    /**
     Set sloar chart data
     
     - parameter countArray: data
     - parameter type:       chart type(this week,last week)
     - parameter rowIndex:   chart index
     */
    func setSloarDataCount(countArray:NSArray,type:Int,rowIndex:Int){
        sortArray.removeAllObjects()
        sortArray.addObjectsFromArray(countArray as [AnyObject])
        
        var maxValue:Int = 0
        for i:Int in 0 ..< countArray.count {
            /**
             *  Data sorting,Small to large sort
             */
            for j:Int in i ..< countArray.count {
                let iSteps:UserSteps = sortArray.objectAtIndex(i) as! UserSteps;
                let jSteps:UserSteps = sortArray.objectAtIndex(j) as! UserSteps;
                let iStepsDate:Double = iSteps.date
                let jStepsDate:Double = jSteps.date
                let iStepsValue:Int = iSteps.steps
                
                //Calculate the maximum
                if iStepsValue>maxValue {
                    maxValue = 0
                }
                //Time has sorted
                if (iStepsDate > jStepsDate){
                    let temp:UserSteps = sortArray.objectAtIndex(i) as! UserSteps;
                    sortArray.replaceObjectAtIndex(i, withObject: sortArray[j])
                    sortArray.replaceObjectAtIndex(j, withObject: temp)
                }
            }
            //chart the maximum
            if i == countArray.count-1 {
                self.setChartViewLeftAxis(Double(maxValue+7), unitString: " hours")
            }
        }
        
        if sortArray.count == 0 {
            self.setChartViewLeftAxis(Double(maxValue+7), unitString: " hours")
        }
        
        for i:Int in 0..<sortArray.count {
            let usersteps:UserSteps = sortArray[i] as! UserSteps
            let date:NSDate = "\(usersteps.createDate)".dateFromFormat("yyyyMMdd")!
            let dateString:String = date.stringFromFormat("dd/MM")
            
            let steps:Double = 0
            yVals.append(ChartDataEntry(value: steps, xIndex: i))
            xVals.append(dateString)
        }
        
        self.setYvalueData(rowIndex,completionData:nil)
        
        let set1:LineChartDataSet = LineChartDataSet(yVals: yVals, label: "")
        set1.lineDashLengths = [0.0, 0];
        set1.highlightLineDashLengths = [0.0, 0.0];
        set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
        set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
        set1.valueTextColor = UIColor.blackColor()
        set1.lineWidth = 1.0;
        set1.circleRadius = 0.0;
        //set1?.drawCirclesEnabled = false;
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false;
        set1.valueFont = UIFont.systemFontOfSize(9.0)
        
        let gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_GRAY().CGColor,AppTheme.NEVO_SOLAR_YELLOW().CGColor];
        let gradient:CGGradientRef = CGGradientCreateWithColors(nil, gradientColors, nil)!
        set1.fillAlpha = 1;
        set1.fill = ChartFill.fillWithLinearGradient(gradient, angle: 80.0)
        set1.drawFilledEnabled = true
        set1.mode = LineChartDataSet.Mode.CubicBezier
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: [set1])
        data.setDrawValues(false)
        lineChartView.data = data;
        //lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInOutCirc)
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
    }
    
    /**
     Set on the left side of the Chart data units
     
     - parameter maxValue:   Max value
     - parameter unitString: unit
     */
    func setChartViewLeftAxis(maxValue:Double,unitString:String) {
        let leftAxis:ChartYAxis = lineChartView.leftAxis;
        leftAxis.axisMaxValue = maxValue;
        leftAxis.axisMinValue = 0.0;
        leftAxis.gridLineDashLengths = [0.0, 0.0];
        leftAxis.labelTextColor = UIColor.blackColor()
        
        leftAxis.labelCount = 5;
        leftAxis.valueFormatter = NSNumberFormatter();
        leftAxis.valueFormatter!.maximumFractionDigits = 1;
        leftAxis.valueFormatter!.negativeSuffix = unitString;
        leftAxis.valueFormatter!.positiveSuffix = unitString;
        leftAxis.labelPosition = ChartYAxis.LabelPosition.OutsideChart
        leftAxis.spaceTop = 0.15;
    }
    
    /**
     set Chart Yvalue
     
     - parameter rowIndex: Which one Chart
     */
    func setYvalueData(rowIndex:Int,completionData:((yvalsIndex:Int,replace:Bool) -> Void)?) {
        let dayTime:Double = 86400
        
        if rowIndex == 0{
            if xVals.count<7 {
                if xVals.count == 0 {
                    let dateString:String = NSDate().beginningOfWeek.stringFromFormat("dd/MM")
                    xVals.append(dateString)
                    yVals.append(ChartDataEntry(value: 0, xIndex: 0))
                }
                for index:Int in xVals.count..<7 {
                    let date:NSDate = xVals[xVals.count-1].dateFromFormat("dd/MM")!
                    let date2:NSDate = NSDate(timeIntervalSince1970: date.timeIntervalSince1970+dayTime)
                    let dateString:String = date2.stringFromFormat("dd/MM")
                    xVals.append(dateString)
                    yVals.append(ChartDataEntry(value: 0, xIndex: index))
                }
            }
        }
        
        if rowIndex == 1{
            let startTimeInterval:NSTimeInterval = NSDate().timeIntervalSince1970-(86400.0*7)
            if xVals.count<7 {
                for index:Int in 1..<7 {
                    if xVals.count==0 {
                        let dateString:String = NSDate(timeIntervalSince1970: startTimeInterval).stringFromFormat("dd/MM")
                        xVals.append(dateString)
                        yVals.append(ChartDataEntry(value: 0, xIndex: index))
                    }
                    
                    let startDate1:NSDate = xVals[index-1].dateFromFormat("dd/MM")!
                    let date2:NSDate = NSDate(timeIntervalSince1970:startTimeInterval+dayTime*Double(index))
                    let dateString1:String = startDate1.stringFromFormat("dd/MM")
                    let dateString2:String = date2.stringFromFormat("dd/MM")
                    if index != 0 {
                        if dateString1 != dateString2 {
                            xVals.insert(dateString2, atIndex: index-1)
                            yVals.insert(ChartDataEntry(value: 0, xIndex: index-1), atIndex: index-1)
                        }else{
                            let dataentry:ChartDataEntry = yVals[index]
                            yVals.replaceRange(index-1..<index, with: [ChartDataEntry(value: dataentry.value, xIndex: index)])
                        }
                        
                    }
                }
            }
        }
        
        if rowIndex == 2 {
            let startTimeInterval:NSTimeInterval = NSDate().timeIntervalSince1970-(dayTime*30)
            if xVals.count<30 {
                for index:Int in 0..<30 {
                    if xVals.count==0 {
                        let dateString:String = NSDate(timeIntervalSince1970: startTimeInterval).stringFromFormat("dd/MM")
                        xVals.append(dateString)
                        yVals.append(ChartDataEntry(value: 0, xIndex: index))
                    }
                    
                    var getIndex:Int = index
                    if index>=xVals.count {
                        getIndex = index-1
                    }
                    let startDate1:NSDate = xVals[getIndex].dateFromFormat("dd/MM")!
                    let date2:NSDate = NSDate(timeIntervalSince1970:startTimeInterval+dayTime*Double(index))
                    let dateString1:String = startDate1.stringFromFormat("dd/MM")
                    let dateString2:String = date2.stringFromFormat("dd/MM")
                    
                    if dateString1 != dateString2 {
                        xVals.insert(dateString2, atIndex: index)
                        yVals.insert(ChartDataEntry(value: 0, xIndex: index), atIndex: index)
                        completionData?(yvalsIndex: index,replace:false)
                    }else{
                        let dataentry:ChartDataEntry = yVals[index]
                        yVals.replaceRange(index..<index+1, with: [ChartDataEntry(value: dataentry.value, xIndex: index)])
                        completionData?(yvalsIndex: index,replace:true)
                    }
                    
                }
            }
        }
    }
}
