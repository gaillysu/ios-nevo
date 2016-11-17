//
//  NewAddAlarmController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/4.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import UIKit

class NewAddAlarmController: UITableViewController,ButtonManagerCallBack,SelectedRepeatDelegate,SelectedSleepTypeDelegate {
        
    var mDelegate:AddAlarmDelegate?

    var timer:TimeInterval = 0.0
    var repeatStatus:Bool = false
    var name:String = ""
    var repeatSelectedIndex:Int = 0
    var alarmTypeIndex:Int = 0
    
    var isOverdue:Bool = false
    
    fileprivate let repeatDayArray:[String] = [
        NSLocalizedString("Sunday", comment: ""),
        NSLocalizedString("Monday", comment: ""),
        NSLocalizedString("Tuesday", comment: ""),
        NSLocalizedString("Wednesday", comment: ""),
        NSLocalizedString("Thursday", comment: ""),
        NSLocalizedString("Friday", comment: ""),
        NSLocalizedString("Saturday", comment: "")]
    
    init() {
        super.init(nibName: "NewAddAlarmController", bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("add_alarm", comment: "")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(controllManager(_:)))
        
        self.tableView.register(UINib(nibName: "NewAddAlarmHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "identifier_header")
        self.tableView.register(UINib(nibName: "AlarmTypeCell", bundle: nil), forCellReuseIdentifier: "AlarmType_identifier")
        self.tableView.register(UINib(nibName:"AddAlarmTableViewCell", bundle: nil), forCellReuseIdentifier: "AddAlarm_Date_identifier")
        
        addTipsLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.subviewsSatisfy(theCondition: { (v) -> (Bool) in
            return v.frame.height == 0.5
            }, do: { (v) in
                v.isHidden = true
        })
    }
    
    override func viewDidLayoutSubviews() {
        print("============================\n\(self.tableView.contentSize)\n=============================\n")
        super.viewDidLayoutSubviews()
    }
    
    func controllManager(_ sender:AnyObject) {
        if(sender.isKind(of: UISwitch.classForCoder())){

        }else{
            let indexPaths:IndexPath = IndexPath(row: 0, section: 1)
            let timerCell:UITableViewCell = self.tableView.cellForRow(at: indexPaths)!
            for datePicker in timerCell.contentView.subviews{
                if(datePicker.isKind(of: UIDatePicker.classForCoder())){
                    let picker:UIDatePicker = datePicker as! UIDatePicker
                    timer = picker.date.timeIntervalSince1970
                }
            }

            let indexPaths3:IndexPath = IndexPath(row: 1, section: 2)
            let timerCell3:UITableViewCell = self.tableView.cellForRow(at: indexPaths3)!
            name = (timerCell3.detailTextLabel!.text)!

            // 2016-10-28 new feature, adjust the alarm's logic
            let nowDate:Date = Date()
            let nowDateTime:Int = nowDate.hour * 60 + nowDate.minute
            let pickerDate:Date = Date(timeIntervalSince1970: timer)
            let pickerTimer:Int = pickerDate.hour * 60 + pickerDate.minute
            
            var isEditing:Bool = false
            for controller in self.navigationController!.viewControllers {
                if controller is AlarmClockController {
                    isEditing = controller.isEditing
                }
            }
            if !isEditing {
                if nowDateTime > pickerTimer {
                    repeatSelectedIndex = Date.tomorrow().weekday
                } else {
                    repeatSelectedIndex = nowDate.weekday
                }
            }
            
            mDelegate?.onDidAddAlarmAction(timer, name: name, repeatNumber: repeatSelectedIndex, alarmType: alarmTypeIndex)
            self.navigationController!.popViewController(animated: true)
        }

    }

    // MARK: - SelectedRepeatDelegate
    func onSelectedRepeatAction(_ value:Int,name:String){
        let indexPath:IndexPath = IndexPath(row: 0, section: 2)
        let cell = self.tableView.cellForRow(at: indexPath)
        if(cell != nil) {
            cell!.detailTextLabel?.text = name
        }
        repeatSelectedIndex = value+1
    }

    // MARK: - SelectedSleepTypeDelegate
    func onSelectedSleepTypeAction(_ value:Int,name:String){
        let indexPath:IndexPath = IndexPath(row: 0, section: 2)
        let cell = self.tableView.cellForRow(at: indexPath)
        if(cell != nil) {
            cell!.detailTextLabel?.text = name
        }
        alarmTypeIndex = value
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        switch (indexPath.section){
        case 0: break

        case 2:
            if(indexPath.row == 0){
                let repeatControll:RepeatViewController = RepeatViewController()
                repeatControll.selectedDelegate = self
                repeatControll.selectedIndex = repeatSelectedIndex
                self.navigationController?.pushViewController(repeatControll, animated: true)
            }

            if(indexPath.row == 1){
                let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
                
                let actionSheet:ActionSheetView = ActionSheetView(title: NSLocalizedString("add_alarm_label", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                actionSheet.addTextField(configurationHandler: { (labelText:UITextField) -> Void in
                    labelText.text = selectedCell.detailTextLabel?.text
                })
                
                let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action:UIAlertAction) -> Void in
                    
                })
                actionSheet.addAction(alertAction)
                
                let alertAction1:UIAlertAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) -> Void in
                    let labelText:UITextField = actionSheet.textFields![0]
                    selectedCell.detailTextLabel?.text = labelText.text
                    selectedCell.layoutSubviews()
                })
                // MARK: - APPTHEME ADJUST
                if !AppTheme.isTargetLunaR_OR_Nevo() {
                    alertAction.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
                    alertAction1.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
                }else{
                    alertAction.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
                    alertAction1.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
                }
                actionSheet.addAction(alertAction1)
                self.present(actionSheet, animated: true, completion: nil)
            }

