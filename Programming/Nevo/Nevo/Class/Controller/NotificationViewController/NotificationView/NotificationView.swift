//
//  NotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/30.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import Kingfisher

class NotificationView: UITableView {

    func bulidNotificationView(_ navigation:UINavigationItem){
        navigation.title = NSLocalizedString("Notifications", comment: "")
    }
}
