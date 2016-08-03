//
//  StepHistoricalViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class StepsHistoryViewController: UIViewController,UICollectionViewDelegateFlowLayout,SelectedChartViewDelegate {

    @IBOutlet weak var stepsHistortView: StepHistoricalView!
    @IBOutlet weak var stepsHistori: UICollectionView!
    private var queryArray:NSArray = NSArray()
    private var contentTitleArray:[String] = []
    private var contentTArray:[String] = [NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: "")]
    
    init() {
        super.init(nibName: "StepsHistoryViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if((UIDevice.currentDevice().systemVersion as NSString).floatValue>7.0){
            self.edgesForExtendedLayout = UIRectEdge.None;
            self.extendedLayoutIncludesOpaqueBars = false;
            self.modalPresentationCapturesStatusBarAppearance = false;
        }
        contentTitleArray = [NSLocalizedString("goal", comment: ""), NSLocalizedString("progress", comment: ""), NSLocalizedString("you_reached", comment: "")]
    }

    override func viewWillAppear(animated: Bool) {
        queryArray = UserSteps.getAll()
        stepsHistortView.bulidStepHistoricalView(self, modelArray: queryArray, navigation: self.navigationItem)

        if(queryArray.count>0) {
            stepsHistortView.nodataLabel.hidden = true
        }else{
            stepsHistortView.nodataLabel.backgroundColor = UIColor.whiteColor()
            stepsHistortView.nodataLabel.hidden = false
            stepsHistortView.nodataLabel.text = NSLocalizedString("no_data", comment: "");
        }
    }

    override func viewDidLayoutSubviews() {
        stepsHistori.backgroundColor = UIColor.whiteColor()
        stepsHistori.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "StepsHistoryViewCell")
        (stepsHistori.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width/3.0, stepsHistori.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - SelectedChartViewDelegate
    func didSelectedhighlightValue(xIndex:Int,dataSetIndex: Int, dataSteps:UserSteps) {
        contentTArray.removeAll()
        contentTArray.insert("\(dataSteps.goalsteps)", atIndex: 0)
        contentTArray.insert(String(format: "%.2f%c", dataSteps.goalreach*100,37), atIndex: 1)
        contentTArray.insert("\(dataSteps.steps)", atIndex: 2)
        stepsHistori.reloadData()
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
