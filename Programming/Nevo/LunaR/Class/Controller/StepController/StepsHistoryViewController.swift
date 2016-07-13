//
//  StepHistoricalViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import Charts

class StepsHistoryViewController: PublicClassController,UICollectionViewDelegateFlowLayout,ChartViewDelegate {

    @IBOutlet weak var stepsHistory: UICollectionView!
    @IBOutlet weak var nodataLabel: UILabel!
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
        queryArray = UserSteps.getAll()
        self.bulidStepHistoricalChartView(queryArray)
        
        stepsHistory.backgroundColor = UIColor(rgba: "#54575a")
        stepsHistory.registerNib(UINib(nibName: "StepGoalSetingViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "StepGoalSetingIdentifier")
        stepsHistory.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "StepsHistoryViewCell")
        (stepsHistory.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width/2.0, 40.0)
    }

    override func viewWillAppear(animated: Bool) {
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if(queryArray.count>0) {
            nodataLabel.hidden = true
        }else{
            nodataLabel.backgroundColor = UIColor.whiteColor()
            nodataLabel.hidden = false
            nodataLabel.text = NSLocalizedString("no_data", comment: "");
        }
        self.view.backgroundColor = UIColor(rgba: "#54575a")
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
        (cell as! StepGoalSetingViewCell).titleLabel.text = contentTitleArray[indexPath.row]
        (cell as! StepGoalSetingViewCell).valueLabel.text = "\(contentTArray[indexPath.row])"
        return cell
    }
    
    func bulidStepHistoricalChartView(modelArray:NSArray){
        queryModel.removeAllObjects()
        sleepArray.removeAllObjects()
        queryModel.addObjectsFromArray(modelArray as [AnyObject])
        
        // MARK: - chartView?.marker
        chartView.backgroundColor = UIColor(rgba: "#54575a")
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
        xAxis.labelTextColor = UIColor.grayColor()
        xAxis.axisLineColor = UIColor.grayColor()
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 7)!
        
        let yAxis:ChartYAxis = chartView!.leftAxis
        yAxis.labelTextColor = UIColor.grayColor()
        yAxis.axisLineColor = UIColor.grayColor()
        yAxis.drawAxisLineEnabled  = true
        yAxis.drawGridLinesEnabled  = true
        yAxis.drawLimitLinesBehindDataEnabled = true
        yAxis.axisMinValue = 0
        yAxis.setLabelCount(5, force: true)
        
        let rightAxis:ChartYAxis = chartView!.rightAxis
        rightAxis.labelTextColor = UIColor.clearColor()
        rightAxis.axisLineColor = UIColor.grayColor()
        rightAxis.drawAxisLineEnabled  = true
        rightAxis.drawGridLinesEnabled  = true
        rightAxis.drawLimitLinesBehindDataEnabled = true
        rightAxis.drawZeroLineEnabled = true
        
        chartView!.rightAxis.enabled = false
        chartView.drawBarShadowEnabled = false
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
            return
        }
        
        var xVal:[String] = [];
        var yVal:[BarChartDataEntry] = [];
        for i in 0 ..< queryModel.count{
            /**
             *  Data sorting,Small to large sort
             */
            for j in 0 ..< queryModel.count{
                let iStepsModel:UserSteps = queryModel.objectAtIndex(i) as! UserSteps;
                let jStepsModel:UserSteps = queryModel.objectAtIndex(j) as! UserSteps;
                let iStepsDate:Double = iStepsModel.date
                let jStepsDate:Double = jStepsModel.date
                if (iStepsDate > jStepsDate){
                    let temp:UserSteps = queryModel.objectAtIndex(i) as! UserSteps;
                    queryModel.replaceObjectAtIndex(i, withObject: queryModel[j])
                    queryModel.replaceObjectAtIndex(j, withObject: temp)
                    
                }
            }
        }
        
        for i in 0 ..< queryModel.count{
            let seleModel:UserSteps = queryModel.objectAtIndex(i) as! UserSteps;
            let val1:Double  = Double(seleModel.steps);
            let date:NSDate = NSDate(timeIntervalSince1970: seleModel.date)
            var dateString:NSString = date.stringFromFormat("yyyyMMdd")
            if(dateString.length < 8) {
                dateString = "00000000"
            }
            xVal.append("\(dateString.substringWithRange(NSMakeRange(6, 2)))/\(dateString.substringWithRange(NSMakeRange(4, 2)))")
            yVal.append(BarChartDataEntry(values: [val1], xIndex:i))
        }
        
        //柱状图表
        //ChartColorTemplates.getDeepSleepColor()
        let set1:BarChartDataSet  = BarChartDataSet(yVals: yVal, label: "")
        //每个数据区块的颜色
        set1.colors = [UIColor.getBaseColor()];
        set1.highlightColor = UIColor.getBaseColor()
        set1.barSpace = 0.05;
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
        let stepsModel:UserSteps = queryModel.objectAtIndex(entry.xIndex) as! UserSteps;
        self.didSelectedhighlightValue(entry.xIndex,dataSetIndex: dataSetIndex, dataSteps:stepsModel)
        let array:NSArray = NSArray(array: [entry.xIndex,dataSetIndex,stepsModel])
        AppTheme.KeyedArchiverName(SELECTED_DATA, andObject: array)
    }
    
    func didSelectedhighlightValue(xIndex:Int,dataSetIndex: Int, dataSteps:UserSteps) {
        contentTArray.removeAll()
        contentTArray.insert("\(dataSteps.calories)", atIndex: 0)
        contentTArray.insert("\(dataSteps.steps)", atIndex: 1)
        contentTArray.insert("\(dataSteps.inactivityTime)", atIndex: 2)
        //contentTArray.insert(String(format: "%.2f%c", dataSteps.goalreach*100,37), atIndex: 1)
        contentTArray.insert("\(dataSteps.walking_distance+dataSteps.running_distance)", atIndex: 3)
        stepsHistory.reloadData()
    }
}
