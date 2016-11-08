//
//  ActionSheetView.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/27.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class ActionSheetView: UIAlertController {
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
            //         _UIAlertControlleriOSActionSheetCancelBackgroundView
            UIApplication.shared.keyWindow?.subviewsSatisfy(theCondition: { (v) -> (Bool) in
                return v.classForCoder == NSClassFromString("_UIAlertControlleriOSActionSheetCancelBackgroundView")
            }, do: { (v) in
                v.backgroundColor = UIColor.getGreyColor()
                v.allSubviews(do: { (v) in
                    if v.isMember(of: UIView.classForCoder()) {
                        v.backgroundColor = UIColor.getGreyColor()
                    }
                })
            })
            
            
            // 标题白色
            view.subviewsSatisfy(theCondition: { (v) -> (Bool) in
                if v.isKind(of: UILabel.classForCoder()) {
                    if (v as! UILabel).text == self.title {
                        return true
                    }
                }
                return false
            }, do: { (v) in
                (v as! UILabel).textColor = UIColor.white
            })
            
            // 副标题白色
            view.subviewsSatisfy(theCondition: { (v) -> (Bool) in
                if v.isKind(of: UILabel.classForCoder()) {
                    if (v as! UILabel).text == self.message {
                        return true
                    }
                }
                return false
            }, do: { (v) in
                (v as! UILabel).textColor = UIColor.white
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }

}
