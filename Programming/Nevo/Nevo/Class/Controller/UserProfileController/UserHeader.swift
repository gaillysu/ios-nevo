//
//  UserHeader.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/19.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class UserHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var avatarView: UIButton!
    
    
    
    @IBAction func uploadAction(_ sender: AnyObject) {
        
        let alert:UIAlertController = UIAlertController(title: "Choose picture source", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1:UIAlertAction = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.default) { (action) in
            
        }
        action1.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
        alert.addAction(action1)
        
        let action2:UIAlertAction = UIAlertAction(title: "Choose from Camera", style: UIAlertActionStyle.default) { (action) in
            
        }
        action2.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
        alert.addAction(action2)
        
        let action3:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            
        }
        action3.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
        alert.addAction(action3)
        viewController()?.present(alert, animated: true, completion: nil)
        
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
