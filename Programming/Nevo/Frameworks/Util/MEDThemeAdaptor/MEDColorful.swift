//
//  MEDColorfulLooking
//  Nevo
//
//  Created by Quentin on 4/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

/// 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧
/// 
/// 风格一致的 App 中, 同一控件在`绝大多数`情景下的配色都是一致的, 比如 tableview 的背景色, switch 的 onTintColor, label 的文字颜色, 所以就在这里把这些封装到方法里, 然后在需要它根据 target 改变的时候调用这个方法即可.
///
/// 或许我也可以用 apptheme 类来解决, 那样需要更多的代码量, 但可能会更加清晰.
///
/// Introduction: The views & viewControllers all have a default behavior, call the `viewDefaultColorful()` method to make them colorful. Maybe use class `apptheme` is a better way, it would be more clear, but need more codes too.
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
            onTintColor = UIColor.getBaseColor()
        } else {
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
                setValue(UIColor.gray, forKeyPath: "_placeholderLabel.textColor")
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
