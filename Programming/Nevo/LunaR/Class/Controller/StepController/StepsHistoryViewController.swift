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
    private var contentTitleArray:[String] = [NSLocalizedString("goal", comment: ""), NSLocalizedString("progress", comment: ""), NSLocalizedString("you_reached", comment: "")]
    private var contentTArray:[String] = [NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: "")]
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
        
        stepsHistory.backgroundColor = UIColor.whiteColor()
        stepsHistory.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "StepsHistoryViewCell")
        (stepsHistory.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width/3.0, stepsHistory.frame.size.height)
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StepsHistoryViewCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        let labelheight:CGFloat = cell.contentView.frame.size.height
        let titleView = cell.contentView.viewWithTag(1500)
        let iphone:Bool = AppTheme.GET_IS_iPhone5S()
        if(titleView == nil){
            let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, cell.contentView.frame.size.width, labelheight/2.0))
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.textColor = UIColor.grayColor()
            titleLabel.backgroundColor = UIColor.clearColor()
            titleLabel.font = AppTheme.FONT_SFUIDISPLAY_REGULAR(mSize: iphone ? 12:15)
            titleLabel.tag = 1500
            titleLabel.text = contentTitleArray[indexPath.row]
            titleLabel.sizeToFit()
            cell.contentView.addSubview(titleLabel)
            titleLabel.center = CGPointMake(cell.contentView.frame.size.width/2.0, labelheight/2.0-titleLabel.frame.size.height)
        }else {
            let titleLabel:UILabel = titleView as! UILabel
            titleLabel.text = contentTitleArray[indexPath.row]
            titleLabel.sizeToFit()
            titleLabel.center = CGPointMake(cell.contentView.frame.size.width/2.0, labelheight/2.0-titleLabel.frame.size.height)
        }

        let contentView = cell.contentView.viewWithTag(1700)
        if(contentView == nil){
            let contentStepsView:UILabel = UILabel(frame: CGRectMake(0, labelheight/2.0, cell.contentView.frame.size.width, labelheight/2.0))
            contentStepsView.textAlignment = NSTextAlignment.Center
            contentStepsView.backgroundColor = UIColor.clearColor()
            contentStepsView.textColor = UIColor.blackColor()
            contentStepsView.font = AppTheme.FONT_SFUIDISPLAY_REGULAR(mSize: iphone ? 15:18)
            contentStepsView.tag = 1700
            contentStepsView.text = "\(contentTArray[indexPath.row])"
            contentStepsView.sizeToFit()
            cell.contentView.addSubview(contentStepsView)
            contentStepsView.center = CGPointMake(cell.contentView.frame.size.width/2.0,labelheight/2.0+contentStepsView.frame.size.height/2.0)
        }else {
            let contentStepsView:UILabel = contentView as! UILabel
            contentStepsView.text = "\(contentTArray[indexPath.row])"
            contentStepsView.sizeToFit()
            contentStepsView.center = CGPointMake(cell.contentView.frame.size.width/2.0, labelheight/2.0+contentStepsView.frame.size.height/2.0)
        }
        return cell
    }
    
    func bulidStepHistoricalChartView(modelArray:NSArray){
        queryModel.removeAllObjects()
        sleepArray.removeAllObjects()
        queryModel.addObjectsFromArray(modelArray as [AnyObject])
        // MARK: - chartView?.marker
        chartView?.descriptionText = " ";
        chartView?.noDataText = NSLocalizedString("no_step_data", comment: "")
        chartView?.noDataTextDescription = "";
        chartView?.pinchZoomEnabled = false
        chartView?.drawGridBackgroundEnabled = false;
        chartView?.drawBarShadowEnabled = false;
        let xScale:CGFloat = CGFloat(queryModel.count)/7.0;//integer/integer = integer,float/float = float
        chartView?.setScaleMinima(xScale, scaleY: 1)
        chartView?.setScaleEnabled(false);
        chartView!.drawValueAboveBarEnabled = true;
        chartView!.doubleTapToZoomEnabled = false;
        chartView!.setViewPortOffsets(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0)
        chartView!.delegate = self
        
        let leftAxis:ChartYAxis = chartView!.leftAxis;
        leftAxis.valueFormatter = NSNumberFormatter();
        leftAxis.drawAxisLineEnabled = false;
        leftAxis.drawGridLinesEnabled = false;
        leftAxis.enabled = false;
        leftAxis.spaceTop = 0.6;
        
        chartView!.rightAxis.enabled = false;
        
        let xAxis:ChartXAxis = chartView!.xAxis;
        xAxis.labelFont = UIFont.systemFontOfSize(8)
        xAxis.drawAxisLineEnabled = false;
        xAxis.drawGridLinesEnabled = false;
        xAxis.labelPosition = ChartXAxis.LabelPosition.BottomInside
        
        chartView!.legend.enabled = false;
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
        set1.colors = [AppTheme.getStepsColor()];
        set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
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
        contentTArray.insert("\(dataSteps.goalsteps)", atIndex: 0)
        contentTArray.insert(String(format: "%.2f%c", dataSteps.goalreach*100,37), atIndex: 1)
        contentTArray.insert("\(dataSteps.steps)", atIndex: 2)
        stepsHistory.reloadData()
    }
}
