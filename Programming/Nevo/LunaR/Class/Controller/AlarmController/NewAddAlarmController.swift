//
//  NewAddAlarmController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/4.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class NewAddAlarmController: UITableViewController,ButtonManagerCallBack,UIAlertViewDelegate,SelectedRepeatDelegate,SelectedSleepTypeDelegate {
        
    var mDelegate:AddAlarmDelegate?

    var timer:NSTimeInterval = 0.0
    var repeatStatus:Bool = false
    var name:String = ""
    private var selectedIndexPath:NSIndexPath?
    var repeatSelectedIndex:Int = 0
    var alarmTypeIndex:Int = 0

    init() {
        super.init(nibName: "NewAddAlarmController", bundle: NSBundle.mainBundle())

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Add Alarm"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("controllManager:"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func controllManager(sender:AnyObject) {
        if(sender.isKindOfClass(UISwitch.classForCoder())){

        }else{
            let indexPaths:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            let timerCell:UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPaths)!
            for datePicker in timerCell.contentView.subviews{
                if(datePicker.isKindOfClass(UIDatePicker.classForCoder())){
                    let picker:UIDatePicker = datePicker as! UIDatePicker
                    timer = picker.date.timeIntervalSince1970
                    NSLog("UIDatePicker______%@,\(timer)", picker.date)

                }
            }

            let indexPaths2:NSIndexPath = NSIndexPath(forRow: 1, inSection: 1)
            let timerCell2:UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPaths2)!
            for datePicker in timerCell2.contentView.subviews{
                if(datePicker.isKindOfClass(UISwitch.classForCoder())){
                    let repeatSwicth:UISwitch = datePicker as! UISwitch
                    repeatStatus = repeatSwicth.on
                    NSLog("repeatStatus______%@", repeatStatus)

                }
            }

            let indexPaths3:NSIndexPath = NSIndexPath(forRow: 2, inSection: 1)
            let timerCell3:UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPaths3)!
            name = (timerCell3.detailTextLabel!.text)!

            mDelegate?.onDidAddAlarmAction(timer, name: name, repeatNumber: repeatSelectedIndex, alarmType: alarmTypeIndex)

            self.navigationController?.popViewControllerAnimated(true)
        }

    }

    // MARK: - SelectedRepeatDelegate
    func onSelectedRepeatAction(value:Int,name:String){
        NSLog("onSelectedRepeatAction:value:\(value),name:\(name)")
        let indexPath:NSIndexPath = NSIndexPath(forRow: 1, inSection: 1)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        if(cell != nil) {
            cell!.detailTextLabel?.text = name
        }
        repeatSelectedIndex = value
    }

    // MARK: - SelectedSleepTypeDelegate
    func onSelectedSleepTypeAction(value:Int,name:String){
        NSLog("onSelectedSleepTypeAction:\(value),name:\(name)")
        let indexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 1)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        if(cell != nil) {
            cell!.detailTextLabel?.text = name
        }
        alarmTypeIndex = value
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        switch (indexPath.section){
        case 0: break

        case 1:
            if(indexPath.row == 0) {
                let typeControll:AlarmTypeController = AlarmTypeController()
                typeControll.sleepTypeDelegate = self
                self.navigationController?.pushViewController(typeControll, animated: true)
            }
            if(indexPath.row == 1){
                let repeatControll:RepeatViewController = RepeatViewController()
                repeatControll.selectedDelegate = self
                self.navigationController?.pushViewController(repeatControll, animated: true)
            }

            if(indexPath.row == 2){
                if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){
                    let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!

                    let actionSheet:UIAlertController = UIAlertController(title: NSLocalizedString("add_alarm_label", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                    actionSheet.addTextFieldWithConfigurationHandler({ (labelText:UITextField) -> Void in
                        labelText.text = selectedCell.detailTextLabel?.text
                    })

                    let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in

                    })
                    actionSheet.addAction(alertAction)

                    let alertAction1:UIAlertAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                        let labelText:UITextField = actionSheet.textFields![0]
                        selectedCell.detailTextLabel?.text = labelText.text
                    })
                    actionSheet.addAction(alertAction1)
                    self.presentViewController(actionSheet, animated: true, completion: nil)
                }else{
                    selectedIndexPath = indexPath;
                    let actionSheet:UIAlertView = UIAlertView(title: NSLocalizedString("add_alarm_label", comment: ""), message: "", delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), otherButtonTitles: NSLocalizedString("Add", comment: ""))
                    actionSheet.alertViewStyle = UIAlertViewStyle.PlainTextInput
                    actionSheet.show()
                }
            }

        default: break
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch (section){
        case 0:
            return 1
        case 1:
            return 3
        default: return 1;
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if(indexPath.section == 0){
            let cellHeight:CGFloat = AddAlarmView.addAlarmTimerTableViewCell(indexPath, tableView: tableView, timer:timer).contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            return cellHeight
        }else{
            return 45.0
        }

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section){
        case 0:
            return AddAlarmView.addAlarmTimerTableViewCell(indexPath, tableView: tableView, timer:timer)
        case 1:
            let titleArray:[String] = ["Alarm type","Repeat","Label"]
            var cell = tableView.dequeueReusableCellWithIdentifier("AlarmTypeCell")
            if(cell == nil){
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "AlarmTypeCell")
            }

            if(indexPath.row == 0){
                cell!.textLabel?.text = NSLocalizedString("\(titleArray[indexPath.row])", comment: "")
                let typeArray:[String] = ["Wake Alarm","Sleep Alarm"]
                cell?.detailTextLabel?.text = typeArray[alarmTypeIndex]
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.None;
                return cell!
            }else if(indexPath.row == 1) {
                cell!.textLabel?.text = NSLocalizedString("\(titleArray[indexPath.row])", comment: "")
                let repeatDayArray:[String] = ["Disable","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
                cell!.detailTextLabel?.text = repeatDayArray[repeatSelectedIndex]
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.None;
                return cell!
            }else if(indexPath.row == 2) {
                cell!.textLabel?.text = NSLocalizedString("\(titleArray[indexPath.row])", comment: "")
                cell!.detailTextLabel?.text = name
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.None;
                return cell!
            }
        default: return UITableViewCell();
        }
        return UITableViewCell();
    }


    // MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(selectedIndexPath!)!
        let labelText:UITextField = alertView.textFieldAtIndex(0)!
        selectedCell.detailTextLabel?.text = labelText.text
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
