//
//  CheckYourIndoxController.swift
//  Nevo
//
//  Created by leiyuncun on 16/6/30.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class CheckYourIndoxController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor("#54575a"))
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        let leftButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel_lunar"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftCancelAction(_:)))
        self.navigationItem.leftBarButtonItem = leftButton

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.lt_reset()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }

    func leftCancelAction(_ sender:UIBarButtonItem) {
        let viewController = self.navigationController?.popViewController(animated: true)
        if viewController != nil {
            self.dismiss(animated: true, completion: nil)
        }
    } 
}
