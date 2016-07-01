//
//  AddAlarmController.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/27.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol AddAlarmDelegate {
    func onDidAddAlarmAction(timer:NSTimeInterval,repeatStatus:Bool,name:String)
    func onDidAddAlarmAction(timer:NSTimeInterval,name:String,repeatNumber:Int,alarmType:Int)
}

class AddAlarmController: UITableViewController,ButtonManagerCallBack,UIAlertViewDelegate {

    @IBOutlet weak var adTableView: AddAlarmView!
    var mDelegate:AddAlarmDelegate?

    var timer:NSTimeInterval = 0.0
    var repeatStatus:Bool = false
    var name:String = ""
    private var selectedIndexPath:NSIndexPath?

    init() {
        super.init(nibName: "AddAlarmController", bundle: NSBundle.mainBundle())

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        adTableView.bulidAdTableView(self.navigationItem)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("controllManager:"))
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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

            let indexPaths2:NSIndexPath = NSIndexPath(forRow: 0, inSection: 1)
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

            mDelegate?.onDidAddAlarmAction(timer, repeatStatus: repeatStatus, name: name)
            self.navigationController?.popViewControllerAnimated(true)
        }

    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        switch (indexPath.section){
        case 0: break

        case 1:
            if(indexPath.row == 1){
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
            return 2
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
            let titleArray:[String] = ["Repeat","Label"]
            if(indexPath.row == 0){
                let cell = AddAlarmView.systemTableViewCell(indexPath, tableView: tableView, title: titleArray[indexPath.row],delegate: self)
                return cell
            }else if(indexPath.row == 1) {
                let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "SystemLabelCell")
                cell.textLabel?.text = NSLocalizedString("\(titleArray[indexPath.row])", comment: "")
                cell.detailTextLabel?.text = name
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = UITableViewCellSelectionStyle.None;
                return cell
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