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
        view.backgroundColor = UIColor.white
    }
}

extension MEDColorfulLooking where Self: UITabBarController {
    public func viewDefaultColorful() {
        tabBar.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        tabBar.isTranslucent = false
    }
}

extension MEDColorfulLooking where Self: UINavigationController {
    public func viewDefaultColorful() {
        navigationBar.lt_setBackgroundColor(UIColor.white)
        navigationBar.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
    }
}

extension MEDColorfulLooking where Self: UITableViewController {
    public func viewDefaultColorful() {
        
    }
}

// MARK: -
// MARK: -
// MARK: - UIView
extension MEDColorfulLooking where Self: UIView {
    public func viewDefaultColorful() {
        
    }
}

extension MEDColorfulLooking where Self: UITableView {
    public func viewDefaultColorful() {
        
    }
}

extension MEDColorfulLooking where Self: UITableViewCell {
    public func viewDefaultColorful() {
        backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor.white
        textLabel?.textColor = UIColor.black
        detailTextLabel?.textColor = UIColor.black
    }
}

extension MEDColorfulLooking where Self: UICollectionView {
    public func viewDefaultColorful() {
        
    }
}

extension MEDColorfulLooking where Self: UICollectionViewCell {
    public func viewDefaultColorful() {
        
    }
}

extension MEDColorfulLooking where Self: UIButton {
    public func viewDefaultColorful() {
        
    }
}

extension MEDColorfulLooking where Self: UILabel {
    public func viewDefaultColorful() {
        
    }
}

extension MEDColorfulLooking where Self: UISwitch {
    public func viewDefaultColorful() {
        tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
    }
}

extension MEDColorfulLooking where Self: UITextField {
    public func viewDefaultColorful() {
        
    }
}

extension MEDColorfulLooking where Self: UISegmentedControl {
    public func viewDefaultColorful() {
        tintColor = UIColor.getBaseColor()
    }
}

extension MEDColorfulLooking where Self: UIActivityIndicatorView {
    public func viewDefaultColorful() {
        
    }
}

extension MEDColorfulLooking where Self: UIDatePicker {
    public func viewDefaultColorful() {
        backgroundColor = UIColor.clear
    }
}

// MARK: -
// MARK: -
// MARK: - NSObject
extension MEDColorfulLooking where Self: UIBarButtonItem {
    public func viewDefaultColorful() {
        tintColor = AppTheme.NEVO_SOLAR_YELLOW()
    }
}

extension MEDColorfulLooking where Self: UIAlertAction {
    public func viewDefaultColorful() {
        let titleTextColor = AppTheme.NEVO_SOLAR_YELLOW()
        if value(forKey: "_titleTextColor") != nil {
            setValue(titleTextColor, forKey: "_titleTextColor")
        }
        if value(forKey: "titleTextColor") != nil {
            setValue(titleTextColor, forKey: "titleTextColor")
        }
    }
}
