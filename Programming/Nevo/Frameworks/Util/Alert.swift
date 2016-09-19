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
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        delegate.presentViewController(alert, animated: true, completion: nil)
    }
    
}
