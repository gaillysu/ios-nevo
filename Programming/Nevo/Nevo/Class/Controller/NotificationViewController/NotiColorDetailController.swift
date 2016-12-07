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
    var notification: NotificationSetting?
    lazy var model: MEDNotificationColor = {
        return MEDNotificationColor.factory(name: "Default Name", color: "#7ED8D1", notificationID: self.notification!.getPacket())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rightItem = UIBarButtonItem.init(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = rightItem
        
        let colorPickerView = MSColorSelectionView()
        let footerView = UIView()
        footerView.addSubview(colorPickerView)
        footerView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        colorPickerView.snp.makeConstraints { (v) in
            v.top.equalTo(64)
            v.trailing.equalTo(50)
            v.leading.equalTo(50)
            v.height.equalTo(colorPickerView.snp.width)
        }
        tableView.tableFooterView = footerView
        
        if notificationColor != nil {
            model = notificationColor!
        }
        
        colorPickerView.color = UIColor.init(rgba: model.color)
        
        colorPickerView.setSelectedIndex(.HSB, animated: false)
        colorPickerView.delegate = self
        
        viewDefaultColorful()
    }
}

extension NotiColorDetailController {
    @objc func save() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(model, update: true)
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
        let cell: NotiColorEditableCell = NotiColorEditableCell()
        
        cell.model = model
        
        cell.textField.text = model.name
        cell.dotImageView.image = UIImage.dotImageWith(color: UIColor.init(rgba: model.color), size: CGSize(width: 100, height: 100))
        
        cell.viewDefaultColorful()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
