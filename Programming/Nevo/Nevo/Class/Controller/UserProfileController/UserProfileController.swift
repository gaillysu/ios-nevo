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

    private let titleArray:[String] = ["First name","Last Name","Weight","Length"]
    private let fieldArray:[String] = ["first_name","last_name","weight","length"]
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
        
        self.tableView.registerNib(UINib(nibName: "UserProfileCell", bundle:nil), forCellReuseIdentifier: userIdentifier)
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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return titleArray.count
        }else{
            return 1
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(userIdentifier,forIndexPath: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.None;
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.textLabel?.text = titleArray[indexPath.row]
            
            if userprofile != nil {
                let profile:UserProfile = userprofile?[0] as! UserProfile
                switch indexPath.row {
                case 0:
                    cell.detailTextLabel?.text = profile.first_name
                case 1:
                    cell.detailTextLabel?.text = profile.last_name
                case 2:
                    cell.detailTextLabel?.text = "\(profile.weight)"
                case 3:
                    cell.detailTextLabel?.text = "\(profile.length)"
                default:
                    break
                }
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(userIdentifier,forIndexPath: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.None;
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.backgroundColor = UIColor.redColor()
            var label = cell.contentView.viewWithTag(1500)
            if label == nil {
                label = UILabel(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,40))
                label?.tag = 1500
                cell.contentView.addSubview(label!)
            }
            label?.backgroundColor = UIColor.redColor()
            (label as! UILabel).textColor = UIColor.whiteColor()
            (label as! UILabel).textAlignment = NSTextAlignment.Center
            (label as! UILabel).text = "LogOut"
            return cell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            let changeProfile:ChangeProfileController = ChangeProfileController()
            changeProfile.title = titleArray[indexPath.row]
            changeProfile.changeName = titleArray[indexPath.row]
            changeProfile.changeField = fieldArray[indexPath.row]
            self.navigationController?.pushViewController(changeProfile, animated: true)
        }else {
            let profile:NSArray = UserProfile.getAll()
            let userprofile:UserProfile = profile[0] as! UserProfile
            userprofile.remove()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}
