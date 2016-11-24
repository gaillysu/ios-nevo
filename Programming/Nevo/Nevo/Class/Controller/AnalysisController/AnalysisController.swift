//
//  SleepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftEventBus
import SnapKit

class AnalysisController: PublicClassController {
    
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var chartsCollectionView: UICollectionView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    let titleArray:[String] = [NSLocalizedString("this_week", comment: ""),NSLocalizedString("last_week", comment: ""),NSLocalizedString("last_30_day", comment: "")]
    fileprivate var contentTitleArray:[String] = [NSLocalizedString("average_steps", comment: ""), NSLocalizedString("total_steps", comment: ""), NSLocalizedString("average_calories", comment: ""),NSLocalizedString("average_time", comment: "")]
    fileprivate var contentTArray:[String] = [NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: "")]
    fileprivate var dataArray:NSMutableArray = NSMutableArray(capacity:3)
    fileprivate let realm:Realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.allSubviews(do: { (v) in
            v.isHidden = v.frame.height == 0.5
        })
        
        let dict:[String : AnyObject] = [NSForegroundColorAttributeName:UIColor.white]
        segmented.setTitleTextAttributes(dict, for: UIControlState.selected)
        
        contentCollectionView.backgroundColor = UIColor.white
        chartsCollectionView.backgroundColor = UIColor.clear
        chartsCollectionView.bounces = false;
        chartsCollectionView.register(UINib(nibName: "AnalysisRadarViewCell",bundle: nil), forCellWithReuseIdentifier: "AnalysisRadar_Identifier")
        chartsCollectionView.register(UINib(nibName: "AnalysisLineChartCell",bundle: nil), forCellWithReuseIdentifier: "AnalysisLineChart_Identifier")
        chartsCollectionView.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ChartsViewHeader_Identifier")
        contentCollectionView.register(UINib(nibName: "AnalysisValueCell",bundle: nil), forCellWithReuseIdentifier: "AnalysisValue_Identifier")
        dataArray.addObjects(from: self.getStepsData())
        
        if UserDefaults.standard.object(forKey: "WATCHNAME_KEY") != nil {
            let value:Int = UserDefaults.standard.object(forKey: "WATCHNAME_KEY") as! Int
            if value>1{
                segmented.insertSegment(withTitle: NSLocalizedString("Solar", comment: ""), at: segmented.numberOfSegments, animated: false)
            }
        }
        
        let segmentDeviderView: UIView = UIView()
        segmented.addSubview(segmentDeviderView)
        segmentDeviderView.snp.makeConstraints { (v) in
            v.width.equalTo(UIScreen.main.bounds.width)
            v.height.equalTo(0.3)
            v.centerX.equalToSuperview()
            v.top.equalTo(segmented.snp.bottom).offset(10)
        }
        
        let segmentedBackgroundView: UIView = UIView()
        self.view.insertSubview(segmentedBackgroundView, at: 0)
        segmentedBackgroundView.snp.makeConstraints { (v) in
            v.width.equalToSuperview()
            v.left.equalToSuperview()
            v.top.equalToSuperview()
            v.bottom.equalTo(segmentDeviderView.snp.top)
        }
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            contentCollectionView.backgroundColor = UIColor.getGreyColor()
            chartsCollectionView.backgroundColor = UIColor.getGreyColor()
            segmented.tintColor = UIColor.getBaseColor()
            segmentDeviderView.backgroundColor = UIColor.black
            
            segmented.backgroundColor = UIColor.getLunarTabBarColor()
            segmentedBackgroundView.backgroundColor = UIColor.getLunarTabBarColor()
        } else {
            segmented.backgroundColor = UIColor.getNevoTabBarColor()
            segmentedBackgroundView.backgroundColor = UIColor.getNevoTabBarColor()
            
            segmentDeviderView.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
        
        let chartLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        chartLayout.itemSize = CGSize(width: 0, height: 0)
        
        chartLayout.minimumInteritemSpacing = 0
        chartLayout.minimumLineSpacing = 0
        chartLayout.scrollDirection = .horizontal
        chartsCollectionView.collectionViewLayout = chartLayout
        
        let contentLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        contentLayout.itemSize = CGSize(width: 0, height: 0)
        
        contentLayout.minimumInteritemSpacing = 0
        contentLayout.minimumLineSpacing = 0
        contentCollectionView.collectionViewLayout = contentLayout
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.bulidPageControl()
        
        let chartLayout:UICollectionViewFlowLayout = chartsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        chartLayout.itemSize = CGSize(width: chartsCollectionView.frame.size.width, height: chartsCollectionView.frame.size.height)
        
        let height: CGFloat = (segmented.selectedSegmentIndex == 2) ? (contentCollectionView.frame.size.height - 20) : (contentCollectionView.frame.size.height/2.0 - 10)
        
        let contentLayout:UICollectionViewFlowLayout = contentCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        contentLayout.itemSize = CGSize(width: contentCollectionView.frame.size.width/2.0, height: height)
    }
}

