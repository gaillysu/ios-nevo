//
//  SleepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AnalysisController: PublicClassController {
    
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var chartsCollectionView: UICollectionView!
    @IBOutlet weak var contentCollectionView: UICollectionView!

    let titleArray:[String] = [NSLocalizedString("this_week", comment: ""),NSLocalizedString("last_week", comment: ""),NSLocalizedString("last_30_day", comment: "")]
    fileprivate var contentTitleArray:[String] = [NSLocalizedString("average_steps", comment: ""), NSLocalizedString("total_steps", comment: ""), NSLocalizedString("average_calories", comment: ""),NSLocalizedString("average_time", comment: "")]
    fileprivate var contentTArray:[String] = [NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: "")]
    fileprivate var dataArray:NSMutableArray = NSMutableArray(capacity:3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            contentCollectionView.backgroundColor = UIColor.getGreyColor()
            chartsCollectionView.backgroundColor = UIColor.getGreyColor()
            segmented.tintColor = UIColor.getBaseColor()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AnalysisController {
    @IBAction func segmentedAction(_ sender: AnyObject) {
        let segment:UISegmentedControl = sender as! UISegmentedControl
        dataArray.removeAllObjects()
        if segment.selectedSegmentIndex == 0 {
            dataArray.addObjects(from: self.getStepsData())
            chartsCollectionView.reloadData()
        }else if segment.selectedSegmentIndex == 1 {
            dataArray.addObjects(from: self.getSleepData())
            chartsCollectionView.reloadData()
        }else{
            dataArray.addObjects(from: self.getStepsData())
            chartsCollectionView.reloadData()
        }
    }
    
    func getStepsData()->[NSArray] {
        let dayDate:Date = Date()
        let thisWeekArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970) AND \(dayDate.endOfWeek.timeIntervalSince1970)")
        let lastWeekArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-(86400.0*7+1)) AND \(dayDate.beginningOfWeek.timeIntervalSince1970+1)")
        let last30DayArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfDay.timeIntervalSince1970-(86400.0*30)) AND \(dayDate.endOfDay.timeIntervalSince1970)")
        return [thisWeekArray,lastWeekArray,last30DayArray]
    }
    
    func getSleepData()->[NSArray] {
        let nextDay:Double = 86401
        
        let dayDate:Date = Date()
        let thisWeekArray:NSArray = UserSleep.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-nextDay) AND \(dayDate.endOfWeek.timeIntervalSince1970+nextDay)")
        let lastWeekArray:NSArray = UserSleep.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-(86400.0*7)-nextDay) AND \(dayDate.beginningOfWeek.timeIntervalSince1970+nextDay)")
        let last30DayArray:NSArray = UserSleep.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfDay.timeIntervalSince1970-(86400.0*30)-nextDay) AND \(dayDate.endOfDay.timeIntervalSince1970+nextDay)")
        return [thisWeekArray,lastWeekArray,last30DayArray]
    }
    
    func getSolarData()->[NSArray] {
        let dayDate:Date = Date()
        let thisWeekArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-1) AND \(dayDate.endOfWeek.timeIntervalSince1970)")
        let lastWeekArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-(86400.0*7)-1) AND \(dayDate.beginningOfWeek.timeIntervalSince1970)")
        let last30DayArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfDay.timeIntervalSince1970-(86400.0*30)) AND \(dayDate.endOfDay.timeIntervalSince1970)")
        return [thisWeekArray,lastWeekArray,last30DayArray]
    }
}

extension AnalysisController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if collectionView.isEqual(chartsCollectionView) {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }else{
            if segmented.selectedSegmentIndex == 2 {
                return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height/2.0)
            }
            return CGSize(width: collectionView.frame.size.width/2.0, height: collectionView.frame.size.height/2.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.isEqual(chartsCollectionView){
            return titleArray.count
        }else{
            return contentTitleArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.isEqual(chartsCollectionView) {
            let cell:AnalysisLineChartCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnalysisLineChart_Identifier", for: indexPath) as! AnalysisLineChartCell
            cell.backgroundColor = UIColor.clear
            cell.setTitle(titleArray[(indexPath as NSIndexPath).row])
            return cell
        }else{
            let cell:AnalysisValueCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnalysisValue_Identifier", for: indexPath) as! AnalysisValueCell
            cell.backgroundColor = UIColor.clear
            //cell.titleLabel.text = contentTitleArray[(indexPath as NSIndexPath).row]
            cell.updateTitleLabel(contentTitleArray[(indexPath as NSIndexPath).row])
            var unit:String = ""
            if segmented.selectedSegmentIndex == 1 {
                switch (indexPath as NSIndexPath).row {
                case 0:
                    unit = "h"
                    break
                case 1:
                    unit = "h"
                    break
                case 2:
                    unit = "h"
                    break
                case 3:
                    unit = "%"
                    break
                default:
                    break
                }
            }
            //cell.valueLabel.text = contentTArray[indexPath.row]+" "+unit
            cell.updateLabel(contentTArray[(indexPath as NSIndexPath).row]+" "+unit)
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
                    self.contentTArray.replaceSubrange(Range(0..<1), with: [String(format: "%.1f",totalValue/avgNumber)])
                    self.contentTArray.replaceSubrange(Range(1..<2), with: [String(format: "%.1f",totalValue)])
                    self.contentTArray.replaceSubrange(Range(2..<3), with: [String(format: "%.1f",totalCalores/Int(avgNumber))])
                    self.contentTArray.replaceSubrange(Range(3..<4), with: [String(format: "%.1f",totalTime/Int(avgNumber))])
                });
            }else{
                self.contentTArray.replaceSubrange(Range(0..<1), with: [String(format: "0")])
                self.contentTArray.replaceSubrange(Range(1..<2), with: [String(format: "0")])
                
                analysisCell.updateChartData(dataArray[indexPath.row] as! NSArray, chartType: segmented.selectedSegmentIndex,rowIndex:indexPath.row, completionData: { (totalValue, totalCalores, totalTime) in
                    
                });
            }
            contentCollectionView.reloadData()
        }
    }
}
