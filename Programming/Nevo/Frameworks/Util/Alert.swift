//
//  Alert.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 17/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

open class Alert: NSObject {
    
    class func Warning(_ delegate: UIViewController, message: String) {
        let alert = ActionSheetView(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        delegate.present(alert, animated: true, completion: nil)
    }
    
}
