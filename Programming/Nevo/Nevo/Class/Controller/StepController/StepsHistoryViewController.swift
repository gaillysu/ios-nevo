//
//  StepHistoricalViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import Charts
import SwiftEventBus

class StepsHistoryViewController: PublicClassController,UICollectionViewDelegateFlowLayout,ChartViewDelegate {

    @IBOutlet weak var stepsHistory: UICollectionView!
    @IBOutlet weak var chartView: BarChartView!
    
    let SELECTED_DATA:String = "SELECTED_DATA"
    
    private var queryArray:NSArray = NSArray()
    private var contentTitleArray:[String] = [NSLocalizedString("CALORIE", comment: ""), NSLocalizedString("STEPS", comment: ""), NSLocalizedString("TIME", comment: ""),NSLocalizedString("KM", comment: "")]
    private var contentTArray:[String] = [NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: "")]
    private var queryModel:NSMutableArray = NSMutableArray()
    private let sleepArray:NSMutableArray = NSMutableArray();
    private let detailArray:NSMutableArray = NSMutableArray(capacity:1);
    
    init() {
        super.init(nibName: "StepsHistoryViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configChartView()
        
        let dayDate:NSDate = NSDate()
        let dayTime:NSTimeInterval = NSDate.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
            //NSDate().beginningOfDay.timeIntervalSince1970
        queryArray = UserSteps.getCriteria("WHERE date = \(dayTime)") //one hour = 3600s
        self.bulidStepHistoricalChartView(queryArray)
        
        stepsHistory.backgroundColor = UIColor.whiteColor()
        stepsHistory.registerNib(UINib(nibName: "StepGoalSetingViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "StepGoalSetingIdentifier")
        stepsHistory.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "StepsHistoryViewCell")
        (stepsHistory.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width/2.0, 40.0)
        
        SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            let userinfo:NSDate = notification.userInfo!["selectedDate"] as! NSDate
            self.queryArray = UserSteps.getCriteria("WHERE date = \(userinfo.beginningOfDay.timeIntervalSince1970)")
            self.bulidStepHistoricalChartView(self.queryArray)
        }
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY) { (notification) in
            let dict:[String:AnyObject] = notification.object as! [String:AnyObject]
            let dailySteps:Int = dict["STEPS"] as! Int
            let dailyStepGoal:Int = dict["GOAL"] as! Int
            let percent :Float = dict["PERCENT"] as! Float
            //self.contentTArray.insert("\(dataSteps.calories)", atIndex: 0)
            self.contentTArray.replaceRange(Range(1..<2), with: ["\(dailySteps)"])
            self.stepsHistory.reloadData()
        }
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            let array:NSArray = UserSteps.getCriteria("WHERE date = \(NSDate().beginningOfDay.timeIntervalSince1970)")
            if array.count>0 {
                let dataSteps:UserSteps = array[0] as! UserSteps
                self.contentTArray.removeAll()
                self.contentTArray.insert("\(dataSteps.calories)", atIndex: 0)
                self.contentTArray.insert("\(dataSteps.steps)", atIndex: 1)
                self.contentTArray.insert("\(dataSteps.inactivityTime/60)m", atIndex: 2)
                self.contentTArray.insert(String(format: "%.2f",(dataSteps.walking_distance+dataSteps.running_distance)/1000), atIndex: 3)
                self.stepsHistory.reloadData()
            }
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self, name: SELECTED_CALENDAR_NOTIFICATION)
        SwiftEventBus.unregister(self, name: EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY)
        SwiftEventBus.unregister(self, name: EVENT_BUS_BEGIN_BIG_SYNCACTIVITY)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - ConfigChartView
    func configChartView() {
        chartView!.noDataText = NSLocalizedString("no_step_data", comment: "")
        chartView!.descriptionText = ""
        chartView!.pinchZoomEnabled = false
        chartView!.doubleTapToZoomEnabled = false
        chartView!.legend.enabled = false
        chartView!.dragEnabled = true
        chartView!.rightAxis.enabled = true
        chartView!.setScaleEnabled(false)
        chartView.delegate = self
        
        let xAxis:ChartXAxis = chartView!.xAxis
        xAxis.labelTextColor = UIColor.blackColor()
        xAxis.axisLineColor = UIColor.blackColor()
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 7)!
        
        let yAxis:ChartYAxis = chartView!.leftAxis
        yAxis.labelTextColor = UIColor.blackColor()
        yAxis.axisLineColor = UIColor.blackColor()
        yAxis.drawAxisLineEnabled  = true
        yAxis.drawGridLinesEnabled  = true
        yAxis.drawLimitLinesBehindDataEnabled = true
        yAxis.axisMinValue = 0
        yAxis.setLabelCount(5, force: true)
        
        let rightAxis:ChartYAxis = chartView!.rightAxis
        rightAxis.labelTextColor = UIColor.clearColor()
        rightAxis.axisLineColor = UIColor.blackColor()
        rightAxis.drawAxisLineEnabled  = true
        rightAxis.drawGridLinesEnabled  = true
        rightAxis.drawLimitLinesBehindDataEnabled = true
        rightAxis.drawZeroLineEnabled = true
        
        chartView!.rightAxis.enabled = false
        chartView.drawBarShadowEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentTitleArray.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StepGoalSetingIdentifier", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.whiteColor()
        (cell as! StepGoalSetingViewCell).titleLabel.text = contentTitleArray[indexPath.row]
        (cell as! StepGoalSetingViewCell).valueLabel.text = "\(contentTArray[indexPath.row])"
        return cell
    }
    
    func bulidStepHistoricalChartView(modelArray:NSArray){
        queryModel.removeAllObjects()
        sleepArray.removeAllObjects()
        queryModel.addObjectsFromArray(modelArray as [AnyObject])
        self.slidersValueChanged()
    }
    
    func slidersValueChanged(){
        self.setDataCount(queryModel.count, Range: 50)
    }

    func stringFromDate(date:NSDate) -> String {
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString:String = dateFormatter.stringFromDate(date)
        return dateString
    }
    
    func setDataCount(count:Int, Range range:Double){
        if(count == 0) {
            chartView?.data = nil
            return
        }
        
        var xVal:[String] = [];
        var yVal:[BarChartDataEntry] = [];
        
        let seleModel:UserSteps = queryModel.objectAtIndex(0) as! UserSteps;
        let hourlystepsArray:NSArray = AppTheme.jsonToArray(seleModel.hourlysteps)
        for (index,steps) in hourlystepsArray.enumerate(){
            let val1:Double  = (steps as! NSNumber).doubleValue;
            let date:NSDate = NSDate(timeIntervalSince1970: seleModel.date)
            var dateString:NSString = date.stringFromFormat("yyyyMMdd")
            if(dateString.length < 8) {
                dateString = "00000000"
            }
            xVal.append("\(index):00")
            yVal.append(BarChartDataEntry(values: [val1], xIndex:index))
        }
        
        //柱状图表
        //ChartColorTemplates.getDeepSleepColor()
        let set1:BarChartDataSet  = BarChartDataSet(yVals: yVal, label: "")
        //每个数据区块的颜色
        set1.colors = [AppTheme.NEVO_SOLAR_YELLOW()];
        set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
        set1.barSpace = 0.1;
        let dataSets:[BarChartDataSet] = [set1];
        
        let data:BarChartData = BarChartData(xVals: xVal, dataSets: dataSets)
        data.setDrawValues(false);//false 显示柱状图数值否则不显示
        chartView?.data = data;
        chartView?.animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
        chartView?.moveViewToX(CGFloat(yVal.count))
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        chartView.highlightValue(xIndex: entry.xIndex, dataSetIndex: dataSetIndex, callDelegate: false)
        NSLog("chartValueSelected:  %d",entry.xIndex)
        let stepsModel:UserSteps = queryModel.objectAtIndex(0) as! UserSteps;
        //let hourlystepsArray:NSArray = AppTheme.jsonToArray(stepsModel.hourlysteps)
        self.didSelectedhighlightValue(entry.xIndex,dataSetIndex: dataSetIndex, dataSteps:stepsModel)
//        let array:NSArray = NSArray(array: [entry.xIndex,dataSetIndex,stepsModel])
//        AppTheme.KeyedArchiverName(SELECTED_DATA, andObject: array)
    }
    
    func didSelectedhighlightValue(xIndex:Int,dataSetIndex: Int, dataSteps:UserSteps) {
        
        self.contentTArray.removeAll()
        self.contentTArray.insert("\(dataSteps.calories)", atIndex: 0)
        self.contentTArray.insert("\(dataSteps.steps)", atIndex: 1)
        self.contentTArray.insert("\(dataSteps.inactivityTime/60)m", atIndex: 2)
        self.contentTArray.insert(String(format: "%.2f km",(dataSteps.walking_distance+dataSteps.running_distance)/1000), atIndex: 3)
        self.stepsHistory.reloadData()
    }
}

// MARK: - Data calculation
extension StepsHistoryViewController {
    
    func calculationData(activeTimer:Int,steps:Int,completionData:((miles:String,calories:String) -> Void)) {
        let profile:NSArray = UserProfile.getAll()
        let userProfile:UserProfile = profile.objectAtIndex(0) as! UserProfile
        let strideLength:Double = Double(userProfile.length)*0.415/100
        let miles:Double = strideLength*Double(steps)/1000
        //Formula's = (2.0 X persons KG X 3.5)/200 = calories per minute
        let calories:Double = (2.0*Double(userProfile.weight)*3.5)/200*Double(activeTimer)
        completionData(miles: String(format: "%.2f",miles), calories: String(format: "%.2f",calories))
    }
}