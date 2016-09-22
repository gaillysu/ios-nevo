//
//  ConnectOtherAppsController.swift
//  Nevo
//
//  Created by leiyuncun on 16/5/25.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import MRProgress
import SwiftyJSON

class ConnectOtherAppsController: UITableViewController {
    fileprivate let licenseApp:[String] = ["Validic"]
    //"HealthKit"
    
    init() {
        super.init(nibName: "ConnectOtherAppsController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "App Authorized"
        self.tableView.register(UINib(nibName: "ConnectOtherAppsCell", bundle:nil), forCellReuseIdentifier: "reuseIdentifier")
        UPDATE_VALIDIC_REQUEST.updateToValidic(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return licenseApp.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier" ,for: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        (cell as! ConnectOtherAppsCell).appNameLabel.text = licenseApp[(indexPath as NSIndexPath).row]
        (cell as! ConnectOtherAppsCell).appSwitch.tag = (indexPath as NSIndexPath).row
        (cell as! ConnectOtherAppsCell).appSwitch.addTarget(self, action: #selector(appAuthorizedAction(_:)), for: UIControlEvents.touchUpInside)
        if "Validic" ==  licenseApp[(indexPath as NSIndexPath).row]{
            if (UserDefaults.standard.object(forKey: ValidicAuthorizedKey) != nil) {
                (cell as! ConnectOtherAppsCell).appSwitch.isOn = true
            }
        }
        return cell
    }
    
    func appAuthorizedAction(_ sender:UISwitch) {
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

    func checkPinCode(_ switchView:UISwitch) {
        if switchView.isOn {
            UIApplication.shared.openURL(URL(string:"https://partner.validic.com/applications/47/test/marketplace")!)
            let alert:UIAlertController = UIAlertController(title: "Please enter the PIN code", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField { (testField:UITextField) in
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (action) in
                switchView.setOn(false, animated: true)
                })
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.default) { (action) in
                let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.indeterminate, animated: true)
                view?.setTintColor(UIColor.getBaseColor())
                let textfield:UITextField = alert.textFields![0]
                let userprofile:UserProfile = UserProfile.getAll()[0] as! UserProfile
                var finalData: [String : AnyObject] = [:]
                let params: [String: AnyObject] = ["uid":"\(userprofile.id)" as AnyObject];
                finalData["user"] = params as AnyObject?
                finalData["pin"] = textfield.text! as AnyObject?
                finalData["access_token"] = OrganizationAccessToken as AnyObject?
                ValidicRequest.validicPostJSONRequest("https://api.validic.com/v1/organizations/\(ValidicOrganizationID)/authorization/new_user", data: finalData, completion: { (result) in
                    MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                    let resultJson = JSON(result)
                    if (resultJson["code"].intValue == 201 || resultJson["code"].intValue == 200) {
                        let userdefalut:UserDefaults = UserDefaults.standard
                        userdefalut.set(resultJson["user"].dictionaryObject, forKey: ValidicAuthorizedKey)
                        userdefalut.synchronize()
                        //download validic data
                        UPDATE_VALIDIC_REQUEST.downloadValidicData()
                    }else{
                        switchView.setOn(false, animated: true)
                    }
                })
                
                })
            
            self.present(alert, animated: true) {
                
            }
            
        }else{
            UserDefaults.standard.removeObject(forKey: ValidicAuthorizedKey)
        }
    }
    
}
