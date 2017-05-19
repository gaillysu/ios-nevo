//
//  BluetoothDurationViewController.swift
//  Nevo
//
//  Created by Karl-John Chow on 4/5/2017.
//  Copyright © 2017 Nevo. All rights reserved.
//

import UIKit
import MSCellAccessory

class BluetoothScanDurationViewController: UIViewController {

    let identifier = "UITableViewCellStyle"
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let presets = [2, 5, 10, 15, 20, 30, 40, 50, 60]
    fileprivate var selectedScanDuration = UserDefaults.standard.getDurationSearch()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scan Duration"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
    }
}
extension BluetoothScanDurationViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = presets.index(of: selectedScanDuration){
            tableView.cellForRow(at: IndexPath(row: index, section: 0))?.accessoryView = nil
        }
        tableView.cellForRow(at: indexPath)?.accessoryView = MSCellAccessory.init(type: FLAT_CHECKMARK, color: UIColor.getBaseColor())
        let minutes = presets[indexPath.row]
        selectedScanDuration = minutes
        UserDefaults.standard.setDurationSearch(version: minutes)
        tableView.deselectRow(at: indexPath, animated: true)
        ConnectionManager.manager.updateBluetoothScanPeriod()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nevo Scan Duration"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "When the watch gets disconnected it will scan for the selected duration. Note that the watch will drain more battery when it scans longer. We suggest not to let it scan for longer then 15 minutes"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        let time = presets[indexPath.row]
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        if time == selectedScanDuration{
            cell?.accessoryView = MSCellAccessory.init(type: FLAT_CHECKMARK, color: UIColor.getBaseColor())
        }
        cell?.textLabel?.text = time.timeRepresentation()
        return cell!
    }
}
