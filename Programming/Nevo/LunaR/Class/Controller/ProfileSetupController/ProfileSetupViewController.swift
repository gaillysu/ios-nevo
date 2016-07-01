//
//  ProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/2.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField
import UIColor_Hex_Swift
import BRYXBanner
import SwiftyJSON
import MRProgress
import XCGLogger

private let DATEPICKER_TAG:Int = 1280
private let PICKERVIEW_TAG:Int = 1380

class ProfileSetupViewController: UIViewController {

    @IBOutlet weak var email: AutocompleteField!
    @IBOutlet weak var firstNameTextField: AutocompleteField!
    @IBOutlet weak var lastNameTextField: AutocompleteField!
    @IBOutlet weak var password: AutocompleteField!
    @IBOutlet weak var retypePassword: AutocompleteField!
    @IBOutlet weak var submitButton: UIButton!

    private var nameDictionary:Dictionary<String,AnyObject> = ["first_name":"DroneUser","last_name":"User"]
    var account:Dictionary<String,AnyObject> = ["email":"","password":""]

    private var selectedTextField: AutocompleteField?
    private var lengthArray:[Int] = []
    private var weightArray:[Int] = []
    private var weightFloatArray:[Int] = []
    private var selectedRow:Int = 0
    private var selectedRow2:Int = 0

    init() {
        super.init(nibName: "ProfileSetupViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor(rgba: "#54575a"))
        
        let leftButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel_lunar"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(leftCancelAction(_:)))
        self.navigationItem.leftBarButtonItem = leftButton
    }

    func leftCancelAction(sender:UIBarButtonItem) {
        let viewController = self.navigationController?.popViewControllerAnimated(true)
        if viewController != nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.lt_reset()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    @IBAction func buttonActionManager(sender: AnyObject) {
        
    }


    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        lastNameTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()

    }
}