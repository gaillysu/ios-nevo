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
            self.view.tintColor = UIColor.getBaseColor()
            
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
    
    public class func makeWarningAlert(title:String, message:String?, style:UIAlertControllerStyle, confirmText:String, cancelText:String, okAction:(((UIAlertAction) -> Void)?), cancelAction:(((UIAlertAction) -> Void)?)) -> UIAlertController{
        let alertActionViewController = ActionSheetView(title: title, message: message, preferredStyle: style)
        alertActionViewController.addAction(UIAlertAction(title: confirmText, style: UIAlertActionStyle.destructive, handler: okAction))
        alertActionViewController.addAction(UIAlertAction(title: cancelText, style: UIAlertActionStyle.cancel, handler: cancelAction))
        return alertActionViewController
    }
}
