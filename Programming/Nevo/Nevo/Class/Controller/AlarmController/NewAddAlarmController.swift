//
//  NewAddAlarmController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/4.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import UIKit

class NewAddAlarmController: UITableViewController {
        
    var mDelegate:AddAlarmDelegate?

    var timer: TimeInterval = 0.0
    var repeatStatus: Bool = false
    var name: String = ""
    var repeatSelectedIndex: Int = 1
    var alarmTypeIndex: Int = 0
    
    var isEdited: Bool = false
    
    var isOverdue: Bool = false
    
    let repeatDayArray = [NSLocalizedString("Sunday", comment: ""),
                          NSLocalizedString("Monday", comment: ""),
                          NSLocalizedString("Tuesday", comment: ""),
                          NSLocalizedString("Wednesday", comment: ""),
                          NSLocalizedString("Thursday", comment: ""),
                          NSLocalizedString("Friday", comment: ""),
                          NSLocalizedString("Saturday", comment: "")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDefaultColorful()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(controllManager(_:)))
        
        tableView.register(UINib(nibName: "NewAddAlarmHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "identifier_header")
        
        addTipsLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.allSubviews(do: { (v) in
            v.isHidden = v.frame.height == 0.5
        })
    }
}


// MARK: - Touch Events
extension NewAddAlarmController: ButtonManagerCallBack {
    func controllManager(_ sender:AnyObject) {
        var indexPath = IndexPath(row: 0, section: 1)
        
        var cell = tableView.cellForRow(at: indexPath)!
        for view in cell.contentView.subviews{
            if(view.isKind(of: UIDatePicker.classForCoder())){
                let picker = view as! UIDatePicker
                timer = picker.date.timeIntervalSince1970
            }
        }

        indexPath = IndexPath(row: 1, section: 2)
        cell = tableView.cellForRow(at: indexPath)!
        if let name = cell.detailTextLabel?.text {
            self.name = name
        }

        let nowDate = Date()
        let nowDateTime = nowDate.hour * 60 + nowDate.minute
        let pickerDate = Date(timeIntervalSince1970: timer)
        let pickerTime = pickerDate.hour * 60 + pickerDate.minute
        
        if !isEdited {
            if nowDateTime > pickerTime {
                repeatSelectedIndex = Date.tomorrow().weekday
            } else {
                repeatSelectedIndex = nowDate.weekday
            }
        }
        
        mDelegate?.onDidAddAlarmAction(timer, name: name, repeatNumber: repeatSelectedIndex, alarmType: alarmTypeIndex)
        
        navigationController!.popViewController(animated: true)
    }
}


// MARK: - Tableview delegate
extension NewAddAlarmController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        switch (indexPath.section) {
            
        case 2:
            if indexPath.row == 0 {
                let repeatController = RepeatViewController()
                repeatController.selectedDelegate = self
                
                repeatController.selectedIndex = repeatSelectedIndex - 1
                
                navigationController?.pushViewController(repeatController, animated: true)
                
                isEdited = true
            }

            if indexPath.row == 1 {
                let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
                
                let actionSheet = MEDAlertController(title: NSLocalizedString("add_alarm_label", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                actionSheet.addTextField(configurationHandler: { (labelText:UITextField) -> Void in
                    labelText.text = selectedCell.detailTextLabel?.text
                })
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (_) in
                    
                    self.dismiss(animated: true, completion: nil)
                })
                
                actionSheet.addAction(cancelAction)
                
                let confirmAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default, handler: { (_) in
                    let labelText:UITextField = actionSheet.textFields![0]
                    selectedCell.detailTextLabel?.text = labelText.text
                    
                    self.dismiss(animated: true, completion: nil)
                })
                
                actionSheet.addAction(confirmAction)
                
                cancelAction.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
                confirmAction.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
                
                present(actionSheet, animated: true, completion: nil)
            }

        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "identifier_header") as! NewAddAlarmHeader
            headerCell.alarmType.selectedSegmentIndex = alarmTypeIndex
            
            headerCell.actionCallBack = {
                (sender) -> Void in
                let segment:UISegmentedControl = sender as! UISegmentedControl
                self.alarmTypeIndex = segment.selectedSegmentIndex
            }
            return headerCell
        } else {
            return nil
        }
    }
}

// MARK: - TableView Datasource
extension NewAddAlarmController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 45 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 1 ? 235 : 45
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        
        case 1:
            return AddAlarmDatePickerCell.reusableCell(tableView: tableView, time: timer)
            
        case 2:
            let titleArray = ["Repeat","Label"]
            let cell = AddAlarmCell.reusableCellForNewAlarm(tableView: tableView, title: titleArray[indexPath.row])
            
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = repeatDayArray[repeatSelectedIndex - 1]
            } else if indexPath.row == 1 {
                cell.detailTextLabel?.text = name
            }
            
            return cell
            
        default: return UITableViewCell();
        }
    }
}

// MARK: - SelectedRepeatDelegate
extension NewAddAlarmController: SelectedRepeatDelegate {
    
    func onSelectedRepeatAction(_ value: Int, name: String){
        let indexPath = IndexPath(row: 0, section: 2)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.detailTextLabel?.text = name
        }
        
        repeatSelectedIndex = value + 1
    }
}

// MARK: - Setup Views
extension NewAddAlarmController {
    
    func addTipsLabel() {
        let view = UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 20, height: 120))
        
        let tipsString = NSLocalizedString(AppTheme.isTargetLunaR_OR_Nevo() ? "tips_content" : "tips_content_lunar", comment: "")
        
        let tipsLabel = UILabel(frame: CGRect(x: 10,y: 0, width: UIScreen.main.bounds.size.width - 20, height: 120))
        tipsLabel.viewDefaultColorful()
        
        tipsLabel.numberOfLines = 0
        tipsLabel.text = tipsString
        tipsLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        
        let attributeDict: [String : AnyObject] = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 16)!]
        let attributedStr: NSMutableAttributedString = NSMutableAttributedString(string: tipsString, attributes: attributeDict)
        attributedStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.getBaseColor(), range: NSMakeRange(0, 5))
        tipsLabel.attributedText = attributedStr
        
        view.addSubview(tipsLabel)
        tableView.tableFooterView = view
    }
}

