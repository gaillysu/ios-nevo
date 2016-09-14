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
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        saveContentTArray()
        
        SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            let userinfo:NSDate = notification.userInfo!["selectedDate"] as! NSDate
            self.queryArray = UserSteps.getCriteria("WHERE date = \(userinfo.beginningOfDay.timeIntervalSince1970)")
            self.bulidStepHistoricalChartView(self.queryArray)
        }
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY) { (notification) in
            let dict:[String:AnyObject] = notification.object as! [String:AnyObject]
            let dailySteps:Int = dict["STEPS"] as! Int
            self.calculationData(0, steps: dailySteps, completionData: { (miles, calories) in
                self.contentTArray.replaceRange(Range(3..<4), with: ["\(miles)"])
            })
            self.stepsHistory.reloadData()
        }
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            self.saveContentTArray()
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
    
    /**
     Archiver "contentTArray"
     */
    func saveContentTArray() {
        //Only for today's data
        let array:NSArray = UserSteps.getCriteria("WHERE date = \(NSDate().beginningOfDay.timeIntervalSince1970)")
        self.queryArray = array
        self.bulidStepHistoricalChartView(array)
        
        if array.count>0 {
            let dataSteps:UserSteps = array[0] as! UserSteps
            
            self.contentTArray.replaceRange(Range(0..<1), with: ["\(dataSteps.calories)"])
            self.contentTArray.replaceRange(Range(1..<2), with: ["\(dataSteps.steps)"])
            self.contentTArray.replaceRange(Range(2..<3), with: [String(format: "%.2f", Float(dataSteps.walking_duration+dataSteps.running_duration)/60)])
            self.calculationData((dataSteps.walking_duration+dataSteps.running_duration), steps: dataSteps.steps, completionData: { (miles, calories) in
                self.contentTArray.replaceRange(Range(0..<1), with: ["\(calories)"])
                self.contentTArray.replaceRange(Range(3..<4), with: ["\(miles)"])
            })
            self.stepsHistory.reloadData()
            //AppTheme.KeyedArchiverName(self.StepsGoalKey, andObject: self.contentTArray)
        }
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
        let cell:StepGoalSetingViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("StepGoalSetingIdentifier", forIndexPath: indexPath) as! StepGoalSetingViewCell
        cell.backgroundColor = UIColor.whiteColor()
        cell.titleLabel.text = contentTitleArray[indexPath.row]
        
        switch indexPath.row {
        case 0:
            cell.valueLabel.text = "\(contentTArray[indexPath.row]) Cal"
            break;
        case 1:
            cell.valueLabel.text = "\(contentTArray[indexPath.row])"
            break;
        case 2:
            cell.valueLabel.text = "\(contentTArray[indexPath.row]) H"
            break;
        case 3:
            cell.valueLabel.text = "\(contentTArray[indexPath.row]) KM"
            break;
        default:
            break;
        }
        
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
        //chartView.highlightValue(xIndex: entry.xIndex, dataSetIndex: dataSetIndex, callDelegate: false)
        //NSLog("chartValueSelected:  %d",entry.xIndex)
        //let stepsModel:UserSteps = queryModel.objectAtIndex(0) as! UserSteps;
        //self.didSelectedhighlightValue(entry.xIndex,dataSetIndex: dataSetIndex, dataSteps:stepsModel)

    }
    
    func didSelectedhighlightValue(xIndex:Int,dataSetIndex: Int, dataSteps:UserSteps) {
        
        self.contentTArray.replaceRange(Range(0..<1), with: ["\(dataSteps.calories)"])
        self.contentTArray.replaceRange(Range(1..<2), with: ["\(dataSteps.steps)"])
        self.contentTArray.replaceRange(Range(2..<3), with: ["\(dataSteps.walking_duration+dataSteps.running_duration)m"])
        self.calculationData(0, steps: dataSteps.steps, completionData: { (miles, calories) in
            self.contentTArray.replaceRange(Range(0..<1), with: ["\(calories)"])
            self.contentTArray.replaceRange(Range(3..<4), with: ["\(miles)"])
        })
        self.stepsHistory.reloadData()
    }
}

// MARK: - Data calculation
extension StepsHistoryViewController {
    
    func calculationData(activeTimer:Int,steps:Int,completionData:((miles:String,calories:String) -> Void)) {
        let profile:NSArray = UserProfile.getAll()
        var userProfile:UserProfile?
        var strideLength:Double = 0
        var userWeight:Double = 0
        if profile.count>0 {
            userProfile = profile.objectAtIndex(0) as? UserProfile
            strideLength = Double(userProfile!.length)*0.415/100
            userWeight = Double(userProfile!.weight)
        }else{
            strideLength = Double(170)*0.415/100
            userWeight = 65
        }
        
        let miles:Double = strideLength*Double(steps)/1000
        //Formula's = (2.0 X persons KG X 3.5)/200 = calories per minute
        let calories:Double = (2.0*userWeight*3.5)/200*Double(activeTimer)
        completionData(miles: String(format: "%.2f",miles), calories: String(format: "%.2f",calories))
    }
}