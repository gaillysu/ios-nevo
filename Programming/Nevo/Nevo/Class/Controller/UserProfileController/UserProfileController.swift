//
//  UserProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/18.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

let userIdentifier:String = "UserProfileIdentifier"
class UserProfileController: UITableViewController {

    private let titleArray:[String] = ["First name","Last Name","Weight","Height","Date of Birth"]
    private let fieldArray:[String] = ["first_name","last_name","weight","height","date_birth"]
    var userprofile:NSArray?
    
    init() {
        super.init(nibName: "UserProfileController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.sectionHeaderHeight = 150
        tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.registerNib(UINib(nibName: "UserProfileCell", bundle:nil), forCellReuseIdentifier: userIdentifier)
        self.tableView.registerNib(UINib(nibName: "UserHeader", bundle:nil), forHeaderFooterViewReuseIdentifier: "HeaderViewReuseIdentifier")

        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    override func viewWillAppear(animated: Bool) {
        userprofile = UserProfile.getAll()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150;
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let header:UITableViewHeaderFooterView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderViewReuseIdentifier")!
        return header;
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 5.0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UserProfileCell = tableView.dequeueReusableCellWithIdentifier(userIdentifier,forIndexPath: indexPath) as! UserProfileCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        //cell.titleLabel.text = titleArray[indexPath.row]
        cell.updateLabel(titleArray[indexPath.row])
        
        if userprofile != nil {
            let profile:UserProfile = userprofile?[0] as! UserProfile
            switch indexPath.row {
            case 0:
                cell.valueTextField.text = profile.first_name
            case 1:
                cell.valueTextField.text = profile.last_name
            case 2:
                cell.valueTextField.text = "\(profile.weight)"
            case 3:
                cell.valueTextField.text = "\(profile.length)"
            case 4:
                cell.valueTextField.text = "\(profile.birthday)"
            default:
                break
            }
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            
        }else {
            let profile:NSArray = UserProfile.getAll()
            let userprofile:UserProfile = profile[0] as! UserProfile
            if userprofile.remove() {
                ValidicRequest.cancelAuthorization()
               self.navigationController?.popViewControllerAnimated(true)
            }
            
        }
    }
}
