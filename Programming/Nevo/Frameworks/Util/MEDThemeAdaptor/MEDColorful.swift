//
//  MEDColorfulLooking
//  Nevo
//
//  Created by Quentin on 4/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

/// 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧
/// 
/// Introduction: The views & viewControllers all have a default behavior, call the `viewDefaultColorful()` method， if you want them more colorful, u should do it yourself.
///
/// 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧

import UIKit

public protocol MEDColorfulLooking  {
    func viewDefaultColorful()
}

extension MEDColorfulLooking where Self: NSObject {
    public func viewDefaultColorful() {}
}

extension NSObject: MEDColorfulLooking {}

// MARK: - UIViewController
extension MEDColorfulLooking where Self: UIViewController {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.view.backgroundColor = UIColor.getLightBaseColor()
            
            self.tabBarController?.tabBar.tintColor = UIColor.getBaseColor()
            self.tabBarController?.tabBar.isTranslucent = false
            self.tabBarController?.tabBar.backgroundColor = UIColor.getGreyColor()
            self.tabBarController?.tabBar.barTintColor = UIColor.getGreyColor()
            
            self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.getLunarTabBarColor())
            self.navigationController?.navigationBar.tintColor = UIColor.getBaseColor()
            
            if var naviTitleAttrs = navigationController?.navigationBar.titleTextAttributes {
                naviTitleAttrs[NSForegroundColorAttributeName] = UIColor.white
            } else {
                navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
            }
            
        } else {
            self.tabBarController?.tabBar.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            self.tabBarController?.tabBar.isTranslucent = false
            
            self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.white)
            self.navigationController?.navigationBar.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
    }
}

// MARK: - UITableViewController
extension MEDColorfulLooking where Self: UITableViewController {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.tableView.backgroundColor = UIColor.getLightBaseColor()
            
            /// TODO 2016-11-04
            ///
            /// Discussion: tableview's separatorColor on lunar maybe is supposed to be a light-color
            self.tableView.separatorColor = UIColor.getWhiteBaseColor()
        } else {
        }
    }
}

// MARK: - UITabelView
extension MEDColorfulLooking where Self: UITableView {
    public func viewDefaultColorful() {
        self.backgroundColor = UIColor.getLightBaseColor()
    }
}

// MARK: - UITableViewCell
extension MEDColorfulLooking where Self: UITableViewCell {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.backgroundColor = UIColor.getGreyColor()
            self.contentView.backgroundColor = UIColor.getGreyColor()
        }
    }
}

// MARK: - UIButton
extension MEDColorfulLooking where Self: UIButton {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.backgroundColor = UIColor.getGreyColor()
            self.setTitleColor(UIColor.white, for: .normal)
        }
    }
}

// MARK: - UILabel
extension MEDColorfulLooking where Self: UILabel {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.backgroundColor = UIColor.getGreyColor()
            self.textColor = UIColor.white
        }
    }
}

// MARK: - UISwitch
extension MEDColorfulLooking where Self: UISwitch {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.tintColor = UIColor.getBaseColor()
            self.onTintColor = UIColor.getBaseColor()
            self.backgroundColor = UIColor.getGreyColor()
        } else {
            self.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            self.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
    }
}

// MARK: - UIBarButtonItem
extension MEDColorfulLooking where Self: UIBarButtonItem {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.tintColor = UIColor.getBaseColor()
        } else {
            self.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
    }
}

// MARK: - UISegmentedControl
extension MEDColorfulLooking where Self: UISegmentedControl {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.tintColor = UIColor.getBaseColor()
        }
    }
}
