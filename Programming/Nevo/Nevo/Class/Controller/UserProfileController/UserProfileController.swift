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
import RealmSwift
import MRProgress

let userIdentifier:String = "UserProfileIdentifier"
class UserProfileController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var userInfoTableView: UITableView!
    
    var newAvatarImage: UIImage?
    
    // Judge if is pushed from `SettingController`, or is after dismiss image picker controller
    var isPushed: Bool = true
    
    fileprivate let tableViewModel:[(title:String, field:String)] = [("First name","first_name"),("Last Name","last_name"),("Weight","weight"),("Height","height"),("Date of Birth","date_birth")]
    
    fileprivate let logoutModel:[(title:String, field:String)] = [("Log out","log_out")]
    
    var userprofile:MEDUserProfile?
    
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
        self.viewDefaultColorful()
        userInfoTableView.viewDefaultColorful()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = NSLocalizedString("Profile", comment: "")
        
        let userArray = MEDUserProfile.getAll()
        if userArray.count>0 {
            userprofile = userArray[0] as? MEDUserProfile
        }
        
        userInfoTableView.reloadData()
    }
    
    func saveProfileAction(_ sender:AnyObject) {
        if let user = userprofile {
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("please_wait", comment: ""), mode: MRProgressOverlayViewMode.indeterminate, animated: true)
            view?.setTintColor(AppTheme.NEVO_SOLAR_YELLOW())
            
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                view?.setTintColor(UIColor.getBaseColor())
            }
            
            MEDUserNetworkManager.updateUser(profile: user, completion: {[weak self] (flag, user) in
                MRProgressOverlayView.dismissAllOverlays(for: self?.navigationController!.view, animated: true)
                
                if flag {
                    DispatchQueue.main.async {
                        _ = self?.userprofile?.update()
                        _ = self?.navigationController?.popViewController(animated: true)
                    }
                } else {
                    let banner = MEDBanner(title: NSLocalizedString("no_network", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.5)
                }
            })
        }
        
        
        if let avatarImage = newAvatarImage {
            let manager = ProfileImageManager.shared
            _ = manager.save(image: avatarImage)
        }
    }
}


// MARK: - ImagePicker Module
extension UserProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate {
    func avatarButtonClick(sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        let alertController = MEDAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
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
        alertController.actions.forEach { action in
            action.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        
        self.isPushed = false
        let userHeader = self.userInfoTableView.headerView(forSection: 0) as! UserHeader
        userHeader.changeAvatar(with: croppedImage)
        
        self.newAvatarImage = croppedImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        
        self.isPushed = false
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



// MARK: - TableView Datasource
extension UserProfileController {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 170
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let header:UserHeader? = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderViewReuseIdentifier") as! UserHeader?
            if isPushed {
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.avatarButtonClick(sender:)))
                header?.avatarView.addGestureRecognizer(tap)
                let manager = ProfileImageManager.shared
                if let image = manager.getImage() {
                    header?.changeAvatar(with: image)
                }
            }
            header?.viewDefaultColorful()
            return header
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return tableViewModel.count
        case 1:
            return logoutModel.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UserProfileCell = tableView.dequeueReusableCell(withIdentifier: userIdentifier,for: indexPath) as! UserProfileCell
        if indexPath.section == 0 {
            let model = tableViewModel[indexPath.row]
            cell.updateLabel(NSLocalizedString(model.field, comment: ""))
            if userprofile != nil {
                switch indexPath.row {
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
            
            cell.cellIndex = indexPath.row
            cell.editCellTextField = {
                (index,text) -> Void in
                XCGLogger.default.debug("Profile TextField\(index)")
                let realm = try! Realm()
                do {
                    try realm.write {
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
                } catch let error {
                    XCGLogger.default.debug("write database error:\(error)")
                }
            }
        
        } else if indexPath.section == 1 && indexPath.row == 0{
            let model = logoutModel[indexPath.row]
            cell.updateLabel(NSLocalizedString(model.field, comment: ""))
            cell.valueTextField.text = ""
            cell.valueTextField.isEnabled = false
            cell.selectionStyle = .default
            cell.accessoryType = .none
            cell.titleLabel.textColor = UIColor.darkRed()
        }
        return cell
    }
}

// MARK: - TableView Delegate
extension UserProfileController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0{
            let dialogController = MEDAlertController(title: NSLocalizedString("log_out", comment: "") , message: NSLocalizedString("Are you sure you want to log out?", comment: ""), preferredStyle: .alert)
            let confirmAction = AlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (_) in
                    if(self.userprofile?.remove())!{
                        self.navigationController?.popViewController(animated: true)
                    }
            })
            confirmAction.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
            dialogController.addAction(confirmAction)
            
            let cancelAction = AlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            cancelAction.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
            dialogController.addAction(cancelAction)
            
            self.present(dialogController, animated: true, completion: nil)
        }
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
