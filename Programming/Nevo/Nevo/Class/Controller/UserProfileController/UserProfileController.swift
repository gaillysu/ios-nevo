//
//  UserProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/18.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import XCGLogger

let userIdentifier:String = "UserProfileIdentifier"
class UserProfileController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var userInfoTableView: UITableView!
    
    private let titleArray:[String] = ["First name","Last Name","Weight","Height","Date of Birth"]
    private let fieldArray:[String] = ["first_name","last_name","weight","height","date_birth"]
    var userprofile:UserProfile?
    
    init() {
        super.init(nibName: "UserProfileController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfoTableView.sectionHeaderHeight = 150
        userInfoTableView.backgroundColor = UIColor.whiteColor()
        userInfoTableView.registerNib(UINib(nibName: "UserProfileCell", bundle:nil), forCellReuseIdentifier: userIdentifier)
        userInfoTableView.registerNib(UINib(nibName: "UserHeader", bundle:nil), forHeaderFooterViewReuseIdentifier: "HeaderViewReuseIdentifier")

        userInfoTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        let rightItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(saveProfileAction(_:)))
        self.navigationItem.rightBarButtonItem = rightItem
    }

    override func viewWillAppear(animated: Bool) {
        let userArray:NSArray = UserProfile.getAll()
        if userArray.count>0 {
            userprofile = userArray[0] as? UserProfile
        }
        
        userInfoTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveProfileAction(sender:AnyObject) {
        if userprofile != nil {
            if userprofile!.update() {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header:UITableViewHeaderFooterView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderViewReuseIdentifier")!
        return header;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50;
    }
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 5.0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UserProfileCell = tableView.dequeueReusableCellWithIdentifier(userIdentifier,forIndexPath: indexPath) as! UserProfileCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        //cell.titleLabel.text = titleArray[indexPath.row]
        cell.updateLabel(titleArray[indexPath.row])
        
        if userprofile != nil {
            
            switch indexPath.row {
            case 0:
                cell.valueTextField.text = userprofile!.first_name
            case 1:
                cell.valueTextField.text = userprofile!.last_name
            case 2:
                cell.valueTextField.text = "\(userprofile!.weight) KG"
                cell.setInputVariables(self.generatePickerData(35, rangeEnd: 150, interval: 0))
                cell.setType(.Numeric)
                cell.textPostFix = " KG"
            case 3:
                cell.valueTextField.text = "\(userprofile!.length) CM"
                cell.setInputVariables(self.generatePickerData(100, rangeEnd: 250, interval: 0))
                cell.setType(.Numeric)
                cell.textPostFix = " CM"
                
            case 4:
                cell.valueTextField.text = "\(userprofile!.birthday)"
                cell.valueTextField.placeholder = "Birthday: "
                cell.setType(.Date)
                cell.textPreFix = "Birthday: "
            default:
                break
            }
        }
        
        cell.cellIndex = indexPath.row
        cell.editCellTextField = {
            (index,text) -> Void in
            XCGLogger.defaultInstance().debug("Profile TextField\(index)")
            switch index {
            case 0:
                self.userprofile!.first_name = text
            case 1:
                self.userprofile!.last_name = text
            case 3:
                if Int(text) != nil {
                    self.userprofile!.length = Int(text)!
                }
            case 2:
                if Int(text) != nil {
                    self.userprofile!.weight = Int(text)!
                }
            case 4:
                self.userprofile!.birthday = text
            default:
                break
            }
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    
    private func generatePickerData(rangeBegin: Int,rangeEnd: Int, interval: Int)->NSMutableArray{
        let data:NSMutableArray = NSMutableArray();
        for i in rangeBegin...rangeEnd{
            if(interval > 0){
                if i % interval == 0 {
                    data.addObject("\(i)")
                }
            }else{
                data.addObject("\(i)")
            }
        }
        return data;
    }
}