extension AnalysisController {
    func bulidPageControl() {
        if self.view.viewWithTag(1900) != nil {
            return
        }
        let pageControl = UIPageControl(frame: CGRect(x: 100, y: UIScreen.main.bounds.size.height-44, width: 100, height: 20))
        pageControl.tag = 1900
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = AppTheme.NEVO_SOLAR_YELLOW()
        pageControl.addTarget(self, action: #selector(pageAction(_ :)), for: UIControlEvents.valueChanged)
        
        pageControl.isUserInteractionEnabled = false
        
        self.view.addSubview(pageControl)
        
        pageControl.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
        }
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            pageControl.currentPageIndicatorTintColor = UIColor.getBaseColor()
        }else{
            pageControl.currentPageIndicatorTintColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
    }
    
    func setCurrentPageIndex(_ index:Int) {
        for view in self.view.subviews {
            if view is  UIPageControl{
                let page:UIPageControl = view as! UIPageControl
                page.currentPage = index
                page.size(forNumberOfPages: index)
                break
            }
        }
    }
    
    func pageAction(_ pageControl: UIPageControl) {
        print("currentPage is \(pageControl.currentPage)")
    }
}

extension AnalysisController {
    @IBAction func segmentedAction(_ sender: AnyObject) {
        let segment:UISegmentedControl = sender as! UISegmentedControl
        refreshViewLayout()
        dataArray.removeAllObjects()
        if segment.selectedSegmentIndex == 0 {
            dataArray.addObjects(from: self.getStepsData())
            chartsCollectionView.reloadData()
        }else if segment.selectedSegmentIndex == 1 {
            dataArray.addObjects(from: self.getSleepData())
            chartsCollectionView.reloadData()
        }else{
            dataArray.addObjects(from: self.getSolarData())
            chartsCollectionView.reloadData()
        }
    }
    
    /*
     Get steps data
     */
    func getStepsData()->[NSArray] {
        let dayDate:Date = Date()
        let thisWeekArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970) AND \(dayDate.endOfWeek.timeIntervalSince1970)")
        let lastWeekArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.endOfDay.timeIntervalSince1970-(86400.0*7)) AND \(dayDate.beginningOfDay.timeIntervalSince1970+1)")
        let last30DayArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.endOfDay.timeIntervalSince1970-(86400.0*30)) AND \(dayDate.beginningOfDay.timeIntervalSince1970+1)")
        return [thisWeekArray,lastWeekArray,last30DayArray]
    }
    
    /*
     Get sleep data
     */
    func getSleepData()->[NSArray] {
        let nextDay:Double = 86401
        
        let dayDate:Date = Date()
        let thisWeekArray:NSArray = UserSleep.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-nextDay) AND \(dayDate.endOfWeek.timeIntervalSince1970+nextDay)")
        let lastWeekArray:NSArray = UserSleep.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfDay.timeIntervalSince1970-(86400.0*7)-nextDay) AND \(dayDate.endOfDay.timeIntervalSince1970+nextDay)")
        let last30DayArray:NSArray = UserSleep.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfDay.timeIntervalSince1970-(86400.0*30)-nextDay) AND \(dayDate.endOfDay.timeIntervalSince1970+nextDay)")
        return [thisWeekArray,lastWeekArray,last30DayArray]
    }
    
    func getSolarData()->[[SolarHarvest]] {
        let dayDate:Date = Date()
        let thisWeekSolar = realm.objects(SolarHarvest.self).filter("date > \(dayDate.beginningOfWeek.timeIntervalSince1970-1) AND date < \(dayDate.endOfWeek.timeIntervalSince1970)")
        var thisWeekData:[SolarHarvest] = []
        for value in thisWeekSolar {
            thisWeekData.append(value as SolarHarvest)
        }

        let lastWeekSolar = realm.objects(SolarHarvest.self).filter("date > \(dayDate.beginningOfWeek.timeIntervalSince1970-(86400.0*7)-1) AND date < \(dayDate.beginningOfWeek.timeIntervalSince1970)")
        var lastWeekData:[SolarHarvest] = []
        for value in lastWeekSolar {
            lastWeekData.append(value as SolarHarvest)
        }
        
        let last30DaySolar = realm.objects(SolarHarvest.self).filter("date > \(dayDate.beginningOfDay.timeIntervalSince1970-(86400.0*30)) AND date < \(dayDate.endOfDay.timeIntervalSince1970)")
        var last30DayData:[SolarHarvest] = []
        for value in last30DaySolar {
            last30DayData.append(value as SolarHarvest)
        }
        
        return [thisWeekData,lastWeekData,last30DayData]
    }
    
}

