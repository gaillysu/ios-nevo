//
//  AddAlarmController.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/27.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol AddAlarmDelegate {
    func onDidAddAlarmAction(_ timer:TimeInterval,repeatStatus:Bool,name:String)
    func onDidAddAlarmAction(_ timer:TimeInterval,name:String,repeatNumber:Int,alarmType:Int)
}

class AddAlarmController: UITableViewController,ButtonManagerCallBack,UIAlertViewDelegate {

    @IBOutlet weak var adTableView: AddAlarmView!
    var mDelegate:AddAlarmDelegate?

    var timer:TimeInterval = 0.0
    var repeatStatus:Bool = false
    var name:String = ""
    fileprivate var selectedIndexPath:IndexPath?

    init() {
        super.init(nibName: "AddAlarmController", bundle: Bundle.main)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName:"AddAlarmTableViewCell", bundle: nil), forCellReuseIdentifier: "AddAlarm_Date_identifier")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(controllManager(_:)))
        
        // MARK: - About Theme
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getLightBaseColor()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func controllManager(_ sender:AnyObject) {
        if(sender.isKind(of: UISwitch.classForCoder())){
            
        }else{
            let indexPaths:IndexPath = IndexPath(row: 0, section: 0)
            let timerCell:UITableViewCell = self.tableView.cellForRow(at: indexPaths)!
            for datePicker in timerCell.contentView.subviews{
                if(datePicker.isKind(of: UIDatePicker.classForCoder())){
                    let picker:UIDatePicker = datePicker as! UIDatePicker
                    timer = picker.date.timeIntervalSince1970
                }
            }

            let indexPaths2:IndexPath = IndexPath(row: 0, section: 1)
            let timerCell2:UITableViewCell = self.tableView.cellForRow(at: indexPaths2)!
            for datePicker in timerCell2.contentView.subviews{
                if(datePicker.isKind(of: UISwitch.classForCoder())){
                    let repeatSwicth:UISwitch = datePicker as! UISwitch
                    repeatStatus = repeatSwicth.isOn
                }
            }

            let indexPaths3:IndexPath = IndexPath(row: 1, section: 1)
            let timerCell3:UITableViewCell = self.tableView.cellForRow(at: indexPaths3)!
            name = (timerCell3.detailTextLabel!.text)!

            mDelegate?.onDidAddAlarmAction(timer, repeatStatus: repeatStatus, name: name)
            _ = self.navigationController?.popViewController(animated: true)
        }

    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        switch ((indexPath as NSIndexPath).section){
        case 0: break

        case 1:
            if((indexPath as NSIndexPath).row == 1){
                if((UIDevice.current.systemVersion as NSString).floatValue >= 8.0){
                    let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!

                    let actionSheet:ActionSheetView = ActionSheetView(title: NSLocalizedString("add_alarm_label", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                    actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                    actionSheet.addTextField(configurationHandler: { (labelText:UITextField) -> Void in
                        labelText.text = selectedCell.detailTextLabel?.text
                    })

                    let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action:UIAlertAction) -> Void in

                    })
                    actionSheet.addAction(alertAction)

                    let alertAction1:UIAlertAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) -> Void in
                        let labelText:UITextField = actionSheet.textFields![0]
                        selectedCell.detailTextLabel?.text = labelText.text
                    })
                    actionSheet.addAction(alertAction1)
                    self.present(actionSheet, animated: true, completion: nil)
                }else{
                    selectedIndexPath = indexPath;
                    let actionSheet:UIAlertView = UIAlertView(title: NSLocalizedString("add_alarm_label", comment: ""), message: "", delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), otherButtonTitles: NSLocalizedString("Add", comment: ""))
                    actionSheet.alertViewStyle = UIAlertViewStyle.plainTextInput
                    actionSheet.show()
                }
            }

        default: break 
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch (section){
        case 0:
            return 1
        case 1:
            return 2
        default: return 1;
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if((indexPath as NSIndexPath).section == 0){
            var cellHeight:CGFloat = CGFloat(UserDefaults.standard.double(forKey: "k\(#file)HeightForDatePickerView"))
            if cellHeight == 0 {
                cellHeight = AddAlarmTableViewCell.factory().frame.height
                UserDefaults.standard.set(Double(cellHeight), forKey: "k\(#file)HeightForDatePickerView")
            }
            return cellHeight
        }else{
            return 45.0
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ((indexPath as NSIndexPath).section){
        case 0:
            return AddAlarmView.addAlarmTimerTableViewCell(indexPath, tableView: tableView, timer:timer)
        case 1:
            let titleArray:[String] = ["Repeat","Label"]
            if((indexPath as NSIndexPath).row == 0){
                let cell = AddAlarmView.systemTableViewCell(indexPath, tableView: tableView, title: titleArray[(indexPath as NSIndexPath).row],delegate: self)
                return cell
            }else if(indexPath.row == 1) {
                let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "SystemLabelCell")
                cell.textLabel?.text = NSLocalizedString("\(titleArray[(indexPath as NSIndexPath).row])", comment: "")
                cell.textLabel?.font = UIFont(name: "Raleway", size: 17)
                cell.detailTextLabel?.text = name
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell.selectionStyle = UITableViewCellSelectionStyle.none;
                cell.preservesSuperviewLayoutMargins = false;
                cell.separatorInset = UIEdgeInsets.zero;
                cell.layoutMargins = UIEdgeInsets.zero;
                cell.selectionStyle = UITableViewCellSelectionStyle.none;
                if !AppTheme.isTargetLunaR_OR_Nevo() {
                    cell.backgroundColor = UIColor.getGreyColor()
                    cell.tintColor = UIColor.getLightBaseColor()
                    cell.contentView.backgroundColor = UIColor.getGreyColor()
                    cell.textLabel?.textColor = UIColor.white
                }
                
                return cell
            }
        default: return UITableViewCell();
        }
        return UITableViewCell();
    }


    // MARK: - UIAlertViewDelegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int){
        let selectedCell:UITableViewCell = tableView.cellForRow(at: selectedIndexPath!)!
        let labelText:UITextField = alertView.textField(at: 0)!
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
