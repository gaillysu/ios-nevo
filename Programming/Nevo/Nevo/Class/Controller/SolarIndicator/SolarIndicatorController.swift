//
//  SolarIndicatorController.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/1.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Charts
import SwiftEventBus
import XCGLogger
import RealmSwift
 

class SolarIndicatorController: PublicClassController {

    @IBOutlet weak var textCollection: UICollectionView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate let realm:Realm = try! Realm()
    
    fileprivate var onTitle:[String] = [NSLocalizedString("timer_on_battery", comment: ""),NSLocalizedString("timer_on_solar", comment: "")]
    fileprivate var onValue:[Double] = [00,00]
    fileprivate var selectedDate:Date = Date()
    
    init() {
        super.init(nibName: "SolarIndicatorController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textCollection.register(UINib(nibName: "SolarInforViewCell",bundle: nil), forCellWithReuseIdentifier: "SolarInfor_Identifier")
        textCollection.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "viewForSupplementaryReuseID")
        
        self.setupPieChartView(pieChartView)
        pieChartView.legend.enabled = false;
        pieChartView.delegate = self
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 0, height: 0)
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSize.init(width: 0, height: 0)
        textCollection.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        textCollection.backgroundColor = UIColor.white
        pieChartView.backgroundColor = UIColor.white
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            self.selectedDate = Date()
            self.updateChartData(date:Date())
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            let userinfo:Date = notification.userInfo!["selectedDate"] as! Date
            self.selectedDate = userinfo
            self.updateChartData(date:userinfo)
        }
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SwiftEventBus.unregister(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY)
        SwiftEventBus.unregister(self, name: SELECTED_CALENDAR_NOTIFICATION)
        SwiftEventBus.unregister(self, name: EVENT_BUS_RAWPACKET_DATA_KEY)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.updateChartData(date:Date())
        pieChartView.animate(xAxisDuration: 1.4, easingOption: ChartEasingOption.easeOutBack)
        textCollection.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout:UICollectionViewFlowLayout = textCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: textCollection.frame.width/2.0, height: textCollection.frame.size.height / 2)
    }

}

extension SolarIndicatorController{

    func getSolarData(date:Date)->[SolarHarvest] {
        
        let solar = realm.objects(SolarHarvest.self).filter("date = \(date.beginningOfDay.timeIntervalSince1970)")
        var solarData:[SolarHarvest] = []
        for value in solar {
            solarData.append(value as SolarHarvest)
        }
        return solarData
    }
}

// MARK: - UICollectionViewDataSource
extension SolarIndicatorController:UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SolarInfor_Identifier", for: indexPath)
        cell.backgroundColor = UIColor.white
        (cell as! SolarInforViewCell).updateTitleLabel(onTitle[(indexPath as NSIndexPath).row])
        (cell as! SolarInforViewCell).valueLabel.text = onValue[indexPath.row].timerFormatValue()
        
        return cell
    }
}

// MARK: - ChartViewDelegate
extension SolarIndicatorController:ChartViewDelegate {
    func updateChartData(date:Date) {
        pieChartView.data = nil
        var solarValue = self.getSolarData(date:date)
        if solarValue.count>0 {
            self.setDataCount(solarValue)
        }else{
            let solar:SolarHarvest = SolarHarvest()
            solar.date = Date().beginningOfDay.timeIntervalSince1970
            solar.solarTotalTime = 0
            solar.solarHourlyTime = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
            solarValue.append(solar)
            self.setDataCount(solarValue)
        }
    }

    func setupPieChartView(_ chartView:PieChartView) {
        chartView.descriptionTextColor = UIColor.white
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.0
        chartView.transparentCircleRadiusPercent = 0.0
        chartView.descriptionText = ""
        chartView.setExtraOffsets(left: 0, top: 0, right: 0, bottom: 0)
        chartView.drawCenterTextEnabled = true
        let paragraphStyle:NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        paragraphStyle.alignment = NSTextAlignment.center
        let centerText:NSMutableAttributedString = NSMutableAttributedString(string: "Charts\nby Daniel Cohen Gindi")
        
        centerText.setAttributes([NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 13.0)!], range: NSMakeRange(0, centerText.length))
        centerText.addAttributes([NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 11.0)!,NSForegroundColorAttributeName:UIColor.gray], range: NSMakeRange(10, centerText.length - 10))
        centerText.addAttributes([NSFontAttributeName:UIFont(name: "HelveticaNeue-LightItalic", size: 11.0)!,NSForegroundColorAttributeName:UIColor(red: 51.0/255.0, green: 181.0/255.0, blue: 229.0/255.0, alpha: 1.0)], range: NSMakeRange(centerText.length - 19, 19))
        //let marker:BalloonMarker = BalloonMarker(color: UIColor.baseColor, font: UIFont(name: "Helvetica-Light", size: 11)!, insets: UIEdgeInsetsMake(8.0, 8.0, 15.0, 8.0))
        //marker.minimumSize = CGSizeMake(60, 25);
        //chartView.marker = marker
        chartView.centerAttributedText = centerText
        chartView.drawCenterTextEnabled = false
        chartView.drawHoleEnabled = true;
        chartView.rotationAngle = 0.0;
        chartView.rotationEnabled = true;
        chartView.highlightPerTapEnabled = true;
        
        let l:Legend = chartView.legend;
        l.position = Legend.Position.rightOfChart;
        l.xEntrySpace = 7.0;
        l.yEntrySpace = 0.0;
        l.yOffset = 0.0;
        
    }
    
    func setDataCount(_ solarValue:[SolarHarvest]) {
        var yVals1:[ChartDataEntry] = []
        
        let solarData:SolarHarvest = solarValue[0]
        let value:Double = Double(solarData.solarTotalTime)/60.0
        
        /*
         Time On Battery = Time Of Today (18:00 -> 1080min) - TotalHarvestingTime (200) = 880 -> 14 hours and 40 minutes
         Time On Solar = Total Harvesting Time (200) -> 3 hours and 20
         */
        let mDay:Date = Date()
        var todayDate:Double = 0.0
        if selectedDate.day == mDay.day {
            todayDate = Double(mDay.hour)+Double(mDay.minute)/60.0
        }else{
            todayDate = 24.0
        }
        
        yVals1.append(BarChartDataEntry(x: 0, y: value))
        yVals1.append(BarChartDataEntry(x: 1, y: todayDate-value))
        
        onValue.replaceSubrange(0..<1, with: [todayDate-value])
        onValue.replaceSubrange(1..<2, with: [value])
        textCollection.reloadData();
        
        var xVals:[String] = []
        xVals.append(NSLocalizedString("Solar", comment: ""))
        xVals.append(NSLocalizedString("Battery", comment: ""))
        
        let dataSet:PieChartDataSet = PieChartDataSet(values: yVals1, label: "")
        dataSet.sliceSpace = 2.0;
        var colors:[UIColor] = [UIColor.baseColor,UIColor.nevoGray];
        dataSet.colors = colors
        
        let pFormatter:NumberFormatter = NumberFormatter()
        pFormatter.numberStyle = NumberFormatter.Style.percent;
        pFormatter.maximumFractionDigits = 1;
        pFormatter.multiplier = 1.0;
        pFormatter.percentSymbol = " %";
        
        let data:PieChartData = PieChartData(dataSets: [dataSet])
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 16.0))
        data.setValueTextColor(UIColor.white)
        pieChartView.data = data;
        pieChartView.highlightValues(nil)
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
    
    }
}
