//
//  UserProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/18.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import XCGLogger
import RSKImageCropper

let userIdentifier:String = "UserProfileIdentifier"
class UserProfileController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var userInfoTableView: UITableView!
    
    // Judge if is pushed from `SettingController`, or is after dismiss image picker controller
    var isPushed: Bool = true
    
    fileprivate let titleArray:[String] = ["First name","Last Name","Weight","Height","Date of Birth"]
    fileprivate let fieldArray:[String] = ["first_name","last_name","weight","height","date_birth"]
    var userprofile:UserProfile?
    
    init() {
        super.init(nibName: "UserProfileController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfoTableView.register(UINib(nibName: "UserProfileCell", bundle:nil), forCellReuseIdentifier: userIdentifier)
        userInfoTableView.register(UINib(nibName: "UserHeader", bundle:nil), forHeaderFooterViewReuseIdentifier: "HeaderViewReuseIdentifier")

        userInfoTableView.separatorStyle = .singleLine
        
        let rightItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveProfileAction(_:)))
        self.navigationItem.rightBarButtonItem = rightItem
        
        /// APPTHEME ADJUST
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getLightBaseColor()
            userInfoTableView.backgroundColor = UIColor.getLightBaseColor()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = NSLocalizedString("Profile", comment: "")
        
        let userArray:NSArray = UserProfile.getAll()
        if userArray.count>0 {
            userprofile = userArray[0] as? UserProfile
        }
        
        userInfoTableView.reloadData()
    }

    func saveProfileAction(_ sender:AnyObject) {
        if userprofile != nil {
            if userprofile!.update() {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        
        if let avatarImage = (userInfoTableView.headerView(forSection: 0) as! UserHeader).avatarView.image(for: .normal) {
            let manager = ProfileImageManager.manager
            manager.save(image: avatarImage)
        }
    }
}


// MARK: - ImagePicker Module
extension UserProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate {
    func avatarButtonClick(sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        let alertController = ActionSheetView(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Choose from Camera", comment: ""), style: .default, handler: { action in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Choose from library", comment: ""), style: .default, handler: { action in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
            alertController.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        
        self.isPushed = false
        let userHeader = self.userInfoTableView.headerView(forSection: 0) as! UserHeader
        userHeader.changeAvatar(with: croppedImage)
        self.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageCropViewController:RSKImageCropViewController = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.circle)
            imageCropViewController.delegate = self
            picker.dismiss(animated: false, completion: {
                self.present(imageCropViewController, animated: false, completion: nil)
            })
        } else {
            print("Something went wrong")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}



// MARK: - TableView delegate
extension UserProfileController {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 150 : 0;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header:UserHeader? = nil
        if section == 0 {
            header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderViewReuseIdentifier") as! UserHeader?

            if isPushed {
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.avatarButtonClick(sender:)))
                header?.avatarView.addGestureRecognizer(tap)
                
                let manager = ProfileImageManager.manager
                if let image = manager.getImage() {
                    header?.changeAvatar(with: image)
                }
            }
        }
        
        /// APPTHEME ADJUST
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            header?.backgroundColor = UIColor.getGreyColor()
        }
        return header;
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UserProfileCell = tableView.dequeueReusableCell(withIdentifier: userIdentifier,for: indexPath) as! UserProfileCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        //cell.titleLabel.text = titleArray[indexPath.row]
        cell.updateLabel(NSLocalizedString(fieldArray[(indexPath as NSIndexPath).row], comment: ""))
        if userprofile != nil {
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.valueTextField.text = userprofile!.first_name
            case 1:
                cell.valueTextField.text = userprofile!.last_name
            case 2:
                cell.valueTextField.text = "\(userprofile!.weight) KG"
                cell.setInputVariables(self.generatePickerData(35, rangeEnd: 150, interval: 0))
                cell.setType(.numeric)
                cell.textPostFix = " KG"
            case 3:
                cell.valueTextField.text = "\(userprofile!.length) CM"
                cell.setInputVariables(self.generatePickerData(100, rangeEnd: 250, interval: 0))
                cell.setType(.numeric)
                cell.textPostFix = " CM"
                
            case 4:
                cell.valueTextField.text = "\(userprofile!.birthday)"
                cell.valueTextField.placeholder = "Birthday: "
                cell.setType(.date)
            default:
                break
            }
        }
        
        cell.cellIndex = (indexPath as NSIndexPath).row
        cell.editCellTextField = {
            (index,text) -> Void in
            XCGLogger.default.debug("Profile TextField\(index)")
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
        
        /// APPTHEME ADJUST
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            cell.backgroundColor = UIColor.getGreyColor()
            cell.titleLabel.textColor = UIColor.white
            cell.valueTextField.textColor = UIColor.getBaseColor()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - Private function
extension UserProfileController {
    fileprivate func generatePickerData(_ rangeBegin: Int,rangeEnd: Int, interval: Int)->NSMutableArray{
        let data:NSMutableArray = NSMutableArray();
        for i in rangeBegin...rangeEnd{
            if(interval > 0){
                if i % interval == 0 {
                    data.add("\(i)")
                }
            }else{
                data.add("\(i)")
            }
        }
        return data;
    }
}
