//
//  PublicClassController.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/26.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

class PublicClassController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if(UIDevice.current.systemVersion.toFloat()>7.0){
            self.edgesForExtendedLayout = UIRectEdge();
            self.extendedLayoutIncludesOpaqueBars = false;
            self.modalPresentationCapturesStatusBarAppearance = false;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
