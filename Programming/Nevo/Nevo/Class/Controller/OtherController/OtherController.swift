//
//  OtherController.swift
//  Nevo
//
//  Created by Cloud on 2016/12/12.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class OtherController: UITableViewController {
    fileprivate var itemArray:[String] = ["goal","unit"]
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
        self.tableView.register(UINib(nibName: "UnitTableViewCell", bundle: nil), forCellReuseIdentifier: "unit_identifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let textValue = itemArray[indexPath.section]
        if textValue == "goal" {
            let cell                    = tableView.dequeueReusableCell(withIdentifier: "other_identifier", for: indexPath)
            cell.textLabel?.text        = NSLocalizedString(textValue, comment: "")
            cell.accessoryType          = UITableViewCellAccessoryType.disclosureIndicator
            cell.viewDefaultColorful()
            return cell
        }else{
            let cell:UnitTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "unit_identifier", for: indexPath) as! UnitTableViewCell
            cell.titleLabel.text        = NSLocalizedString(textValue, comment: "")
            cell.titleLabel.textColor   = UIColor.white
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
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
