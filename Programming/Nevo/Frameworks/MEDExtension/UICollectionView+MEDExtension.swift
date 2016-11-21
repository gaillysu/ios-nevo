//
//  UICollectionView+MEDExtension.swift
//  Nevo
//
//  Created by Quentin on 21/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    // Context of the use is extreme
    public func findMaxLabelWidth() -> CGFloat {
        var maxWidth:CGFloat = -1
        for cell in self.visibleCells {
            cell.allSubviews(do: { (v) in
                if v.isKind(of: UILabel.classForCoder()) {
                    let label = v as! UILabel
                    if let text = label.text {                        
                        let attr:[String:AnyObject] = [NSFontAttributeName:label.font]
                        let width:CGFloat = (text as NSString).size(attributes: attr).width
                        print("==============\(width)======\(text)")
                        if width > maxWidth {
                            maxWidth = width
                        }
                    }
                }
            })
        }
        
        return maxWidth
    }
}
