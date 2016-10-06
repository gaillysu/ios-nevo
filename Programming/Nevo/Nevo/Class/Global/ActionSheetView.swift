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
        if isSetSubView {
            self.setSubView()
        }
    }
    
    func setSubView() {
        for view in self.view.subviews.first!.subviews {
            //NSLog("第一个循环几次")
            for view2 in view.subviews {
                //NSLog("第二个循环几次")
                for view3 in view2.subviews {
                    //NSLog("第三个循环几次")
                    for view4 in view3.subviews {
                        //NSLog("第四个循环几次")
                        view4.backgroundColor = UIColor(rgba: "#54575A")
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }

}
