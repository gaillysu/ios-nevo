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
    private let licenseApp:[String] = ["Validic"]
    //"HealthKit"
    
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
        UPDATE_VALIDIC_REQUEST.updateToValidic(nil)
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
            self.checkPinCode(sender)
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
            let alert:UIAlertController = UIAlertController(title: "Please enter the PIN code", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler { (testField:UITextField) in
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel) { (action) in
                switchView.setOn(false, animated: true)
                })
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.Default) { (action) in
                let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
                view.setTintColor(UIColor.getBaseColor())
                let textfield:UITextField = alert.textFields![0]
                let userprofile:UserProfile = UserProfile.getAll()[0] as! UserProfile
                var finalData: [String : AnyObject] = [:]
                let params: [String: AnyObject] = ["uid":"\(userprofile.id)"];
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
                        //download validic data
                        UPDATE_VALIDIC_REQUEST.downloadValidicData()
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
    }
    
}
