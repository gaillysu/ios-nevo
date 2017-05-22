//
//  AddAlarmController.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/27.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol AddAlarmDelegate {
    func onDidAddAlarmAction(_ timer: TimeInterval, repeatStatus: Bool, name: String)
    func onDidAddAlarmAction(_ timer: TimeInterval, name: String, repeatNumber: Int, alarmType: Int)
}

class AddAlarmController: UITableViewController, ButtonManagerCallBack, UIAlertViewDelegate {

    var mDelegate:AddAlarmDelegate?

    var timer: TimeInterval = 0.0
    var repeatStatus: Bool = false
    var name: String = ""
    
    fileprivate var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDefaultColorful()
        
        tableView.register(UINib(nibName:"AddAlarmTableViewCell", bundle: nil), forCellReuseIdentifier: "AddAlarm_Date_identifier")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(controllManager(_:)))
        
        tableView.isScrollEnabled = false
    }
}

// MARK: - Touch events
extension AddAlarmController {
    
    func controllManager(_ sender:AnyObject) {

        var indexPaths = IndexPath(row: 0, section: 0)
        
        var cell = tableView.cellForRow(at: indexPaths)!
        
        for view in cell.contentView.subviews {
        
            if(view.isKind(of: UIDatePicker.classForCoder())){
                let picker = view as! UIDatePicker
                timer = picker.date.timeIntervalSince1970
            }
        }

        indexPaths = IndexPath(row: 0, section: 1)
        
        cell = tableView.cellForRow(at: indexPaths)!
        
        if let view = cell.accessoryView, let s = view as? UISwitch{
            repeatStatus = s.isOn
        }

        indexPaths = IndexPath(row: 1, section: 1)
        cell = tableView.cellForRow(at: indexPaths)!
        
        name = (cell.detailTextLabel!.text)!

        mDelegate?.onDidAddAlarmAction(timer, repeatStatus: repeatStatus, name: name)
        
        _ = navigationController?.popViewController(animated: true)
    }
}

// MARK: - Tableview delegate
extension AddAlarmController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        switch (indexPath.section) {
        
        case 0: break

        case 1:
            if(indexPath.row == 1){
                let selectedCell = tableView.cellForRow(at: indexPath)!

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
                
                cancelAction.setValue(UIColor.baseColor, forKey: "titleTextColor")
                confirmAction.setValue(UIColor.baseColor, forKey: "titleTextColor")
                
                present(actionSheet, animated: true, completion: nil)
            }

        default: break 
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return indexPath.section == 0 ? 235 : 45
    }
}

// MARK: - Tableview datasource
extension AddAlarmController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.section) {
        
        case 0:
            return AddAlarmDatePickerCell.reusableCell(tableView: tableView, time: timer)
        
        case 1:
            
            let titleArray = ["Repeat", "Label"]
            
            if(indexPath.row == 0) {
                let cell = AddAlarmCell.reusableCell(tableView: tableView, title: titleArray[indexPath.row])
                
                return cell
            }else if (indexPath.row == 1) {
                let cell = AddAlarmCell.reusableCell(tableView: tableView, title: titleArray[indexPath.row])
                cell.detailTextLabel?.text = name
                return cell
            }
        default:
            break
        }
        
        return UITableViewCell();
    }
}
