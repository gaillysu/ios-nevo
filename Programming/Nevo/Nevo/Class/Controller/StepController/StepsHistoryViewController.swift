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

class StepsHistoryViewController: PublicClassController,ChartViewDelegate {

    @IBOutlet weak var stepsHistory: UICollectionView!
    @IBOutlet weak var chartView: BarChartView!
    
    let SELECTED_DATA:String = "SELECTED_DATA"
    
    fileprivate var queryArray:NSArray = NSArray()
    fileprivate var contentTitleArray:[String] = [NSLocalizedString("CALORIE", comment: ""), NSLocalizedString("STEPS", comment: ""), NSLocalizedString("TIME", comment: ""),NSLocalizedString("KM", comment: "")]
    fileprivate var contentTArray:[String] = ["0","0","0","0"]
    fileprivate var queryModel:NSMutableArray = NSMutableArray()
    fileprivate let sleepArray:NSMutableArray = NSMutableArray();
    fileprivate let detailArray:NSMutableArray = NSMutableArray(capacity:1);
    
    init() {
        super.init(nibName: "StepsHistoryViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configChartView()
        
        let dayDate:Date = Date()
        let dayTime:TimeInterval = Date.date(dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
            //NSDate().beginningOfDay.timeIntervalSince1970
        queryArray = UserSteps.getCriteria("WHERE date = \(dayTime)") //one hour = 3600s
        self.bulidStepHistoricalChartView(queryArray)
        
        stepsHistory.backgroundColor = UIColor.white
        stepsHistory.register(UINib(nibName: "StepGoalSetingViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "StepGoalSetingIdentifier")
        stepsHistory.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "StepsHistoryViewCell")
        (stepsHistory.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: UIScreen.main.bounds.size.width/2.0, height: 40.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveContentTArray()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            let userinfo:Date = notification.userInfo!["selectedDate"] as! Date
            self.queryArray = UserSteps.getCriteria("WHERE date = \(userinfo.beginningOfDay.timeIntervalSince1970)")
            self.bulidStepHistoricalChartView(self.queryArray)
        }
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY) { (notification) in
            let dict:[String:AnyObject] = notification.object as! [String:AnyObject]
            let dailySteps:Int = dict["STEPS"] as! Int
            /*
            self.calculationData(0, steps: dailySteps, completionData: { (miles, calories) in
                self.contentTArray.replaceSubrange(Range(3..<4), with: ["\(miles)"])
            })
             */
            //self.stepsHistory.reloadData()
        }
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            self.saveContentTArray()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self, name: SELECTED_CALENDAR_NOTIFICATION)
        SwiftEventBus.unregister(self, name: EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY)
        SwiftEventBus.unregister(self, name: EVENT_BUS_BEGIN_BIG_SYNCACTIVITY)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !AppTheme.isTargetLunaR_OR_Nevo(){
            self.view.backgroundColor = UIColor.getGreyColor()
            stepsHistory.backgroundColor = UIColor.getGreyColor()
            chartView.backgroundColor = UIColor.getGreyColor()
        }
    }
    
    /**
     Archiver "contentTArray"
     */
    func saveContentTArray() {
        //Only for today's data
        let array:NSArray = UserSteps.getCriteria("WHERE date = \(Date().beginningOfDay.timeIntervalSince1970)")
        self.queryArray = array
        self.bulidStepHistoricalChartView(array)
        
        if array.count>0 {
            let dataSteps:UserSteps = array[0] as! UserSteps
            
            self.contentTArray.replaceSubrange(Range(0..<1), with: ["\(dataSteps.calories)"])
            self.contentTArray.replaceSubrange(Range(1..<2), with: ["\(dataSteps.steps)"])
            self.contentTArray.replaceSubrange(Range(2..<3), with: [String(format: "%.2f", Float(dataSteps.walking_duration+dataSteps.running_duration)/60)])
            self.calculationData((dataSteps.walking_duration+dataSteps.running_duration), steps: dataSteps.steps, completionData: { (miles, calories) in
                self.contentTArray.replaceSubrange(Range(0..<1), with: ["\(calories)"])
                self.contentTArray.replaceSubrange(Range(3..<4), with: ["\(miles)"])
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
        xAxis.labelTextColor = UIColor.black
        xAxis.axisLineColor = UIColor.black
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.labelPosition = ChartXAxis.LabelPosition.bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 7)!
        
        let yAxis:ChartYAxis = chartView!.leftAxis
        yAxis.labelTextColor = UIColor.black
        yAxis.axisLineColor = UIColor.black
        yAxis.drawAxisLineEnabled  = true
        yAxis.drawGridLinesEnabled  = true
        yAxis.drawLimitLinesBehindDataEnabled = true
        yAxis.axisMaxValue = 500;
        yAxis.axisMinValue = 0
        yAxis.setLabelCount(5, force: true)
        
        let rightAxis:ChartYAxis = chartView!.rightAxis
        rightAxis.labelTextColor = UIColor.clear
        rightAxis.axisLineColor = UIColor.black
        rightAxis.drawAxisLineEnabled  = true
        rightAxis.drawGridLinesEnabled  = true
        rightAxis.drawLimitLinesBehindDataEnabled = true
        rightAxis.drawZeroLineEnabled = true
        
        chartView!.rightAxis.enabled = false
        chartView.drawBarShadowEnabled = false
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            xAxis.labelTextColor = UIColor.white
            xAxis.axisLineColor = UIColor.white
            
            yAxis.labelTextColor = UIColor.white
            yAxis.axisLineColor = UIColor.white
            rightAxis.axisLineColor = UIColor.white
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bulidStepHistoricalChartView(_ modelArray:NSArray){
        queryModel.removeAllObjects()
        sleepArray.removeAllObjects()
        queryModel.addObjects(from: modelArray as [AnyObject])
        self.slidersValueChanged()
    }
    
    func slidersValueChanged(){
        self.setDataCount(queryModel.count, Range: 50)
    }

    func stringFromDate(_ date:Date) -> String {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString:String = dateFormatter.string(from: date)
        return dateString
    }
    
    func setDataCount(_ count:Int, Range range:Double){
        if(count == 0) {
            let stepsModel:UserSteps = UserSteps()
            stepsModel.date = Date().timeIntervalSince1970
            stepsModel.createDate = Date().stringFromFormat("yyyyMMdd")
            stepsModel.hourlysteps = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
            stepsModel.hourlydistance = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
            stepsModel.hourlycalories = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
            queryModel.add(stepsModel)
        }
        
        var xVal:[String] = [];
        var yVal:[BarChartDataEntry] = [];
        
        var maxValue:Double = 0;
        
        let stepsModel:UserSteps = queryModel.object(at: 0) as! UserSteps;
        let hourlystepsArray:NSArray = AppTheme.jsonToArray(stepsModel.hourlysteps)
        for (index,steps) in hourlystepsArray.enumerated(){
            let val1:Double  = (steps as! NSNumber).doubleValue;
            let date:Date = Date(timeIntervalSince1970: stepsModel.date)
            var dateString:NSString = date.stringFromFormat("yyyyMMdd") as NSString
            if(dateString.length < 8) {
                dateString = "00000000"
            }
            xVal.append("\(index):00")
            yVal.append(BarChartDataEntry(values: [val1], xIndex:index))
            
            if val1>500 {
                if val1>maxValue{
                    maxValue = val1
                    chartView!.leftAxis.axisMaxValue = val1+100
                }
            }
        }
        
        //柱状图表
        //ChartColorTemplates.getDeepSleepColor()
        let set1:BarChartDataSet  = BarChartDataSet(yVals: yVal, label: "")
        //每个数据区块的颜色
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            set1.colors = [UIColor.getBaseColor()];
            set1.highlightColor = UIColor.getBaseColor()
        }else{
            set1.colors = [AppTheme.NEVO_SOLAR_YELLOW()];
            set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
        
        set1.barSpace = 0.1;
        let dataSets:[BarChartDataSet] = [set1];
        
        let data:BarChartData = BarChartData(xVals: xVal, dataSets: dataSets)
        data.setDrawValues(false);//false 显示柱状图数值否则不显示
        chartView?.data = data;
        chartView?.animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCirc)
        chartView?.moveViewToX(CGFloat(yVal.count))
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        //chartView.highlightValue(xIndex: entry.xIndex, dataSetIndex: dataSetIndex, callDelegate: false)
        //NSLog("chartValueSelected:  %d",entry.xIndex)
        //let stepsModel:UserSteps = queryModel.objectAtIndex(0) as! UserSteps;
        //self.didSelectedhighlightValue(entry.xIndex,dataSetIndex: dataSetIndex, dataSteps:stepsModel)

    }
    
    func didSelectedhighlightValue(_ xIndex:Int,dataSetIndex: Int, dataSteps:UserSteps) {
        
        self.contentTArray.replaceSubrange(Range(0..<1), with: ["\(dataSteps.calories)"])
        self.contentTArray.replaceSubrange(Range(1..<2), with: ["\(dataSteps.steps)"])
        self.contentTArray.replaceSubrange(Range(2..<3), with: ["\(dataSteps.walking_duration+dataSteps.running_duration)m"])
        self.calculationData(0, steps: dataSteps.steps, completionData: { (miles, calories) in
            self.contentTArray.replaceSubrange(Range(0..<1), with: ["\(calories)"])
            self.contentTArray.replaceSubrange(Range(3..<4), with: ["\(miles)"])
        })
        self.stepsHistory.reloadData()
    }
}

// MARK: - Data calculation
extension StepsHistoryViewController {
    
    func calculationData(_ activeTimer:Int,steps:Int,completionData:((_ miles:String,_ calories:String) -> Void)) {
        let profile:NSArray = UserProfile.getAll()
        var userProfile:UserProfile?
        var strideLength:Double = 0
        var userWeight:Double = 0
        if profile.count>0 {
            userProfile = profile.object(at: 0) as? UserProfile
            strideLength = Double(userProfile!.length)*0.415/100
            userWeight = Double(userProfile!.weight)
        }else{
            strideLength = Double(170)*0.415/100
            userWeight = 65
        }
        
        let miles:Double = strideLength*Double(steps)/1000
        //Formula's = (2.0 X persons KG X 3.5)/200 = calories per minute
        let calories:Double = (2.0*userWeight*3.5)/200*Double(activeTimer)
        completionData(String(format: "%.2f",miles), String(format: "%.2f",calories))
    }
}

extension StepsHistoryViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: (UIScreen.main.bounds.size.width)/2.0, height: collectionView.frame.size.height/2 - 10)
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:StepGoalSetingViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StepGoalSetingIdentifier", for: indexPath) as! StepGoalSetingViewCell
        cell.backgroundColor = UIColor.white
        let titleString:String = contentTitleArray[(indexPath as NSIndexPath).row]
        cell.titleLabel.text = titleString.capitalized(with: Locale.current)
        if !AppTheme.isTargetLunaR_OR_Nevo(){
            cell.backgroundColor = UIColor.getGreyColor()
            cell.valueLabel.textColor = UIColor.getBaseColor()
            cell.titleLabel.textColor = UIColor.white
        }
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            cell.valueLabel.text = "\(contentTArray[(indexPath as NSIndexPath).row]) Cal"
            break;
        case 1:
            cell.valueLabel.text = "\(contentTArray[(indexPath as NSIndexPath).row])"
            break;
        case 2:
            cell.valueLabel.text = "\(contentTArray[(indexPath as NSIndexPath).row]) H"
            break;
        case 3:
            cell.valueLabel.text = "\(contentTArray[(indexPath as NSIndexPath).row]) KM"
            break;
        default:
            break;
        }
        
        return cell
    }
}
