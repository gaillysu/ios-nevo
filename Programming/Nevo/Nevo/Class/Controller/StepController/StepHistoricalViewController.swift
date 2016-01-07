//
//  StepHistoricalViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class StepHistoricalViewController: UIViewController,UICollectionViewDelegateFlowLayout,SelectedChartViewDelegate {

    @IBOutlet weak var stepsHistortView: StepHistoricalView!
    @IBOutlet weak var stepsHistori: UICollectionView!
    private var queryArray:NSArray = NSArray()
    private var contentTitleArray:[String] = []
    private var contentTArray:[String] = ["0","0","0","0","0","0","0","0","0"]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "StepHistoricalViewController", bundle: NSBundle.mainBundle())
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
        queryArray = UserSteps.getAll()
        stepsHistortView.bulidStepHistoricalView(self, modelArray: queryArray, navigation: self.navigationItem)
        
        contentTitleArray = [NSLocalizedString("all_day_mileage", comment: ""), NSLocalizedString("all_day_steps", comment: ""), NSLocalizedString("all_day_consume", comment: ""), NSLocalizedString("walking_mileage", comment: ""), NSLocalizedString("walking_duration", comment: ""), NSLocalizedString("walking_consume", comment: ""),NSLocalizedString("running_mileage", comment: ""), NSLocalizedString("running_duration", comment: ""), NSLocalizedString("running_consume", comment: "")]
        stepsHistori.backgroundColor = UIColor.whiteColor()
        stepsHistori.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "StepsHistoryViewCell")
        (stepsHistori.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width/3.0, stepsHistori.frame.size.height/3.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - SelectedChartViewDelegate
    func didSelectedhighlightValue(xIndex:Int,dataSetIndex: Int, dataSteps:UserSteps) {
        //contentTArray
        contentTArray.removeAll()
        contentTArray.insert("\(dataSteps.distance)", atIndex: 0)
        contentTArray.insert("\(dataSteps.steps)", atIndex: 1)
        contentTArray.insert("\(dataSteps.calories)", atIndex: 2)
        contentTArray.insert("\(dataSteps.walking_distance)", atIndex: 3)
        contentTArray.insert("\(dataSteps.walking_duration)", atIndex: 4)
        contentTArray.insert("\(dataSteps.walking_calories)", atIndex: 5)
        contentTArray.insert("\(dataSteps.running_distance)", atIndex: 6)
        contentTArray.insert("\(dataSteps.running_duration)", atIndex: 7)
        contentTArray.insert("\(dataSteps.running_calories)", atIndex: 8)
        stepsHistori.reloadData()
        
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentTitleArray.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StepsHistoryViewCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.whiteColor()
        cell.backgroundView = UIView()
        let titleView = cell.contentView.viewWithTag(1500)
        if(titleView == nil){
            let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height/3.0))
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.textColor = UIColor.grayColor()
            titleLabel.backgroundColor = UIColor.whiteColor()
            titleLabel.font = UIFont.systemFontOfSize((cell.contentView.frame.size.height/3.0)*0.6)
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
            contentStepsView.font = UIFont.systemFontOfSize((cell.contentView.frame.size.height/3.0)*0.9)
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