        default: break
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section){
        case 0:
            return 0
        case 1:
            return 1
        default: return 2;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 45
        }else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 23
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if((indexPath as NSIndexPath).section == 1){
            
            var cellHeight:CGFloat = CGFloat(UserDefaults.standard.double(forKey: "k\(#file)HeightForDatePickerView"))
            if cellHeight != 0 {
            } else {
                cellHeight = AddAlarmTableViewCell.factory().frame.height
                UserDefaults.standard.set(Double(cellHeight), forKey: "k\(#file)HeightForDatePickerView")
            }
            return cellHeight
        }else{
            return 45.0
        }

    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let  headerCell:NewAddAlarmHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "identifier_header") as! NewAddAlarmHeader
            headerCell.alarmType.selectedSegmentIndex = alarmTypeIndex
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                headerCell.alarmType.tintColor = UIColor.getBaseColor()
                headerCell.backgroundColor = UIColor.getLunarTabBarColor()
                headerCell.contentView.backgroundColor = UIColor.getLunarTabBarColor()
                headerCell.alarmType.backgroundColor = UIColor.getLunarTabBarColor()
            }
            
            headerCell.actionCallBack = {
                (sender) -> Void in
                let segment:UISegmentedControl = sender as! UISegmentedControl
                self.alarmTypeIndex = segment.selectedSegmentIndex
            }
            return headerCell
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ((indexPath as NSIndexPath).section){
        case 1:
            let cell:AddAlarmTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddAlarm_Date_identifier", for: indexPath) as! AddAlarmTableViewCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
            cell.selectionStyle = UITableViewCellSelectionStyle.none;
            cell.backgroundColor = UIColor.white
            cell.contentView.backgroundColor = UIColor.clear
            if(timer > 0){
                cell.datePicker.date = Date(timeIntervalSince1970: timer)
            }
            return cell
        case 2:
            let titleArray:[String] = ["Repeat","Label"]
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmType_identifier",for: indexPath)
            cell.preservesSuperviewLayoutMargins = false;
            cell.separatorInset = UIEdgeInsets.zero;
            cell.layoutMargins = UIEdgeInsets.zero;
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            cell.selectionStyle = UITableViewCellSelectionStyle.none;
            if(indexPath.row == 0) {
                cell.textLabel?.text = NSLocalizedString("\(titleArray[indexPath.row])", comment: "")
                cell.detailTextLabel?.text = repeatDayArray[repeatSelectedIndex]
            }else if(indexPath.row == 1) {
                cell.textLabel?.text = NSLocalizedString("\(titleArray[indexPath.row])", comment: "")
                cell.detailTextLabel?.text = name
            }
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                cell.backgroundColor = UIColor.getGreyColor()
            }
            
            return cell
        default: return UITableViewCell();
        }
    }
    
    fileprivate func addTipsLabel() {
        if self.tableView.tableFooterView == nil {
            let view = UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-20, height: 120))
            
            let tipsString:String = NSLocalizedString(AppTheme.isTargetLunaR_OR_Nevo() ? "tips_content" : "tips_content_lunar", comment: "")
            let tipsLabel:UILabel = UILabel(frame: CGRect(x: 10,y: 0,width: UIScreen.main.bounds.size.width-20,height: 120))
            tipsLabel.backgroundColor = UIColor.clear
            tipsLabel.numberOfLines = 0
            tipsLabel.text = tipsString
            tipsLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
            
            
            // MARK:- THEME ADJUST
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                //                self.tableView.backgroundColor = UIColor.getGreyColor()
                self.tableView.backgroundColor = UIColor.getLightBaseColor()
                tipsLabel.textColor = UIColor.white
                let attributeDict:[String : AnyObject] = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 16)!]
                let AttributedStr:NSMutableAttributedString = NSMutableAttributedString(string: tipsString, attributes: attributeDict)
                AttributedStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.getBaseColor(), range: NSMakeRange(0, 5))
                tipsLabel.attributedText = AttributedStr
            }else{
                let attributeDict:[String : AnyObject] = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 16)!]
                let AttributedStr:NSMutableAttributedString = NSMutableAttributedString(string: tipsString, attributes: attributeDict)
                AttributedStr.addAttribute(NSForegroundColorAttributeName, value: AppTheme.NEVO_SOLAR_YELLOW(), range: NSMakeRange(0, 5))
                tipsLabel.attributedText = AttributedStr
            }
            
            view.addSubview(tipsLabel)
            self.tableView.tableFooterView = view
        }
    }
}

