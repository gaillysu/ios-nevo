//
//  MEDColorfulLooking
//  Nevo
//
//  Created by Quentin on 4/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

/// 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧
///
/// Introduction: The views & viewControllers all have a default behavior, call the `viewDefaultColorful()` method to make them colorful. 
///
/// Maybe use class `apptheme` is a better way, it would be more clear, but need more codes too.
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

// MARK: -
// MARK: -
// MARK: - UIViewController
extension MEDColorfulLooking where Self: UIViewController {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getLightBaseColor()
        } else {
            view.backgroundColor = UIColor.white
        }
    }
}

extension MEDColorfulLooking where Self: UITabBarController {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            tabBar.tintColor = UIColor.getBaseColor()
            tabBar.isTranslucent = false
            tabBar.backgroundColor = UIColor.getGreyColor()
            tabBar.barTintColor = UIColor.getGreyColor()
        } else {
            tabBar.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            tabBar.isTranslucent = false
        }
    }
}

extension MEDColorfulLooking where Self: UINavigationController {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            navigationBar.lt_setBackgroundColor(UIColor.getLunarTabBarColor())
            navigationBar.tintColor = UIColor.getBaseColor()
            
            if var naviTitleAttrs = navigationController?.navigationBar.titleTextAttributes {
                naviTitleAttrs[NSForegroundColorAttributeName] = UIColor.white
            } else {
                navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
            }
        } else {
            navigationBar.lt_setBackgroundColor(UIColor.white)
            navigationBar.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
    }
}

extension MEDColorfulLooking where Self: UITableViewController {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            tableView.backgroundColor = UIColor.getLightBaseColor()
        }
    }
}

// MARK: -
// MARK: -
// MARK: - UIView
extension MEDColorfulLooking where Self: UIView {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            backgroundColor = UIColor.getLightBaseColor()
        }
    }
}

extension MEDColorfulLooking where Self: UITableView {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo(){
            backgroundColor = UIColor.getLightBaseColor()
            /// Seperator color
        }
    }
}

extension MEDColorfulLooking where Self: UITableViewCell {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            backgroundColor = UIColor.getGreyColor()
            contentView.backgroundColor = UIColor.getGreyColor()
            textLabel?.textColor = UIColor.white
            detailTextLabel?.textColor = UIColor.white
        }
    }
}

extension MEDColorfulLooking where Self: UICollectionView {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo(){
            backgroundColor = UIColor.getLightBaseColor()
        }
    }
}

extension MEDColorfulLooking where Self: UICollectionViewCell {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            backgroundColor = UIColor.getGreyColor()
            contentView.backgroundColor = UIColor.getGreyColor()
        }
    }
}

extension MEDColorfulLooking where Self: UIButton {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            backgroundColor = UIColor.clear
            setTitleColor(UIColor.white, for: .normal)
        }
    }
}

extension MEDColorfulLooking where Self: UILabel {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            backgroundColor = UIColor.clear
            textColor = UIColor.white
        }
    }
}

extension MEDColorfulLooking where Self: UISwitch {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            tintColor = UIColor.getBaseColor()
            onTintColor = UIColor.getBaseColor()
        } else {
            tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
    }
}

extension MEDColorfulLooking where Self: UITextField {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            backgroundColor = UIColor.getGreyColor()
            textColor = UIColor.white
            tintColor = UIColor.white
            
            if value(forKeyPath: "_placeholderLabel.textColor") != nil {
                setValue(UIColor(white: 1, alpha: 0.7), forKeyPath: "_placeholderLabel.textColor")
            }
        }
    }
}

extension MEDColorfulLooking where Self: UISegmentedControl {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            tintColor = UIColor.getBaseColor()
        }
    }
}

extension MEDColorfulLooking where Self: UIActivityIndicatorView {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            color = UIColor.white
            tintColor = UIColor.white
        }
    }
}

// MARK: -
// MARK: -
// MARK: - NSObject
extension MEDColorfulLooking where Self: UIBarButtonItem {
    public func viewDefaultColorful() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            tintColor = UIColor.getBaseColor()
        } else {
            tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
    }
}

extension MEDColorfulLooking where Self: UIAlertAction {
    public func viewDefaultColorful() {
        let titleTextColor = AppTheme.isTargetLunaR_OR_Nevo() ? AppTheme.NEVO_SOLAR_YELLOW() : UIColor.getBaseColor()
        if value(forKey: "_titleTextColor") != nil {
            setValue(titleTextColor, forKey: "_titleTextColor")
        }
        if value(forKey: "titleTextColor") != nil {
            setValue(titleTextColor, forKey: "titleTextColor")
        }
    }
}
