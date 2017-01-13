//
//  UINavigationBar+MEDExtension.swift
//  Nevo
//
//  Created by Quentin on 13/1/17.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit

extension UINavigationBar {
    @objc private func MEDLayoutSubviews() {
        MEDLayoutSubviews()
        
        subviewsSatisfy(theCondition: { (v) -> (Bool) in
            return v.frame.height == 0.5
        }) { (v) in
            
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                v.backgroundColor = UIColor.white
            }
        }
    }
    
    
    override open class func initialize() {
        super.initialize()
        
        if self == UINavigationBar.self {
            let new = class_getInstanceMethod(self, #selector(MEDLayoutSubviews))
            let old = class_getInstanceMethod(self, NSSelectorFromString("layoutSubviews"))
            
            method_exchangeImplementations(new, old)
        }
    }
}
