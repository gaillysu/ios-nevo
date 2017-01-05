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
 
import SwiftyJSON

class StepsHistoryViewController: PublicClassController,ChartViewDelegate {

    @IBOutlet weak var stepsHistory: UICollectionView!
    @IBOutlet weak var chartView: BarChartView!
    
    @IBOutlet weak var centerTitleLabel: UILabel!
    
    let SELECTED_DATA:String = "SELECTED_DATA"
    
    fileprivate var queryArray:NSArray = NSArray()
    fileprivate var contentTitleArray:[String] = [NSLocalizedString("CALORIE", comment: ""), NSLocalizedString("STEPS", comment: ""), NSLocalizedString("TIME", comment: ""),NSLocalizedString("KM", comment: "")]
    fileprivate var contentTArray:[String] = ["0","0","0","0"]
    fileprivate var queryModel:NSMutableArray = NSMutableArray()
    fileprivate let detailArray:NSMutableArray = NSMutableArray(capacity:1);
    
    init() {
        super.init(nibName: "StepsHistoryViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !AppTheme.isTargetLunaR_OR_Nevo(){
            centerTitleLabel.textColor = UIColor.white
        }
        
        self.configChartView()
        let dayDate:Date = Date()
        let dayTime:TimeInterval = Date.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
        self.bulidStepHistoricalChartView(dayTime)
        
        stepsHistory.backgroundColor = UIColor.white
        stepsHistory.register(UINib(nibName: "StepGoalSetingViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "StepGoalSetingIdentifier")
        stepsHistory.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "StepsHistoryViewCell")
        
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 0, height: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        stepsHistory.collectionViewLayout = layout
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let dayDate:Date = Date()
        let dayTime:TimeInterval = Date.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
        saveContentTArray(date: dayTime)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            let userinfo:Date = notification.userInfo!["selectedDate"] as! Date
            //self.queryArray = UserSteps.getCriteria("WHERE date = \(userinfo.beginningOfDay.timeIntervalSince1970)")
            self.saveContentTArray(date: userinfo.beginningOfDay.timeIntervalSince1970)
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
            self.saveContentTArray(date: Date().beginningOfDay.timeIntervalSince1970)
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
            self.view.backgroundColor = UIColor.getLightBaseColor()
            stepsHistory.backgroundColor = UIColor.getLightBaseColor()
            chartView.backgroundColor = UIColor.getLightBaseColor()
        }
        
        let layout:UICollectionViewFlowLayout = stepsHistory.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: (stepsHistory.frame.size.width)/2.0, height: stepsHistory.frame.size.height/2.0 - 10)
    }
    
    /**
     Archiver "contentTArray"
     */
    func saveContentTArray(date:TimeInterval) {
        //Only for today's data
        self.bulidStepHistoricalChartView(date)
        let queryArray = MEDUserSteps.getFilter("date = \(date)")
        if queryArray.count>0 {
            let dataSteps:MEDUserSteps = queryArray[0] as! MEDUserSteps
            let timerValue:Double = Double(dataSteps.walking_duration+dataSteps.running_duration)
            self.contentTArray.replaceSubrange(Range(0..<1), with: [String(format: "%.2f", dataSteps.totalCalories)])
            self.contentTArray.replaceSubrange(Range(1..<2), with: ["\(dataSteps.totalSteps)"])
            self.contentTArray.replaceSubrange(Range(2..<3), with: [AppTheme.timerFormatValue(value: timerValue/60.0)])
            DataCalculation.calculationData((dataSteps.walking_duration+dataSteps.running_duration), steps: dataSteps.totalSteps, completionData: { (miles, calories) in
                self.contentTArray.replaceSubrange(Range(0..<1), with: [String(format: "%.2f", fabs(calories))])
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
        
        let xAxis:XAxis = chartView!.xAxis
        xAxis.labelTextColor = UIColor.black
        xAxis.axisLineColor = UIColor.black
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.labelPosition = XAxis.LabelPosition.bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 10)!
        
        let yAxis:YAxis = chartView!.leftAxis
        yAxis.labelTextColor = UIColor.black
        yAxis.axisLineColor = UIColor.black
        yAxis.drawAxisLineEnabled  = true
        yAxis.drawGridLinesEnabled  = true
        yAxis.drawLimitLinesBehindDataEnabled = true
        yAxis.axisMaximum = 500;
        yAxis.axisMinimum = 0
        yAxis.setLabelCount(5, force: true)
        
        let rightAxis:YAxis = chartView!.rightAxis
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
    
    func bulidStepHistoricalChartView(_ date:TimeInterval){
        let queryArray = MEDUserSteps.getFilter("date = \(date)")
        self.setDataCount(queryArray)
    }

    
    func setDataCount(_ valueArray:[Any]){
        var stepsValue:[Any] = valueArray
        if(valueArray.count == 0) {
            let stepsModel:MEDUserSteps = MEDUserSteps()
            stepsModel.date = Date().timeIntervalSince1970
            stepsModel.createDate = Date().stringFromFormat("yyyyMMdd")
            stepsModel.hourlysteps = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
            stepsModel.hourlydistance = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
            stepsModel.hourlycalories = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
            stepsValue.append(stepsModel)
        }
        
        var yVal:[BarChartDataEntry] = [];
        
        var tempMaxValue:Double = 0;
        
        let stepsModel:MEDUserSteps = stepsValue[0] as! MEDUserSteps;
        let hourlystepsArray = JSON(AppTheme.jsonToArray(stepsModel.hourlysteps)).arrayValue
        
        let formatter:ChartFormatter = ChartFormatter()
        let xaxis:XAxis = XAxis()
        
        for (index,steps) in hourlystepsArray.enumerated(){
            let val1:Double  = steps.doubleValue;
            if tempMaxValue < val1 {
                tempMaxValue = val1
            }
            let date:Date = Date(timeIntervalSince1970: stepsModel.date)
            var dateString:NSString = date.stringFromFormat("yyyyMMdd") as NSString
            if(dateString.length < 8) {
                dateString = "00000000"
            }
            yVal.append(BarChartDataEntry(x: Double(index), yValues: [val1]))
            _ = formatter.stringForValue(Double(index), axis: xaxis)
        }
        
        xaxis.valueFormatter = formatter
        chartView?.xAxis.valueFormatter = xaxis.valueFormatter
        
        let steps:Int = 500
        let remaining = Double(steps - (Int(tempMaxValue) % steps))
        var maxValue = remaining + tempMaxValue
        var labelCount = Int(round(maxValue/Double(steps))) + 1
        if maxValue < 50 {
            maxValue += Double(steps)
            labelCount += 1
        }
        
        chartView!.leftAxis.setLabelCount(labelCount, force: true)
        chartView!.leftAxis.axisMaximum = maxValue
        
        //柱状图表
        let set1:BarChartDataSet  = BarChartDataSet(values: yVal, label: "")
        //每个数据区块的颜色
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            set1.colors = [UIColor.getBaseColor()];
            set1.highlightColor = UIColor.getBaseColor()
        }else{
            set1.colors = [AppTheme.NEVO_SOLAR_YELLOW()];
            set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
        
        set1.barBorderWidth = 0.1
        //set1.barSpace = 0.1;
        let dataSets:[BarChartDataSet] = [set1];
        
        let data:BarChartData = BarChartData(dataSets: dataSets)
        data.setDrawValues(false);//false 显示柱状图数值否则不显示
        chartView?.data = data;
        chartView?.animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCirc)
        chartView?.moveViewToX(Double(yVal.count))
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        //chartView.highlightValue(xIndex: entry.xIndex, dataSetIndex: dataSetIndex, callDelegate: false)
        //NSLog("chartValueSelected:  %d",entry.xIndex)
        //let stepsModel:UserSteps = queryModel.objectAtIndex(0) as! UserSteps;
        //self.didSelectedhighlightValue(entry.xIndex,dataSetIndex: dataSetIndex, dataSteps:stepsModel)

    }
}

extension StepsHistoryViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
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
            cell.backgroundColor = UIColor.getLightBaseColor()
            cell.valueLabel.textColor = UIColor.getBaseColor()
            cell.titleLabel.textColor = UIColor.white
        }
        
        switch indexPath.row {
        case 0:
            cell.valueLabel.text = "\(contentTArray[indexPath.row]) Cal"
            break;
        case 1:
            cell.valueLabel.text = "\(contentTArray[indexPath.row])"
            break;
        case 2:
            cell.valueLabel.text = "\(contentTArray[indexPath.row])"
            break;
        case 3:
            var unit:String = "KM"
            var unitValue:Double = "\(contentTArray[indexPath.row])".toDouble()
            if AppTheme.getUserSelectedUnitValue() == 1 {
                unit = "Mi"
                unitValue = unitValue*kmToMi
            }
            cell.valueLabel.text = "\(unitValue.to2Double()) \(unit)"
            break;
        default:
            break;
        }
        
        return cell
    }
}
