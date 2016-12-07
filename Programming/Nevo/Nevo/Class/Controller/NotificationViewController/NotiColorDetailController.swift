//
//  NotiColorDetailController.swift
//  Nevo
//
//  Created by Quentin on 6/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import SnapKit
import MSColorPicker
import RealmSwift

class NotiColorDetailController: UITableViewController {
    
    var notificationColor: MEDNotificationColor?
    var notification: MEDUserNotification?
    lazy var model: MEDNotificationColor = {
        if let notificationColor = self.notificationColor {
            return MEDNotificationColor.factory(name: notificationColor.name, color: notificationColor.color)
        } else {
            return MEDNotificationColor.factory(name: "Default Name", color: "#7ED8D1")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rightItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = rightItem
        
        tableView.isScrollEnabled = false
        
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 200))
        let colorPickerView = MSColorSelectionView.init(frame: CGRect.init(x: 0, y: 0, width: footerView.frame.width - 50, height: footerView.frame.height))
        
        footerView.addSubview(colorPickerView)
        colorPickerView.center.x = footerView.center.x
        tableView.tableFooterView = footerView
        
        colorPickerView.color = UIColor.init(rgba: model.color)
        colorPickerView.backgroundColor = UIColor.getLightBaseColor()
        colorPickerView.setSelectedIndex(.HSB, animated: false)
        colorPickerView.delegate = self
        
        self.tableView.register(UINib(nibName: "NotiColorEditableCell", bundle: nil), forCellReuseIdentifier: "kNotiColorEditabelCellIdentifier")
        
//        colorPickerView.allSubviews { (v) in
//            if v.isKind(of: MSColorComponentView.self) {
//                (v as! MSColorComponentView).title = ""
//            }
//        }
        viewDefaultColorful()
    }
}

extension NotiColorDetailController {
    @objc func save() {
        let realm = try! Realm()
        try! realm.write {
            if let notificationColor = self.notificationColor {
                notificationColor.color = model.color
                notificationColor.name = model.name
                _ = navigationController?.popViewController(animated: true)
            } else {
                notification?.colorKey = model.key
                realm.add(model, update: true)
                _ = navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension NotiColorDetailController: MSColorViewDelegate {
    func colorView(_ colorView: MSColorView!, didChange color: UIColor!) {
        model.color = color.hexString(false)
        tableView.reloadData()
    }
}

extension NotiColorDetailController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NotiColorEditableCell = tableView.dequeueReusableCell(withIdentifier: "kNotiColorEditabelCellIdentifier", for: indexPath) as! NotiColorEditableCell
        cell.selectionStyle = .none
        
        cell.model = model
        cell.dotImageView.image = UIImage.dotImageWith(color: UIColor.init(rgba: model.color), backgroundColor: UIColor.getGreyColor(), size: CGSize(width: 15, height: 15))
        cell.textField.text = model.name
        
        cell.viewDefaultColorful()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
