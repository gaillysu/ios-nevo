//
//  OtherController.swift
//  Nevo
//
//  Created by Cloud on 2016/12/12.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class OtherController: UITableViewController {
    fileprivate var itemArray:[String] = ["goal","unit", "home_local"]
    //imperial
    init() {
        super.init(nibName: "OtherController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("other_settings", comment: "")
        
        self.tableView.viewDefaultColorful()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.tableView.separatorColor = UIColor.getLightBaseColor()
        }
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor.lightGray
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "other_identifier")
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if AppTheme.isTargetLunaR_OR_Nevo() {
            return itemArray.count - 1
        } else {
            return itemArray.count
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let textValue = itemArray[indexPath.section]
        if textValue == "goal" {
            let cell                    = tableView.dequeueReusableCell(withIdentifier: "other_identifier", for: indexPath)
            cell.textLabel?.font        = UIFont(name: "Raleway", size: 17.0)
            cell.textLabel?.text        = NSLocalizedString(textValue, comment: "")
            cell.accessoryType          = UITableViewCellAccessoryType.disclosureIndicator
            cell.viewDefaultColorful()
            return cell
        }else if textValue == "unit" {
            let cell:UnitTableViewCell  = UnitTableViewCell.getCell(with: tableView, type: .unit)
            cell.titleLabel.text        = NSLocalizedString(textValue, comment: "")
            cell.viewDefaultColorful()
            cell.separatorInset         = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
            return cell
        } else {
            let cell:UnitTableViewCell  = UnitTableViewCell.getCell(with: tableView, type: .syncTime)
            cell.titleLabel.text        = NSLocalizedString(textValue, comment: "")
            cell.viewDefaultColorful()
            cell.separatorInset         = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
            return cell
        }
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        let textValue = itemArray[indexPath.section]
        if textValue == "goal" {
            let presetView:PresetTableViewController = PresetTableViewController()
            presetView.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(presetView, animated: true)
        }
    }
}
