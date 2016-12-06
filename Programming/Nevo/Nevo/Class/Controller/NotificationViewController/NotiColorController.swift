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
    
    var notification: NotificationSetting?
    var notificationColor: MEDNotificationColor?
    fileprivate var notificationColors: [MEDNotificationColor] = []
    
    let realm: Realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let results = realm.objects(MEDNotificationColor.self)
        for model in results {
            notificationColors.append(model)
        }
        
        navigationItem.title = NSLocalizedString("color", comment: "")
        let rightItem: UIBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "edit_icon"), style: .plain, target: self, action: #selector(addNotificationColorItem))
        navigationItem.rightBarButtonItem = rightItem
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "kReusableIdentifier")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

extension NotiColorController {
    @objc func addNotificationColorItem() {
        let controller = NotiColorDetailController()
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension NotiColorController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        try! realm.write {
            let model = notificationColors[indexPath.row]
            model.notificationID = notification!.getPacket()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment:""), handler: { (action, indexPath) in
            try! self.realm.write {
                self.realm.delete(self.notificationColors[indexPath.row])
            }
            self.tableView.reloadData()
        })
        let editAction = UITableViewRowAction(style: .default, title: NSLocalizedString("Edit", comment:""), handler: { (action, indexPath) in
            let controller = NotiColorDetailController()
            controller.notificationColor = notificationColors[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        })

        deleteAction.backgroundColor = UIColor.getBaseColor()
        editAction.backgroundColor = UIColor.getBaseColor()
        return [deleteAction, editAction]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationColors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kReusableIdentifier" ,for: indexPath)
        
        let model = notificationColors[indexPath.row]
        
        cell.textLabel?.text = model.name
        cell.imageView?.image = UIImage.dotImageWith(color: UIColor.init(rgba: model.color), size: CGSize(width: 100, height: 100))
        
        if notificationColor?.notificationID == notification?.getPacket() {
            let image = UIImage(named: "notifications_check")
            cell.accessoryView = UIImageView(image: image)
        } else {
            cell.accessoryView = nil
        }
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            cell.backgroundColor = UIColor.getGreyColor()
            cell.contentView.backgroundColor = UIColor.getGreyColor()
            cell.textLabel?.textColor = UIColor.white
        }
        
        return cell
    }
}
