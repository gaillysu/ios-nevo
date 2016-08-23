//
//  NewAddAlarmController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/4.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class NewAddAlarmController: UITableViewController,ButtonManagerCallBack,SelectedRepeatDelegate,SelectedSleepTypeDelegate {
        
    var mDelegate:AddAlarmDelegate?

    var timer:NSTimeInterval = 0.0
    var repeatStatus:Bool = false
    var name:String = ""
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(controllManager(_:)))
        
        self.tableView.registerNib(UINib(nibName: "NewAddAlarmHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "identifier_header")
        self.tableView.registerNib(UINib(nibName: "AlarmTypeCell", bundle: nil), forCellReuseIdentifier: "AlarmType_identifier")
        self.tableView.backgroundColor = UIColor.whiteColor()
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.separatorColor = UIColor.getLightBaseColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        if self.tableView.tableFooterView == nil {
            let view = UIView()
            let tipsString:String = "Tips:\n    Sleep alarm allows you set a timmer that your Nevo can automatic turn on sleep mode."
            let tipsLabel:UILabel = UILabel(frame: CGRectMake(10,0,UIScreen.mainScreen().bounds.size.width-20,120))
            tipsLabel.numberOfLines = 0
            tipsLabel.text = tipsString
            tipsLabel.font = UIFont(name: "Helvetica Neue", size: 10)
            let attributeDict:[String : AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(16)]
            let AttributedStr:NSMutableAttributedString = NSMutableAttributedString(string: tipsString, attributes: attributeDict)
            AttributedStr.addAttribute(NSForegroundColorAttributeName, value: AppTheme.NEVO_SOLAR_YELLOW(), range: NSMakeRange(0, 5))
            tipsLabel.attributedText = AttributedStr
            view.addSubview(tipsLabel)
            self.tableView.tableFooterView = view
        }
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

            let indexPaths3:NSIndexPath = NSIndexPath(forRow: 1, inSection: 1)
            let timerCell3:UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPaths3)!
            name = (timerCell3.detailTextLabel!.text)!

            mDelegate?.onDidAddAlarmAction(timer, name: name, repeatNumber: repeatSelectedIndex, alarmType: alarmTypeIndex)

            self.navigationController?.popViewControllerAnimated(true)
        }

    }

    // MARK: - SelectedRepeatDelegate
    func onSelectedRepeatAction(value:Int,name:String){
        NSLog("onSelectedRepeatAction:value:\(value),name:\(name)")
        let indexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 1)
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
            if(indexPath.row == 0){
                let repeatControll:RepeatViewController = RepeatViewController()
                repeatControll.selectedDelegate = self
                repeatControll.selectedIndex = repeatSelectedIndex
                self.navigationController?.pushViewController(repeatControll, animated: true)
            }

            if(indexPath.row == 1){
                let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
                
                let actionSheet:UIAlertController = UIAlertController(title: NSLocalizedString("add_alarm_label", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                actionSheet.addTextFieldWithConfigurationHandler({ (labelText:UITextField) -> Void in
                    labelText.text = selectedCell.detailTextLabel?.text
                })
                
                let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                    
                })
                alertAction.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
                actionSheet.addAction(alertAction)
                
                let alertAction1:UIAlertAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                    let labelText:UITextField = actionSheet.textFields![0]
                    selectedCell.detailTextLabel?.text = labelText.text
                    selectedCell.layoutSubviews()
                })
                alertAction1.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
                actionSheet.addAction(alertAction1)
                self.presentViewController(actionSheet, animated: true, completion: nil)
            }

        default: break
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section){
        case 0:
            return 1
        case 1:
            return 2
        default: return 1;
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 45
        }else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if(indexPath.section == 0){
            let cellHeight:CGFloat = AddAlarmView.addAlarmTimerTableViewCell(indexPath, tableView: tableView, timer:timer).contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            return cellHeight
        }else{
            return 45.0
        }

    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let  headerCell:NewAddAlarmHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier("identifier_header") as! NewAddAlarmHeader
            headerCell.actionCallBack = {
                (sender) -> Void in
                let segment:UISegmentedControl = sender as! UISegmentedControl
                NSLog("选择器发送实例第几个:\(segment.selectedSegmentIndex)")
                self.alarmTypeIndex = segment.selectedSegmentIndex
            }
            return headerCell
        }else{
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section){
        case 0:
            return AddAlarmView.addAlarmTimerTableViewCell(indexPath, tableView: tableView, timer:timer)
        case 1:
            let titleArray:[String] = ["Repeat","Label"]
            let cell = tableView.dequeueReusableCellWithIdentifier("AlarmType_identifier",forIndexPath: indexPath)
            cell.preservesSuperviewLayoutMargins = false;
            cell.separatorInset = UIEdgeInsetsZero;
            cell.layoutMargins = UIEdgeInsetsZero;
            cell.backgroundColor = UIColor.clearColor()
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = UITableViewCellSelectionStyle.None;
            if(indexPath.row == 0) {
                cell.textLabel?.text = NSLocalizedString("\(titleArray[indexPath.row])", comment: "")
                let repeatDayArray:[String] = ["Disable","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
                cell.detailTextLabel?.text = repeatDayArray[repeatSelectedIndex]
            }else if(indexPath.row == 1) {
                cell.textLabel?.text = NSLocalizedString("\(titleArray[indexPath.row])", comment: "")
                cell.detailTextLabel?.text = name
            }
            return cell
        default: return UITableViewCell();
        }
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
