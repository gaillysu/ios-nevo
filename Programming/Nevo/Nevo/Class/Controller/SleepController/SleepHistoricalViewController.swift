//
//  QueryHistoricalController.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/14.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SleepHistoricalViewController: UIViewController,ChartViewDelegate,SelectedChartViewDelegate {

    @IBOutlet var queryView: SleepHistoricalView!
    private var contentTitleArray:[String] = []
    private var contentTArray:[String] = ["0","0","0","0","0","0"]

    private var queryArray:NSArray?
    init() {
        super.init(nibName: "SleepHistoricalViewController", bundle: NSBundle.mainBundle())

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if(Double(UIDevice.currentDevice().systemVersion)>7.0){
            self.edgesForExtendedLayout = UIRectEdge.None;
            self.extendedLayoutIncludesOpaqueBars = false;
            self.modalPresentationCapturesStatusBarAppearance = false;
        }

        contentTitleArray = [NSLocalizedString("sleep_duration", comment: ""), NSLocalizedString("deep_sleep", comment: ""), NSLocalizedString("light_sleep", comment: ""), NSLocalizedString("sleep_timer", comment: ""), NSLocalizedString("wake_timer", comment: ""), NSLocalizedString("wake_duration", comment: "")]
        queryArray = UserSleep.getAll()

        queryView.bulidQueryView(self,modelArray: queryArray!,navigation: self.navigationItem)

        queryView.detailCollectionView.backgroundColor = UIColor.whiteColor()
        queryView.detailCollectionView.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "SleepHistoryViewCell")
        (queryView.detailCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width/3.0, queryView.detailCollectionView.frame.size.height/3.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - SelectedChartViewDelegate
    func didSleepSelectedhighlightValue(xIndex:Int,dataSetIndex: Int, dataSleep:Sleep) {
        //contentTArray
        contentTArray.removeAll()
        contentTArray.insert(String(format: "%.2f", dataSleep.getTotalSleep()), atIndex: 0)
        contentTArray.insert(String(format: "%.2f", dataSleep.getDeepSleep()), atIndex: 1)
        contentTArray.insert(String(format: "%.2f", dataSleep.getLightSleep()), atIndex: 2)
        contentTArray.insert("\(0)", atIndex: 3)
        contentTArray.insert("\(0)", atIndex: 4)
        contentTArray.insert("\(0)", atIndex: 5)
        queryView.detailCollectionView.reloadData()
    }

    private func calculateMinutes(time:Double) -> (hours:Int,minutes:Int){
        return (Int(time),Int(60*(time%1)));
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentTitleArray.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SleepHistoryViewCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.whiteColor()
        cell.backgroundView = UIView()
        let titleView = cell.contentView.viewWithTag(1500)
        if(titleView == nil){
            let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height/3.0))
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.textColor = UIColor.grayColor()
            titleLabel.backgroundColor = UIColor.whiteColor()
            titleLabel.font = UIFont.boldSystemFontOfSize((cell.contentView.frame.size.height/3.0)*0.6)
            titleLabel.tag = 1500
            titleLabel.text = contentTitleArray[indexPath.row]
            cell.contentView.addSubview(titleLabel)
        }else {
            let titleLabel:UILabel = titleView as! UILabel
            titleLabel.text = contentTitleArray[indexPath.row]
        }

        let contentView = cell.contentView.viewWithTag(1700)
        if(contentView == nil){
            let contentStepsView:UILabel = UILabel(frame: CGRectMake(0, cell.contentView.frame.size.height/3.0, cell.contentView.frame.size.width, (cell.contentView.frame.size.height/3.0)*2.0))
            contentStepsView.textAlignment = NSTextAlignment.Center
            contentStepsView.backgroundColor = UIColor.whiteColor()
            contentStepsView.font = UIFont.boldSystemFontOfSize((cell.contentView.frame.size.height/3.0)*0.9)
            contentStepsView.tag = 1700
            contentStepsView.text = "\(contentTArray[indexPath.row])"
            cell.contentView.addSubview(contentStepsView)
        }else {
            let contentStepsView:UILabel = contentView as! UILabel
            contentStepsView.text = "\(contentTArray[indexPath.row])"
        }
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