extension AnalysisController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.isEqual(chartsCollectionView){
            return titleArray.count
        }else{
            return contentTitleArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        refreshViewLayout()
        if collectionView.isEqual(chartsCollectionView) {
            let cell:AnalysisLineChartCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnalysisLineChart_Identifier", for: indexPath) as! AnalysisLineChartCell
            cell.backgroundColor = UIColor.clear
            cell.setTitle(titleArray[indexPath.row])
            return cell
        }else{
            let cell:AnalysisValueCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnalysisValue_Identifier", for: indexPath) as! AnalysisValueCell
            cell.backgroundColor = UIColor.clear
            cell.updateTitleLabel(contentTitleArray[(indexPath as NSIndexPath).row])
            cell.updateLabel(contentTArray[(indexPath as NSIndexPath).row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        if collectionView.isEqual(chartsCollectionView) {
            print("indexPath===\(indexPath.row)")
            let analysisCell:AnalysisLineChartCell = cell as! AnalysisLineChartCell
            if segmented.selectedSegmentIndex == 0 {
                contentTitleArray = [
                    NSLocalizedString("average_steps", comment: ""),
                    NSLocalizedString("total_steps", comment: ""),
                    NSLocalizedString("average_calories", comment: ""),
                    NSLocalizedString("average_time", comment: "")]
            }
            if segmented.selectedSegmentIndex == 1 {
                contentTitleArray = [
                    NSLocalizedString("average_sleep", comment: ""),
                    NSLocalizedString("total_sleep", comment: ""),
                    NSLocalizedString("average_wake", comment: ""),
                    NSLocalizedString("Quality", comment: "")]
            }
            
            if segmented.selectedSegmentIndex == 2 {
                contentTitleArray = [
                    NSLocalizedString("timer_on_battery", comment: ""),
                    NSLocalizedString("timer_on_solar", comment: "")]
            }
            
            if segmented.selectedSegmentIndex != 2 {
                var avgNumber:Float = 0
                if (indexPath as NSIndexPath).row == 0 || (indexPath as NSIndexPath).row == 1 {
                    avgNumber = 7
                }else{
                    avgNumber = 30
                }
                
                analysisCell.updateChartData(dataArray[indexPath.row] as! NSArray, chartType: segmented.selectedSegmentIndex,rowIndex:indexPath.row, completionData: { (totalValue, totalCalores, totalTime) in
                    var stepsOrSleepValue1:String = ""
                    if segmented.selectedSegmentIndex == 0 {
                        stepsOrSleepValue1 = String(format: "%.0f",totalValue/avgNumber)
                        self.contentTArray.replaceSubrange(Range(0..<1), with: [stepsOrSleepValue1])
                        self.contentTArray.replaceSubrange(Range(1..<2), with: [String(format: "%.0f",totalValue)])
                        self.contentTArray.replaceSubrange(Range(2..<3), with: [String(format: "%.0f",Float(totalCalores)/Float(avgNumber))])
                        self.contentTArray.replaceSubrange(Range(3..<4), with: [AppTheme.timerFormatValue(value: Double(totalTime)/Double(avgNumber))])
                    }else{
                        stepsOrSleepValue1 = AppTheme.timerFormatValue(value: Double(totalValue/avgNumber))
                        self.contentTArray.replaceSubrange(Range(0..<1), with: [stepsOrSleepValue1])
                        self.contentTArray.replaceSubrange(Range(1..<2), with: [AppTheme.timerFormatValue(value: Double(totalValue))])
                        self.contentTArray.replaceSubrange(Range(2..<3), with: [AppTheme.timerFormatValue(value: Double(totalCalores)/Double(avgNumber))])
                        self.contentTArray.replaceSubrange(Range(3..<4), with: [String(format: "%.0f%c",totalTime,37)])
                    }
                    
                });
                
            }else{
                self.contentTArray.replaceSubrange(Range(0..<1), with: [String(format: "0")])
                self.contentTArray.replaceSubrange(Range(1..<2), with: [String(format: "0")])
                
                var avgNumber:Float = 0
                if (indexPath as NSIndexPath).row == 0 || (indexPath as NSIndexPath).row == 1 {
                    avgNumber = 7
                }else{
                    avgNumber = 30
                }

                analysisCell.updateChartData(dataArray[indexPath.row] as! NSArray, chartType: segmented.selectedSegmentIndex,rowIndex:indexPath.row, completionData: { (totalValue, totalCalores, totalTime) in
                    self.contentTArray.replaceSubrange(Range(0..<1), with: [AppTheme.timerFormatValue(value: Double((24.0*avgNumber)-totalValue))])
                    self.contentTArray.replaceSubrange(Range(1..<2), with: [AppTheme.timerFormatValue(value: Double(totalValue))])
                });
            }
            setCurrentPageIndex(indexPath.row)
            contentCollectionView.reloadData()
        }
    }
}

// MARK: - Private function
extension AnalysisController {
    fileprivate func refreshViewLayout() {
        self.view.setNeedsLayout()
    }
}
