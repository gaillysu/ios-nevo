//
//  MEDAlertController.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/27.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class MEDAlertController: UIAlertController {
    var isSetSubView:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for view in self.view.subviews.first!.subviews {
            //NSLog("第一个循环几次")
            for view2 in view.subviews {
                //NSLog("第二个循环几次")
                for view3 in view2.subviews {
                    //NSLog("第三个循环几次")
                    for view4 in view3.subviews {
                        if !AppTheme.isTargetLunaR_OR_Nevo() {
                            view4.backgroundColor = UIColor.getGreyColor();
                        }
                    }
                }
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.view.tintColor = UIColor.getBaseColor()
            
            //         _UIAlertControlleriOSActionSheetCancelBackgroundView
            UIApplication.shared.keyWindow?.allSubviews(do: { (v) in
                if v.classForCoder == NSClassFromString("_UIAlertControlleriOSActionSheetCancelBackgroundView") {
                    v.backgroundColor = UIColor.getGreyColor()
                }
                
                v.allSubviews(do: { (v) in
                    if v.isMember(of: UIView.classForCoder()) {
                        v.backgroundColor = UIColor.getGreyColor()
                    }
                })
            })
            
            view.allSubviews(do: { (v) in
                if v.isKind(of: UILabel.classForCoder()) {
                    let label = v as! UILabel
                    if label.text == self.title || label.text == self.message {
                        label.textColor = UIColor.white
                    }
                }
            })
        }
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
