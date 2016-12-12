//
//  NotiColorController
//  Nevo
//
//  Created by Quentin on 6/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift
import UIColor_Hex_Swift

class NotiColorController: UITableViewController {
    
    var notification: MEDUserNotification?
    var notificationColor: MEDNotificationColor?
    fileprivate var notificationColors: [MEDNotificationColor] {
        return MEDNotificationColor.getAll() as! [MEDNotificationColor]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("color", comment: "")
        
        let rightItem: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addNotificationColorItem))
        
        navigationItem.rightBarButtonItem = rightItem
        
        tableView.tableFooterView = UIView()
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "kReusableIdentifier")
        
        viewDefaultColorful()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

extension NotiColorController {
    @objc func addNotificationColorItem() {
        let controller = NotiColorDetailController(style: .grouped)
        controller.notification = self.notification
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension NotiColorController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let realm = try! Realm()
        try! realm.write {
            notification?.colorValue = notificationColors[indexPath.row].color
            notification?.colorName = notificationColors[indexPath.row].name
            notification?.colorKey = notificationColors[indexPath.row].key
            tableView.reloadData()
        }
         AppDelegate.getAppDelegate().deleteAllLunaRNotfication()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment:""), handler: { (action, indexPath) in
            let realm = try! Realm()
            try! realm.write {
                realm.delete(self.notificationColors[indexPath.row])
            }
            self.tableView.reloadData()
        })
        let editAction = UITableViewRowAction(style: .default, title: NSLocalizedString("Edit", comment:""), handler: { (action, indexPath) in
            let controller = NotiColorDetailController(style: .grouped)
            controller.notification = self.notification
            controller.notificationColor = self.notificationColors[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        })
        
        editAction.backgroundColor = UIColor.getBaseColor()
        return [deleteAction, editAction]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationColors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kReusableIdentifier" ,for: indexPath)
        cell.selectionStyle = .none
        
        let notificationColor = notificationColors[indexPath.row]
        
        cell.textLabel?.text = notificationColor.name
        cell.imageView?.image = UIImage.dotImageWith(color: UIColor.init(rgba: notificationColor.color), backgroundColor: UIColor.getGreyColor(), size: CGSize(width: 15, height: 15))
        
        if notificationColor.key == notification!.colorKey {
            let image = UIImage(named: "notifications_check")
            cell.accessoryView = UIImageView(image: image)
        } else {
            cell.accessoryView = nil
        }
        
        cell.viewDefaultColorful()
        
        return cell
    }
}
