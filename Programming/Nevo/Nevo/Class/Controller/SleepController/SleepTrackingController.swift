//
//  HomeController.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import UIKit

/*
Controller of the Home Screen,
it should handle very little, only the initialisation of the different Views and the Sync Controller
*/

class SleepTrackingController: PublicClassController, SyncControllerDelegate ,ButtonManagerCallBack,ClockRefreshDelegate,UICollectionViewDelegate,UICollectionViewDataSource{
    @IBOutlet weak var sleepView: SleepTrackingView!
    private var mVisiable:Bool = false
    private var contentTitleArray:[String] = []
    private var contentTArray:[String] = ["0","0","0","0","0","0"]

    init() {
        super.init(nibName: "SleepTrackingController", bundle: NSBundle.mainBundle())

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
        ClockRefreshManager.sharedInstance.setRefreshDelegate(self)

        sleepView.bulidHomeView(self)
        sleepView.collectionView?.delegate = self
        sleepView.collectionView?.dataSource = self

        if(NSUserDefaults.standardUserDefaults().boolForKey("firstLaunch")){
            let page7:Page7Controller = Page7Controller()
            self.presentViewController(page7, animated: true, completion: { () -> Void in
                
            })
        }

    }

    override func viewDidAppear(animated: Bool) {
        //todaySleepArray: sync!.GET_TodaySleepData()
        if !AppDelegate.getAppDelegate().getMconnectionController().hasSavedAddress() {
            AppTheme.DLog("No saved device, let's launch the tutorial")
        } else {
            AppTheme.DLog("We have a saved address, no need to go through the tutorial")
            AppDelegate.getAppDelegate().startConnect(false, delegate: self)
            checkConnection()
            mVisiable = true
        }

        if(AppDelegate.getAppDelegate().GET_TodaySleepData().count == 2){
            sleepView.setProgress(AppDelegate.getAppDelegate().GET_TodaySleepData())
        }

    }
    
    override func viewDidDisappear(animated: Bool) {
        mVisiable = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ClockRefreshDelegate
    func clockRefreshAction(){
        sleepView.getClockTimerView().currentTimer()
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject) {

        
    }

    /**
    goto OTA screen.
    */
    func gotoOTAScreen(){
        self.performSegueWithIdentifier("Home_nevoOta", sender: self)
    }

    /**

    See SyncControllerDelegate
    
    */
    // MARK: - SyncControllerDelegate
    func packetReceived(packet:NevoPacket) {

        if packet.getHeader() == LedLightOnOffNevoRequest.HEADER()
        {
            AppTheme.DLog("end handshake nevo");
            //blink once Clock
            self.sleepView.getClockTimerView().setClockImage(AppTheme.GET_RESOURCES_IMAGE("clockview600_color"))
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
              self.sleepView.getClockTimerView().setClockImage(AppTheme.GET_RESOURCES_IMAGE("white_clock"))
            })
        }
    }

    /**
    See SyncControllerDelegate
    */
    func receivedRSSIValue(number:NSNumber){

    }

    func connectionStateChanged(isConnected: Bool) {
        //Maybe we just got disconnected, let's check
        
        checkConnection()
    }

    func syncFinished(){
        if(AppDelegate.getAppDelegate().GET_TodaySleepData().count==2){
            sleepView.setProgress(AppDelegate.getAppDelegate().GET_TodaySleepData())
        }
    }

    /**
    Checks if any device is currently connected
    */
    
    func checkConnection() {
        
        if !AppDelegate.getAppDelegate().isConnected() {
            //We are currently not connected
           reconnect()
        }
    }
    
    func reconnect() {
        AppDelegate.getAppDelegate().connect()
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SleepCollectionViewCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        let labelheight:CGFloat = cell.contentView.frame.size.height
        let titleView = cell.contentView.viewWithTag(1500)
        let iphone:Bool = AppTheme.GET_IS_iPhone5S()
        if(titleView == nil){
            let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, cell.contentView.frame.size.width, labelheight/2.0))
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.backgroundColor = UIColor.clearColor()
            titleLabel.font = UIFont.boldSystemFontOfSize(iphone ? 10:12)
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
            contentStepsView.textColor = UIColor.whiteColor()
            contentStepsView.font = UIFont.boldSystemFontOfSize(iphone ? 12:15)
            contentStepsView.tag = 1700
            contentStepsView.text = "\(contentTArray[indexPath.row])"
            contentStepsView.sizeToFit()
            cell.contentView.addSubview(contentStepsView)
            contentStepsView.center = CGPointMake(cell.contentView.frame.size.width/2.0,labelheight/2.0+contentStepsView.frame.size.height/2.0)
        }else {
            let contentStepsView:UILabel = contentView as! UILabel
            contentStepsView.text = "\(contentTArray[indexPath.row])"
            contentStepsView.sizeToFit()
            contentStepsView.center = CGPointMake(cell.contentView.frame.size.width/2.0,labelheight/2.0+contentStepsView.frame.size.height/2.0)
        }
        return cell
    }

}
