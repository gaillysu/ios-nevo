//
//  AnalysisLineChartCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/9.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Charts

class AnalysisLineChartCell: UICollectionViewCell,ChartViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    fileprivate var sortArray:NSMutableArray = NSMutableArray()
    
    fileprivate var xVals:[String] = []
    fileprivate var yVals:[ChartDataEntry] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initChartView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            titleLabel.textColor = UIColor.white
        }
    }

    fileprivate func initChartView() {
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
        xAxis.labelTextColor = UIColor.black;
        xAxis.axisLineColor = AppTheme.NEVO_SOLAR_GRAY()
        xAxis.drawLimitLinesBehindDataEnabled = false;
        xAxis.labelPosition = ChartXAxis.LabelPosition.bottom
        xAxis.labelFont = UIFont(name: "Raleway", size: 7)!
        
        lineChartView.legend.form = ChartLegend.Form.line
        lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.easeInOutCirc)
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            xAxis.labelTextColor = UIColor.white;
        }
    }
    
    func setTitle(_ title:String) {
        titleLabel.text = title.uppercased()
    }
    
    func setContentValue(_ title:String) {
        titleLabel.text = title
    }
    
    func updateChartData(_ dataArray:NSArray,chartType:Int,rowIndex:Int,completionData:((_ totalValue:Float,_ totalCalores:Int,_ totalTime:Double) -> Void)) {
        lineChartView.data = nil
        xVals = []
        yVals = []
        
        switch chartType {
        case 0:
            let marker:BalloonMarker = BalloonMarker(color: AppTheme.NEVO_SOLAR_YELLOW(), font: UIFont.systemFont(ofSize: 12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
            marker.minimumSize = CGSize(width: 80.0, height: 40.0);
            marker.markerType = .stepsChartType
            lineChartView.marker = marker;
            var totalSteps:Int = 0
            var totalCalores:Int = 0
            var totalTime:Int = 0
            for value in dataArray {
                let usersteps:MEDUserSteps = value as! MEDUserSteps
                totalSteps += usersteps.totalSteps
                totalCalores += Int(usersteps.totalCalories)
                totalTime += (usersteps.walking_duration+usersteps.running_duration)
            }
            completionData(Float(totalSteps), totalCalores, Double(totalTime)/60.0)
            self.setStepsDataCount(dataArray, type: chartType,rowIndex:rowIndex)
        case 1:
            let marker:BalloonMarker = BalloonMarker(color: AppTheme.NEVO_SOLAR_YELLOW(), font: UIFont.systemFont(ofSize: 12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
            marker.minimumSize = CGSize(width: 80.0, height: 40.0);
            marker.markerType = .sleepChartType
            lineChartView.marker = marker;
            var totalValue:Int = 0
            var weakeValue:Int = 0
            var deepValue:Int = 0
            for value in dataArray {
                let userSleep:MEDUserSleep = value as! MEDUserSleep
                let sleepTime:[Int] = AppTheme.jsonToArray(userSleep.hourlySleepTime) as! [Int]
                let weakeSleepTime:[Int] = AppTheme.jsonToArray(userSleep.hourlyWakeTime) as! [Int]
                let deepSleepTime:[Int] = AppTheme.jsonToArray(userSleep.hourlyDeepTime) as! [Int]
                
                totalValue +=  sleepTime.reduce(0, {$0 + $1})
                
                weakeValue += weakeSleepTime.reduce(0, {$0 + $1})
                
                deepValue += deepSleepTime.reduce(0, {$0 + $1})
            }

            let isNan = (Double(deepValue)/Double(totalValue)).isNaN
            var quality:Double = isNan ? 0:(Double(deepValue)/Double(totalValue))*100
            if totalValue == 0 {
                quality = 0
            }
            
            completionData(Float(totalValue)/60.0, weakeValue, quality)
            self.setSleepDataCount(dataArray, type: chartType,rowIndex:rowIndex)
        case 2:
            let marker:BalloonMarker = BalloonMarker(color: AppTheme.NEVO_SOLAR_YELLOW(), font: UIFont.systemFont(ofSize: 12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
            marker.minimumSize = CGSize(width: 80.0, height: 40.0);
            marker.markerType = .stepsChartType
            lineChartView.marker = marker;
            
            var totalValue:Int = 0
            for value in dataArray {
                let userSleep:SolarHarvest = value as! SolarHarvest
                let sleepTime:[Int] = AppTheme.jsonToArray(userSleep.solarHourlyTime) as! [Int]
                totalValue +=  sleepTime.reduce(0, {$0 + $1})
            }
            completionData(Float(totalValue)/60.0, 0, 0)
            self.setSloarDataCount(dataArray, type: chartType,rowIndex:rowIndex)
        default: break
        }
    }
    
    func setStepsDataCount(_ countArray:NSArray,type:Int,rowIndex:Int) {
        var maxValue:Int = 0
        var userStepsArray:[MEDUserSteps] = []
        
        for i:Int in 0 ..< countArray.count {
            let steps:MEDUserSteps = countArray.object(at: i) as! MEDUserSteps;
            userStepsArray.append(steps)
        }
        
        userStepsArray = userStepsArray.sorted(by: {$0.date < $1.date })
        
        if userStepsArray.count == 0 {
            self.setChartViewLeftAxis(Double(maxValue+1000), unitString: "")
        }
        
        for i:Int in 0..<userStepsArray.count {
            let usersteps:MEDUserSteps = userStepsArray[i]
            let date:Date = "\(usersteps.createDate)".dateFromFormat("yyyyMMdd",locale: DateFormatter().locale)!
            let dateString:String = date.stringFromFormat("dd/MM")
            let stepsArray:[Int] = AppTheme.jsonToArray(usersteps.hourlysteps) as! [Int]
            let totalSteps:Int = stepsArray.reduce(0, {$0 + $1})
            
            yVals.append(ChartDataEntry(value: Double(totalSteps), xIndex: i))
            xVals.append(dateString)
            
            //Calculate the maximum
            if totalSteps>maxValue {
                maxValue = totalSteps
            }
        }
        
        self.setChartViewLeftAxis(Double(maxValue-(maxValue%2)+800), unitString: "")
        
        self.setYvalueData(rowIndex,completionData: nil)
        
        let set1:LineChartDataSet = LineChartDataSet(yVals: yVals, label: "")
        set1.lineDashLengths = [0.0, 0];
        set1.highlightLineDashLengths = [0.0, 0.0];
        set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
        set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
        set1.valueTextColor = UIColor.black
        set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
        set1.lineWidth = 1.0;
        set1.circleRadius = 0.0;
        //set1?.drawCirclesEnabled = false;
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false;
        set1.valueFont = UIFont.systemFont(ofSize: 9.0)
        
        var gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_YELLOW().cgColor,AppTheme.NEVO_SOLAR_GRAY().cgColor];
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            gradientColors = [UIColor.getTintColor().cgColor,UIColor.getBaseColor().cgColor];
        }
        let gradient:CGGradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        set1.fillAlpha = 1;
        set1.fill = ChartFill.fillWithLinearGradient(gradient, angle: 80.0)
        set1.drawFilledEnabled = true
        set1.mode = LineChartDataSet.Mode.cubicBezier
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: [set1])
        data.setDrawValues(false)
        lineChartView.data = data;
        //lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInOutCirc)
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCirc)
    }

    func setSleepDataCount(_ countArray:NSArray,type:Int,rowIndex:Int) {
        var weakeYVals:[ChartDataEntry] = []
        var lightYVals:[ChartDataEntry] = []
        var deepYVals:[ChartDataEntry] = []
        
        var maxValue:Int = 0
        var sleepValueArray:[MEDUserSleep] = []
        
        for i:Int in 0 ..< countArray.count {
            let sleep:MEDUserSleep = countArray.object(at: i) as! MEDUserSleep;
            sleepValueArray.append(sleep)
        }
        
        sleepValueArray = sleepValueArray.sorted(by: {$0.date < $1.date })

        
        for (index,sleep) in sleepValueArray.enumerated() {
            
            var sleepValue:Int = 0
            var weakeValue:Int = 0
            var lightValue:Int = 0
            var deepValue:Int = 0
            
            let mSleeps:MEDUserSleep = sleep
            
            let sleepsValue1:[Int] = AppTheme.jsonToArray(mSleeps.hourlySleepTime) as! [Int]
            let wakeSleep:[Int] = AppTheme.jsonToArray(mSleeps.hourlyWakeTime) as! [Int]
            let lightSleep:[Int] = AppTheme.jsonToArray(mSleeps.hourlyLightTime) as! [Int]
            let deepSleep:[Int] = AppTheme.jsonToArray(mSleeps.hourlyDeepTime) as! [Int]
            
            let date:Date = Date(timeIntervalSince1970: mSleeps.date)
            let dateString:String = date.stringFromFormat("dd/MM")
            
            if index>0 {
                let kSleeps:MEDUserSleep = sleepValueArray[index-1]
                let value1:[Int] = AppTheme.jsonToArray(kSleeps.hourlySleepTime) as! [Int]
                let value2:[Int] = AppTheme.jsonToArray(kSleeps.hourlyWakeTime) as! [Int]
                let value3:[Int] = AppTheme.jsonToArray(kSleeps.hourlyLightTime) as! [Int]
                let value4:[Int] = AppTheme.jsonToArray(kSleeps.hourlyDeepTime) as! [Int]
                
                
                sleepValue = value1.dropFirst(18).reduce(0, {$0 + $1})
                weakeValue = value2.dropFirst(18).reduce(0, {$0 + $1})
                lightValue = value3.dropFirst(18).reduce(0, {$0 + $1})
                deepValue = value4.dropFirst(18).reduce(0, {$0 + $1})

            }
            
            sleepValue += sleepsValue1.prefix(12).reduce(0, {$0 + $1})
            weakeValue += wakeSleep.prefix(12).reduce(0, {$0 + $1})
            lightValue += lightSleep.prefix(12).reduce(0, {$0 + $1})
            deepValue += deepSleep.prefix(12).reduce(0, {$0 + $1})
            
            
            //Calculate the maximum
            if sleepValue>maxValue {
                maxValue = sleepValue
            }
            
            //chart the maximum
            if index == countArray.count-1 {
                self.setChartViewLeftAxis(Double(maxValue/60+2), unitString: " "+NSLocalizedString("hours", comment: ""))
            }
            
            weakeYVals.append(ChartDataEntry(value: (Double(weakeValue)/60).to2Double(), xIndex: index))
            lightYVals.append(ChartDataEntry(value: (Double(lightValue)/60).to2Double(), xIndex: index))
            deepYVals.append(ChartDataEntry(value: (Double(deepValue)/60).to2Double(), xIndex: index))
            xVals.append(dateString)
            yVals.append(ChartDataEntry(value: 0, xIndex: index))
        }
        
        if sleepValueArray.count == 0 {
            self.setChartViewLeftAxis(Double(maxValue+7), unitString: " "+NSLocalizedString("hours", comment: ""))
        }else{
            if maxValue == 0 {
                self.setChartViewLeftAxis(Double(maxValue+7), unitString: " "+NSLocalizedString("hours", comment: ""))
            }
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
        
        /*
         重新排列数据，因为数据库得到的数据可能是不连续的，如果是不连续的还需要重新构造元素，元素需要重新加入数组排列
         */
        self.setYvalueData(rowIndex) { (yvalsIndex, replace) in
            if replace {
                if weakeYVals.count > 0{
                    let weakeDataentry:ChartDataEntry = weakeYVals[yvalsIndex]
                    let lightDataentry:ChartDataEntry = lightYVals[yvalsIndex]
                    let deepDataentry:ChartDataEntry = deepYVals[yvalsIndex]
                    weakeYVals.replaceSubrange(yvalsIndex..<yvalsIndex+1, with: [ChartDataEntry(value: weakeDataentry.value.to2Double(), xIndex: yvalsIndex)])
                    lightYVals.replaceSubrange(yvalsIndex..<yvalsIndex+1, with: [ChartDataEntry(value: lightDataentry.value.to2Double(), xIndex: yvalsIndex)])
                    deepYVals.replaceSubrange(yvalsIndex..<yvalsIndex+1, with: [ChartDataEntry(value: deepDataentry.value.to2Double(), xIndex: yvalsIndex)])
                }else{
                    weakeYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), at: yvalsIndex)
                    lightYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), at: yvalsIndex)
                    deepYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), at: yvalsIndex)
                }
                
            }else{
                weakeYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), at: yvalsIndex)
                lightYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), at: yvalsIndex)
                deepYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), at: yvalsIndex)
            }
        }
        
        /*
         *此方法只适用于睡眠数据排序*
         由于计算数据排序，有可能会有重复多余数据，因此在这里只要删除和对应个数不同，数组最后的元素即可.
         rowIndex:代表当前对应的第几个图表，rowIndex == 0 || rowIndex == 1 (数组的元素个数应该为7), rowIndex == 2 数组的元素个数为30
         */
        if rowIndex == 0 || rowIndex == 1{
            if weakeYVals.count>7 && lightYVals.count>7 && deepYVals.count>7{
                var valueIndex:Int = 0
                for atIndex in 7..<weakeYVals.count {
                    weakeYVals.remove(at: atIndex-valueIndex)
                    lightYVals.remove(at: atIndex-valueIndex)
                    deepYVals.remove(at: atIndex-valueIndex)
                    valueIndex+=1
                }
            }
        }else{
            if weakeYVals.count>30 && lightYVals.count>30 && deepYVals.count>30{
                var valueIndex:Int = 0
                for atIndex in 30..<weakeYVals.count {
                    weakeYVals.remove(at: atIndex-valueIndex)
                    lightYVals.remove(at: atIndex-valueIndex)
                    deepYVals.remove(at: atIndex-valueIndex)
                    valueIndex+=1
                }
            }
        }
        
        let dataArray:[[ChartDataEntry]] = [weakeYVals,lightYVals,deepYVals]
        var dataSets:[LineChartDataSet] = [];
        
        for (index,values) in dataArray.enumerated() {
            let set1:LineChartDataSet = LineChartDataSet(yVals: values, label: "")
            set1.lineDashLengths = [0.0, 0];
            set1.highlightLineDashLengths = [0.0, 0.0];
            set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
            set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
            set1.valueTextColor = UIColor.black
            set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
            set1.lineWidth = 1.0;
            set1.circleRadius = 0.0;
            set1.drawValuesEnabled = false
            set1.drawCircleHoleEnabled = false;
            set1.valueFont = UIFont.systemFont(ofSize: 9.0)
            //set1.mode = LineChartDataSet.Mode.CubicBezier
            
            var gradientColors:[UIColor] = [UIColor.lightGray,AppTheme.NEVO_SOLAR_YELLOW(),AppTheme.NEVO_SOLAR_GRAY()];
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                gradientColors = [UIColor.lightGray,UIColor.getTintColor(),UIColor.getBaseColor()];
            }
            set1.fillAlpha = 0.5;
            set1.fill = ChartFill.fillWithColor(gradientColors[index])
            //fillWithLinearGradient(gradient, angle: 90.0)
            set1.drawFilledEnabled = true;
            dataSets.append(set1)
        }
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        lineChartView.data = data;
        lineChartView.legend.form = ChartLegend.Form.line
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCirc)
    }
    
    /**
     Set sloar chart data
     
     - parameter countArray: data
     - parameter type:       chart type(this week,last week)
     - parameter rowIndex:   chart index
     */
    func setSloarDataCount(_ countArray:NSArray,type:Int,rowIndex:Int){
        sortArray.removeAllObjects()
        sortArray.addObjects(from: countArray as [AnyObject])
        
        var sloarValue:[SolarHarvest] = []
        var maxValue:Int = 0
        
        for i:Int in 0 ..< countArray.count {
            let sloar:SolarHarvest = countArray.object(at: i) as! SolarHarvest;
            sloarValue.append(sloar)
            //chart the maximum
        }
        
        sloarValue = sloarValue.sorted(by: {$0.date < $1.date })
         
        if sloarValue.count == 0 {
            self.setChartViewLeftAxis(Double(maxValue+1), unitString: "")
        }
        
        for (index,value) in sloarValue.enumerated() {
            let sloarValue:SolarHarvest = value
            let date:Date = Date(timeIntervalSince1970: sloarValue.date)
            let dateString:String = date.stringFromFormat("dd/MM")
            
            let sloarTime:Double = Double(sloarValue.solarTotalTime)
            yVals.append(ChartDataEntry(value: sloarTime, xIndex: index))
            xVals.append(dateString)
            
            let iSloarValue:Int = sloarValue.solarTotalTime
            //Calculate the maximum
            if iSloarValue>maxValue {
                maxValue = iSloarValue
            }
        }
        
        
        self.setChartViewLeftAxis(Double(Double(maxValue)/60.0+7), unitString: " "+NSLocalizedString("hours", comment: ""))
        
        self.setYvalueData(rowIndex,completionData:nil)
        
        let set1:LineChartDataSet = LineChartDataSet(yVals: yVals, label: "")
        set1.lineDashLengths = [0.0, 0];
        set1.highlightLineDashLengths = [0.0, 0.0];
        set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
        set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
        set1.valueTextColor = UIColor.black
        set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
        set1.lineWidth = 1.0;
        set1.circleRadius = 0.0;
        //set1?.drawCirclesEnabled = false;
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false;
        set1.valueFont = UIFont.systemFont(ofSize: 9.0)
        
        var gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_GRAY().cgColor,AppTheme.NEVO_SOLAR_YELLOW().cgColor];
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            gradientColors = [UIColor.getBaseColor().cgColor,UIColor.getTintColor().cgColor];
        }
        
        let gradient:CGGradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        set1.fillAlpha = 1;
        set1.fill = ChartFill.fillWithLinearGradient(gradient, angle: 80.0)
        set1.drawFilledEnabled = true
        set1.mode = LineChartDataSet.Mode.cubicBezier
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: [set1])
        data.setDrawValues(false)
        lineChartView.data = data;
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCirc)
    }
    
    /**
     Set on the left side of the Chart data units
     
     - parameter maxValue:   Max value
     - parameter unitString: unit
     */
    func setChartViewLeftAxis(_ maxValue:Double,unitString:String) {
        let leftAxis:ChartYAxis = lineChartView.leftAxis;
        leftAxis.axisMaxValue = maxValue;
        leftAxis.axisMinValue = 0.0;
        leftAxis.gridLineDashLengths = [0.0, 0.0];
        leftAxis.labelTextColor = UIColor.black
        leftAxis.labelFont = UIFont(name: "Raleway", size: 10)!
        
        //leftAxis.labelCount = 5;
        leftAxis.valueFormatter = NumberFormatter();
        leftAxis.valueFormatter!.maximumFractionDigits = 1;
        leftAxis.valueFormatter!.negativeSuffix = unitString;
        leftAxis.valueFormatter!.positiveSuffix = unitString;
        leftAxis.labelPosition = ChartYAxis.LabelPosition.outsideChart
        leftAxis.spaceTop = 0.15;
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            leftAxis.labelTextColor = UIColor.white;
        }
    }
    
    /**
     set Chart Yvalue
     
     - parameter rowIndex: Which one Chart
     */
    func setYvalueData(_ rowIndex:Int,completionData:((_ yvalsIndex:Int,_ replace:Bool) -> Void)?) {
        let dayTime:Double = 86400
        
        if rowIndex == 0{
            let startTimeInterval:TimeInterval = Date().beginningOfWeek.timeIntervalSince1970
            if xVals.count<7 {
                for index:Int in 0..<7 {
                    if xVals.count == 0 {
                        let dateString:String = Date().beginningOfWeek.stringFromFormat("dd/MM")
                        xVals.append(dateString)
                        yVals.append(ChartDataEntry(value: 0, xIndex: 0))
                    }
                    var getIndex:Int = index
                    if index>=xVals.count {
                        getIndex = index-1
                    }
                    
                    let startDate1:Date = xVals[getIndex].dateFromFormat("dd/MM",locale: DateFormatter().locale)!
                    let date2:Date = Date(timeIntervalSince1970:startTimeInterval+dayTime*Double(index))
                    let dateString1:String = startDate1.stringFromFormat("dd/MM")
                    let dateString2:String = date2.stringFromFormat("dd/MM")
                    if dateString1 != dateString2 {
                        xVals.insert(dateString2, at: index)
                        yVals.insert(ChartDataEntry(value: 0, xIndex: index), at: index)
                        completionData?(index,false)
                    }else{
                        let dataentry:ChartDataEntry = yVals[index]
                        yVals.replaceSubrange(index..<index+1, with: [ChartDataEntry(value: dataentry.value.to2Double(), xIndex: getIndex)])
                        completionData?(getIndex,true)
                    }
                    
                    if index == 6 {
                        if yVals.count>7 {
                            var valueIndex:Int = 0
                            for atIndex in 7..<yVals.count {
                                xVals.remove(at: atIndex-valueIndex)
                                yVals.remove(at: atIndex-valueIndex)
                                valueIndex+=1
                            }
                        }
                        let dataentry:ChartDataEntry = yVals[yVals.count-1]
                        yVals.replaceSubrange(yVals.count-1..<yVals.count, with: [ChartDataEntry(value: dataentry.value.to2Double(), xIndex: yVals.count-1)])
                        completionData?(yVals.count-1,true)
                    }
                }
            }
        }
        
        if rowIndex == 1{
            let startTimeInterval:TimeInterval = Date().beginningOfDay.timeIntervalSince1970-(86400.0*7)-1
            if xVals.count<7 {
                for index:Int in 0..<7 {
                    if xVals.count==0 {
                        let dateString:String = Date(timeIntervalSince1970: startTimeInterval).stringFromFormat("dd/MM")
                        xVals.append(dateString)
                        yVals.append(ChartDataEntry(value: 0, xIndex: index))
                    }
                    
                    var getIndex:Int = index
                    if index>=xVals.count {
                        getIndex = index-1
                    }
                    let startDate1:Date = xVals[getIndex].dateFromFormat("dd/MM",locale: DateFormatter().locale)!
                    let date2:Date = Date(timeIntervalSince1970:startTimeInterval+dayTime*Double(index))
                    let dateString1:String = startDate1.stringFromFormat("dd/MM")
                    let dateString2:String = date2.stringFromFormat("dd/MM")
                    
                    if dateString1 != dateString2 {
                        xVals.insert(dateString2, at: index)
                        yVals.insert(ChartDataEntry(value: 0, xIndex: index), at: index)
                        completionData?(index,false)
                    }else{
                        let dataentry:ChartDataEntry = yVals[index]
                        yVals.replaceSubrange(index..<index+1, with: [ChartDataEntry(value: dataentry.value.to2Double(), xIndex: index)])
                        completionData?(index,true)
                    }
                    
                    if index == 6 {
                        if yVals.count>7 {
                            var valueIndex:Int = 0
                            for atIndex in 7..<yVals.count {
                                xVals.remove(at: atIndex-valueIndex)
                                yVals.remove(at: atIndex-valueIndex)
                                valueIndex+=1
                            }
                        }
                        let dataentry:ChartDataEntry = yVals[yVals.count-1]
                        yVals.replaceSubrange(yVals.count-1..<yVals.count, with: [ChartDataEntry(value: dataentry.value.to2Double(), xIndex: yVals.count-1)])
                        completionData?(yVals.count-1,true)
                    }
                }
            }
        }
        
        if rowIndex == 2 {
            let startTimeInterval:TimeInterval = Date().beginningOfDay.timeIntervalSince1970-(dayTime*30)-1
            if xVals.count<30 {
                for index:Int in 0..<30 {
                    if xVals.count==0 {
                        let dateString:String = Date(timeIntervalSince1970: startTimeInterval).stringFromFormat("dd/MM")
                        xVals.append(dateString)
                        yVals.append(ChartDataEntry(value: 0, xIndex: index))
                    }
                    var getIndex:Int = index
                    if index>=xVals.count {
                        getIndex = index-1
                    }
                    let startDate1:Date = xVals[getIndex].dateFromFormat("dd/MM",locale: DateFormatter().locale)!
                    let date2:Date = Date(timeIntervalSince1970:startTimeInterval+dayTime*Double(index))
                    let dateString1:String = startDate1.stringFromFormat("dd/MM")
                    let dateString2:String = date2.stringFromFormat("dd/MM")
                    
                    if dateString1 != dateString2 {
                        xVals.insert(dateString2, at: index)
                        yVals.insert(ChartDataEntry(value: 0, xIndex: index), at: index)
                        completionData?(index,false)
                    }else{
                        let dataentry:ChartDataEntry = yVals[index]
                        yVals.replaceSubrange(index..<index+1, with: [ChartDataEntry(value: dataentry.value.to2Double(), xIndex: index)])
                        completionData?(index,true)
                    }
                    
                    if index == 29 {
                        if yVals.count>30 {
                            var valueIndex:Int = 0
                            for atIndex in 30..<yVals.count {
                                xVals.remove(at: atIndex-valueIndex)
                                yVals.remove(at: atIndex-valueIndex)
                                valueIndex+=1
                            }
                        }
                        let dataentry:ChartDataEntry = yVals[yVals.count-1]
                        yVals.replaceSubrange(yVals.count-1..<yVals.count, with: [ChartDataEntry(value: dataentry.value.to2Double(), xIndex: yVals.count-1)])
                        completionData?(yVals.count-1,true)
                    }
                }
            }
        }
    }
}
