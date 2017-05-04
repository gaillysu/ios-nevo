
//
//  UITableViewCell.swift + Extension
//  Nevo
//
//  Created by Karl-John Chow on 4/5/2017.
//  Copyright © 2017 Nevo. All rights reserved.
//

import Foundation

extension UITableViewCell {
    
    func enable(on: Bool) {
        isUserInteractionEnabled = on
        for view in contentView.subviews {
            view.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
        }
    }
}
