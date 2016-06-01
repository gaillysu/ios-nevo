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

    private let titleArray:[String] = ["First name","Last Name","Weight","Age","Length"]
    private let fieldArray:[String] = ["first_name","last_name","weight","age","lenght"]
    var userprofile:NSArray?
    
    init() {
        super.init(nibName: "UserProfileController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.sectionHeaderHeight = 90

    }

    override func viewDidAppear(animated: Bool) {
        userprofile = UserProfile.getAll()
        self.tableView.reloadData()
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
        return titleArray.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(userIdentifier) as? UserProfileCell
        if (cell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("UserProfileCell", owner: self, options: nil)
            cell = nibs.objectAtIndex(0) as? UserProfileCell;
        }
        cell?.selectionStyle = UITableViewCellSelectionStyle.None;
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell?.textLabel?.text = titleArray[indexPath.row]
        
        if userprofile != nil {
            let profile:UserProfile = userprofile?[0] as! UserProfile
            switch indexPath.row {
            case 0:
                cell?.detailTextLabel?.text = profile.first_name
            case 1:
                cell?.detailTextLabel?.text = profile.last_name
            case 2:
                cell?.detailTextLabel?.text = "\(profile.weight)"
            case 3:
                cell?.detailTextLabel?.text = "\(profile.age)"
            case 4:
                cell?.detailTextLabel?.text = "\(profile.lenght)"
            default:
                break
            }
        }
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let changeProfile:ChangeProfileController = ChangeProfileController()
        changeProfile.title = titleArray[indexPath.row]
        changeProfile.changeName = titleArray[indexPath.row]
        changeProfile.changeField = fieldArray[indexPath.row]
        
        self.navigationController?.pushViewController(changeProfile, animated: true)
    }
}
