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
        if((UIDevice.current.systemVersion as NSString).floatValue>7.0){
            self.edgesForExtendedLayout = UIRectEdge();
            self.extendedLayoutIncludesOpaqueBars = false;
            self.modalPresentationCapturesStatusBarAppearance = false;
        }
        let infoDictionary:[String : AnyObject] = Bundle.main.infoDictionary! as [String : AnyObject]
        
        let app_Name:String = infoDictionary["CFBundleName"] as! String
        if app_Name == "LunaR" {
            self.view.backgroundColor = UIColor(rgba: "#54575a")
        }

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
