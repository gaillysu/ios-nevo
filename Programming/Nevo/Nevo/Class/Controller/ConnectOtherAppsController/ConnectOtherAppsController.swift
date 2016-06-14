//
//  ConnectOtherAppsController.swift
//  Nevo
//
//  Created by leiyuncun on 16/5/25.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import SwiftyJSON
import MRProgress

class ConnectOtherAppsController: UITableViewController {
    private let licenseApp:[String] = ["HealthKit","Validic"]
    
    init() {
        super.init(nibName: "ConnectOtherAppsController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "App Authorized"
        self.tableView.registerNib(UINib(nibName: "ConnectOtherAppsCell", bundle:nil), forCellReuseIdentifier: "reuseIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return licenseApp.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier" ,forIndexPath: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        (cell as! ConnectOtherAppsCell).appNameLabel.text = licenseApp[indexPath.row]
        (cell as! ConnectOtherAppsCell).appSwitch.tag = indexPath.row
        (cell as! ConnectOtherAppsCell).appSwitch.addTarget(self, action: #selector(appAuthorizedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        if "Validic" ==  licenseApp[indexPath.row]{
            if (NSUserDefaults.standardUserDefaults().objectForKey(ValidicAuthorizedKey) != nil) {
                (cell as! ConnectOtherAppsCell).appSwitch.on = true
            }
        }
        return cell
    }
    
    func appAuthorizedAction(sender:UISwitch) {
        switch sender.tag {
        case 0:
            break
        case 1:
            self.checkPinCode(sender)
        case 2: break
        case 3: break
        default: break
            
        }
    }

    func checkPinCode(switchView:UISwitch) {
        if switchView.on {
            UIApplication.sharedApplication().openURL(NSURL(string:"https://partner.validic.com/applications/47/test/marketplace")!)
            let alert:UIAlertController = UIAlertController(title: "请输入PIN码", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler { (testField:UITextField) in
            }
            
            alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel) { (action) in
                switchView.setOn(false, animated: true)
                })
            
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (action) in
                let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
                view.setTintColor(UIColor.getBaseColor())
                let textfield:UITextField = alert.textFields![0]
                let userprofile:UserProfile = UserProfile.getAll()[0] as! UserProfile
                var finalData: [String : AnyObject] = [:]
                let params: [String: AnyObject] = ["uid":"\(userprofile.uid)"];
                finalData["user"] = params
                finalData["pin"] = textfield.text!
                finalData["access_token"] = OrganizationAccessToken
                ValidicRequest.validicPostJSONRequest("https://api.validic.com/v1/organizations/\(ValidicOrganizationID)/authorization/new_user", data: finalData, completion: { (result) in
                    MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
                    let resultJson = JSON(result)
                    if (resultJson["code"].intValue == 201 || resultJson["code"].intValue == 200) {
                        let userdefalut:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        userdefalut.setObject(resultJson["user"].dictionaryObject, forKey: ValidicAuthorizedKey)
                        userdefalut.synchronize()
                        
                        
                    }else{
                        switchView.setOn(false, animated: true)
                    }
                })
                
                })
            
            self.presentViewController(alert, animated: true) {
                
            }
            
        }else{
            NSUserDefaults.standardUserDefaults().removeObjectForKey(ValidicAuthorizedKey)
        }
        //UserSteps.getAll()
    }
    
    func updateToValidic() {
        let stepsArray:NSArray = UserSteps.getAll()
        var array:[[String : AnyObject]] = []
        for steps in stepsArray{
            let userSteps:UserSteps = steps as! UserSteps
            var detail:[String : AnyObject] = [:]
            detail["timestamp"] = ValidicRequest.formatterDate(NSDate(timeIntervalSince1970: userSteps.date))
            detail["utc_offset"] = "+00:00"
            detail["steps"] = userSteps.steps
            detail["distance"] = userSteps.distance
            detail["floors"] = 0
            detail["elevation"] = 0
            detail["calories_burned"] = userSteps.calories
            detail["activity_id"] = "0"
            array.append(detail)
        }
        
        for object in array{
            UPDATE_VALIDIC_REQUEST.updateValidicData(object, completion: { (result) in
                
            })
        }
    }
    
}
