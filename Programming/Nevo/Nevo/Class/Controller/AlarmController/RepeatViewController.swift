//
//  RepeatViewController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/3.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

protocol SelectedRepeatDelegate {

    func onSelectedRepeatAction(_ value: Int,name: String)
}

class RepeatViewController: UITableViewController {
    
    let repeatDayArray = [NSLocalizedString("Sunday", comment: ""),
                          NSLocalizedString("Monday", comment: ""),
                          NSLocalizedString("Tuesday", comment: ""),
                          NSLocalizedString("Wednesday", comment: ""),
                          NSLocalizedString("Thursday", comment: ""),
                          NSLocalizedString("Friday", comment: ""),
                          NSLocalizedString("Saturday", comment: "")]
    
    var selectedIndex: Int = 0
    var selectedDelegate: SelectedRepeatDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Repeat", comment: "")
        
        tableView.tableFooterView = UIView()
        
//        tableView.contentOffset = CGPoint(x: 0, y: 45)
//        tableView.contentInset = UIEdgeInsets(top: 45, left: 0, bottom: 0, right: 0)
        
        viewDefaultColorful()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.subviewsSatisfy(theCondition: { (v) -> (Bool) in
            return v.frame.height == 0.5
        }, do: { (v) in
            v.isHidden = false
        })
    }
}

// MARK: - TableView Delegate
extension RepeatViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedDelegate?.onSelectedRepeatAction(indexPath.row, name: repeatDayArray[indexPath.row])
        
        navigationController!.popViewController(animated: true)
    }
}

// MARK: - Tableview Datasource
extension RepeatViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repeatDayArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reusableID = "RepeatViewCell_Identifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: reusableID)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: reusableID)
        }
        
        cell!.viewDefaultColorful()
        cell!.separatorInset = .zero
        
        cell!.textLabel?.font = UIFont(name: "Raleway", size: 16)!
        cell!.textLabel?.text = NSLocalizedString(repeatDayArray[indexPath.row], comment: "")
        
        cell!.selectionStyle = .gray
        
        cell?.layoutMargins = .zero
        cell?.preservesSuperviewLayoutMargins = false
        
        if(indexPath.row == selectedIndex) {
            let selectedImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 23))
            selectedImage.contentMode = .scaleAspectFit
            selectedImage.image = UIImage(named: "notifications_check")
            selectedImage.tag = 1500
            cell!.accessoryView = selectedImage
        }
        
        return cell!
    }
}

