//
//  View.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/26.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

extension UIView {
    func searchVisualEffectsSubview() -> UIVisualEffectView? {
        if let visualEffectView = self as? UIVisualEffectView {
            return visualEffectView
        }else {
            for subview in subviews {
                if let found = subview.searchVisualEffectsSubview() {
                    return found
                }
            }
        }
        
        return nil
    }
}