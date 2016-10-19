//
//  Notifications.swift
//  Nevo
//
//  Created by Karl-John Chow on 18/10/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import UIKit
import RealmSwift

class Notifications: Object {

    dynamic var clock:Int = 0
    
    dynamic var notificationType = ""
    
    dynamic var enabled = false

    func fromNotificationModel (notificationModel: UserNotification){
        self.clock = notificationModel.clock
        self.notificationType = notificationModel.NotificationType
        self.enabled = notificationModel.status
    }
    //Nuffield health
}
