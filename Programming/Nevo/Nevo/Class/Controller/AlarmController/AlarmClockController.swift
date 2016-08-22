//
//  alarmClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import Timepiece

class AlarmClockController: UITableViewController, SyncControllerDelegate,AddAlarmDelegate {
    
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    private var slectedIndex:Int = -1 //To edit a record the number of rows selected content
    var mWakeAlarmArray:NSMutableArray = NSMutableArray()
    var mSleepAlarmArray:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initValue()
        
        AppDelegate.getAppDelegate().startConnect(false, delegate: self)
        self.editButtonItem().tintColor = UIColor.getBaseColor()
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()

        self.tableView.allowsSelectionDuringEditing = true;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableView.registerNib(UINib(nibName: "AlarmClockVCell",bundle:nil), forCellReuseIdentifier: "alarmCell")
    }

    func initValue() {
        self.view.backgroundColor = UIColor.getGreyColor()
        
        let array:NSArray = UserAlarm.getAll()
        mWakeAlarmArray.removeAllObjects()
        mSleepAlarmArray.removeAllObjects()
        for alarmModel in array{
            let useralarm:UserAlarm = alarmModel as! UserAlarm
            if useralarm.type == 0 {
                mWakeAlarmArray.addObject(useralarm)
            }else{
                mSleepAlarmArray.addObject(useralarm)
            }
        }

        if(UserAlarm.isExistInTable()){
            UserAlarm.updateTable()
        }
    }

    override func viewDidAppear(animated: Bool) {
        checkConnection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ButtonManagerCallBack
    /*
    call back Button Action
    */
    @IBAction func controllManager(sender:AnyObject){

        if(sender.isEqual(rightBarButton)){
            self.tableView.setEditing(false, animated: true)
            let addAlarm:NewAddAlarmController = NewAddAlarmController()
            addAlarm.title = NSLocalizedString("add_alarm", comment: "")
            addAlarm.mDelegate = self
            addAlarm.hidesBottomBarWhenPushed = true
            self.navigationController?.showViewController(addAlarm, sender: self)
        }

        if(sender.isKindOfClass(UISwitch.classForCoder())){
            let mSwitch:UISwitch = sender as! UISwitch
            saveNewAlarmSwicthData(mWakeAlarmArray,index: mSwitch.tag)
        }
    }

    func sleepSwitchManager(sender:UISwitch) {
        saveNewAlarmSwicthData(mSleepAlarmArray,index: sender.tag)
    }
    
    func saveNewAlarmSwicthData(mAlarmArray:NSArray,index:Int) {
        var alarmCount:Int = 0
        for alarm in mAlarmArray{
            let alarmModel:UserAlarm =  alarm as! UserAlarm
            if (alarmModel.status){
                alarmCount += 1
            }
        }

        var isStatus:Bool = false
        if(alarmCount < 7){
            isStatus = true
        }

        let alarmModel:UserAlarm =  mAlarmArray[index] as! UserAlarm
        if(isStatus) {
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":alarmModel.timer,"label":"\(alarmModel.label)","status":isStatus,"repeatStatus":false,"dayOfWeek":alarmModel.dayOfWeek,"type":alarmModel.type])
            let res:Bool = addalarm.update()
            let date:NSDate = NSDate(timeIntervalSince1970: addalarm.timer)
            let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: Bool(addalarm.type) ? alarmCount:alarmCount, alarmWeekday: addalarm.dayOfWeek)
            if(AppDelegate.getAppDelegate().isConnected() && res){
                AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                self.SyncAlarmAlertView()
            }else{
                self.willSyncAlarmAlertView()
            }
        }else{
            let titleString:String = NSLocalizedString("alarmTitle", comment: "")
            let msg:String = NSLocalizedString("Nevo supports only 7 alarms for now.", comment: "")
            let buttonString:String = NSLocalizedString("Ok", comment: "")

            if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){

                let actionSheet:UIAlertController = UIAlertController(title: titleString, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                let alertAction:UIAlertAction = UIAlertAction(title: buttonString, style: UIAlertActionStyle.Default, handler: { ( alert) -> Void in

                })
                actionSheet.addAction(alertAction)

                self.presentViewController(actionSheet, animated: true, completion: nil)
            }else{
                let actionSheet:UIAlertView = UIAlertView(title: titleString, message: msg, delegate: nil, cancelButtonTitle: buttonString)
                actionSheet.layer.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
                actionSheet.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                actionSheet.show()
            }
        }

    }


    /**
     Will sync when nevo is connected
     */
    func willSyncAlarmAlertView() {
        let banner = Banner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
    }

    /**
     Syncing alarm
     */
    func SyncAlarmAlertView() {
        let banner = Banner(title: NSLocalizedString("syncing_Alarm", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
    }

    // MARK: - AddAlarmDelegate
    func onDidAddAlarmAction(timer:NSTimeInterval,repeatStatus:Bool,name:String) {
    
    }
    
    func onDidAddAlarmAction(timer:NSTimeInterval,name:String,repeatNumber:Int,alarmType:Int) {
        var sleepAlarmCount:Int = 7
        var dayAlarmCount:Int = 0
        let alarmArray:NSArray = alarmType==1 ? mSleepAlarmArray:mWakeAlarmArray
        
        let array:NSArray = UserAlarm.getAll()
        for alarm in array{
            let alarmModel:UserAlarm =  alarm as! UserAlarm
            if(alarmModel.type == 1 && alarmModel.status) {
                sleepAlarmCount += 1
            }else if (alarmModel.type == 0 && alarmModel.status){
                dayAlarmCount += 1
            }
        }
        
        if(slectedIndex >= 0){
            let alarmModel:UserAlarm =  alarmArray[slectedIndex] as! UserAlarm
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":timer,"label":"\(name)","status":alarmModel.status,"repeatStatus":false,"dayOfWeek":repeatNumber,"type":alarmType])
            if(addalarm.update()){
                
                (alarmType==0 ? mSleepAlarmArray:mWakeAlarmArray).replaceObjectAtIndex(slectedIndex, withObject: addalarm)
                self.editing = false
                self.tableView.setEditing(false, animated: true)
                self.tableView.reloadData()

                let date:NSDate = NSDate(timeIntervalSince1970: timer)
                let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: Bool(alarmType) ? sleepAlarmCount:dayAlarmCount, alarmWeekday: repeatNumber)

                if(AppDelegate.getAppDelegate().isConnected()){
                    AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                    SyncAlarmAlertView()
                }else{
                    willSyncAlarmAlertView()
                }

                slectedIndex = -1
            }
        }else{
            var isDayStatus:Bool = false
            var isSleepStatus:Bool = false
            if(dayAlarmCount<=6){
                isDayStatus = true
            }

            if(sleepAlarmCount<=13) {
                isSleepStatus = true
            }

            let switchStatus:Bool = Bool(alarmType) ? isSleepStatus:isDayStatus
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":0,"timer":timer,"label":"\(name)","status":switchStatus ,"repeatStatus":false,"dayOfWeek":repeatNumber,"type":alarmType])
            addalarm.add({ (id, completion) -> Void in
                if(completion!){
                    addalarm.id = id!
                    (alarmType==1 ? self.mSleepAlarmArray:self.mWakeAlarmArray).addObject(addalarm)
                    self.tableView.reloadData()

                    let date:NSDate = NSDate(timeIntervalSince1970: timer)
                    let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: Bool(alarmType) ? sleepAlarmCount:dayAlarmCount, alarmWeekday: repeatNumber)

                    if(switchStatus) {
                        if(AppDelegate.getAppDelegate().isConnected()){
                            AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                            self.SyncAlarmAlertView()
                        }else{
                            self.willSyncAlarmAlertView()
                        }
                    }
                }else{
                    let aler:UIAlertView = UIAlertView(title: "Tip", message: "Database insert fail", delegate: nil, cancelButtonTitle: "ok")
                    aler.show()
                }
            })
        }
    }

    // MARK: - SyncControllerDelegate
    func receivedRSSIValue(number:NSNumber){

    }

    func packetReceived(packet:NevoPacket) {
    
    }

    func connectionStateChanged(isConnected : Bool) {

        //Maybe we just got disconnected, let's check

        //checkConnection()

    }

    func syncFinished(){

    }

    func stringFromDate(date:NSDate) -> String {
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateFormat = "HH:mm a"
        let dateString:String = dateFormatter.stringFromDate(date)
        return dateString
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


    // MARK: - UITableViewDelegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        if mWakeAlarmArray.count == 0 && mSleepAlarmArray.count == 0 {
            tableView.backgroundView = NotAlarmView.getNotAlarmView()
            return 0
        }else{
            tableView.backgroundView = nil
            return 2
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            return mSleepAlarmArray.count
        }else if section == 1 {
            return mWakeAlarmArray.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let headerLabel:LineLabel = LineLabel(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,30))
        headerLabel.backgroundColor = UIColor.getGreyColor()
        let titleArray:[String] = ["Sleep Alarm","Wake Alarm"]
        headerLabel.text = NSLocalizedString(titleArray[section], comment: "")
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.textAlignment = NSTextAlignment.Center
        if section == 0 {
            headerLabel.backgroundColor = UIColor.getLightBaseColor()
        }
        return headerLabel
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let endCell:AlarmClockVCell = tableView.dequeueReusableCellWithIdentifier("alarmCell", forIndexPath: indexPath) as! AlarmClockVCell
        endCell.selectionStyle = UITableViewCellSelectionStyle.None
        var alarmModel:UserAlarm?
        if indexPath.section == 0 {
            alarmModel = mSleepAlarmArray[indexPath.row] as? UserAlarm
        }else{
            alarmModel = mWakeAlarmArray[indexPath.row] as? UserAlarm
        }
        
        let dayArray:[String] = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        let date:NSDate = NSDate(timeIntervalSince1970: alarmModel!.timer)
        if alarmModel?.dayOfWeek == 0 {
            endCell.alarmIn.text = "Alarm close"
        }else{
            if alarmModel!.dayOfWeek != NSDate().weekday {
                endCell.alarmIn.text = "Alarm on \(dayArray[alarmModel!.dayOfWeek-1]) "
            }else{
                if date.hour>=NSDate().hour && date.minute>NSDate().minute {
                    let nowHour:Int = abs(date.hour-NSDate().hour)
                    let noeMinte:Int = abs(date.minute-NSDate().minute)
                    endCell.alarmIn.text = "Alarm in \(nowHour)h \(noeMinte)m"
                }else{
                    endCell.alarmIn.text = "Alarm close"
                }
            }
        }
        endCell.dateLabel.text = stringFromDate(date)
        endCell.titleLabel.text = alarmModel!.label
        endCell.alarmSwicth.tag = indexPath.row
        endCell.alarmSwicth.on = alarmModel!.status
        if indexPath.section == 0 {
            endCell.alarmSwicth.addTarget(self, action: #selector(sleepSwitchManager(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }else{
            endCell.contentView.backgroundColor = UIColor.getGreyColor()
            endCell.alarmSwicth.addTarget(self, action: #selector(controllManager(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }
        
        return endCell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?{
        let button1 = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        })
        button1.backgroundColor = UIColor.getBaseColor()
        return [button1]
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            var willAlarm:UserAlarm?
            if indexPath.section == 0 {
                willAlarm = mSleepAlarmArray[indexPath.row] as? UserAlarm
            }else{
                willAlarm = mWakeAlarmArray[indexPath.row] as? UserAlarm
            }

            if(willAlarm!.remove()){
                if indexPath.section == 0 {
                    mSleepAlarmArray.removeObjectAtIndex(indexPath.row)
                }else{
                    mWakeAlarmArray.removeObjectAtIndex(indexPath.row)
                }
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                var alarmArray:[NewAlarm] = []
                let array:NSArray = indexPath.section==1 ? mWakeAlarmArray:mSleepAlarmArray
                for (index, value) in array.enumerate() {
                    if((value as! UserAlarm).status) {
                        let date:NSDate = NSDate(timeIntervalSince1970: (value as! UserAlarm).timer)
                        let alarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: index, alarmWeekday: (value as! UserAlarm).dayOfWeek)
                        alarmArray.append(alarm)
                    }
                }

                //Only delete state switch on will be synchronized to watch
                if(willAlarm!.status) {
                    if(AppDelegate.getAppDelegate().isConnected()){
                        for alarm in alarmArray {
                            let newAlarm:NewAlarm = alarm
                            AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                        }
                        self.SyncAlarmAlertView()
                    }else{
                        self.willSyncAlarmAlertView()
                    }
                }
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if(self.editing){
            slectedIndex = indexPath.row
            var alarmModel:UserAlarm?
            if indexPath.section == 0 {
                alarmModel = mSleepAlarmArray[indexPath.row] as? UserAlarm
            }else{
                alarmModel = mWakeAlarmArray[indexPath.row] as? UserAlarm
            }

            let addAlarm:NewAddAlarmController = NewAddAlarmController()
            addAlarm.title = NSLocalizedString("edit_alarm", comment: "")
            addAlarm.timer = alarmModel!.timer
            addAlarm.name = alarmModel!.label
            addAlarm.alarmTypeIndex = alarmModel!.type
            addAlarm.repeatSelectedIndex = alarmModel!.dayOfWeek
            addAlarm.mDelegate = self
            addAlarm.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addAlarm, animated: true)

        }

    }
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
}
