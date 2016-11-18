//
//  UserHeader.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/19.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class UserHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var avatarView: UIButton!
    
    var _sourceType:UIImagePickerControllerSourceType? = nil
    
    @IBAction func uploadAction(_ sender: AnyObject) {
        let alert:ActionSheetView = ActionSheetView(title: NSLocalizedString("Choose picture source", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1:UIAlertAction = UIAlertAction(title: NSLocalizedString("Choose from library", comment: ""), style: UIAlertActionStyle.default) { (action) in
            let imagepicker = UIImagePickerController()
            imagepicker.navigationBar.backgroundColor =  UIColor.black
            imagepicker.delegate = self
            imagepicker.sourceType = .photoLibrary
            self._sourceType = .photoLibrary
            self.viewController()?.present(imagepicker, animated: true, completion: nil)
        }
        action1.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
        alert.addAction(action1)
        
        let action2:AlertAction = AlertAction(title: NSLocalizedString("Choose from Camera", comment: ""), style: UIAlertActionStyle.default) { (action) in
            let sourceType:UIImagePickerControllerSourceType = .camera
            self._sourceType = sourceType
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = sourceType
                self.viewController()?.present(picker, animated: true, completion: nil)
            } else {
                print("camera not available")
            }
            
        }
        action2.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
        alert.addAction(action2)
        
        let action3:AlertAction = AlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (action) in
            self.viewController()?.dismiss(animated: true, completion: nil)
        }
        action3.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
        alert.addAction(action3)
        viewController()?.present(alert, animated: true, completion: nil)
    }
}

extension UserHeader:PhotoViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let originalImage:UIImage = (info as NSDictionary).object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
        let newImage = UIImage.fitScreen(with: originalImage)
        let photoVC = PhotoViewController()
        photoVC.oldImage = newImage
        photoVC.mode = .viewModeSquare
        photoVC.cropWidth = 300
        photoVC.cropHeight = 300
        photoVC.delegate = self
        
        //*** 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧 ****//
        photoVC.view.allSubviews { (v) in
            if v is UILabel {
                let label = v as! UILabel
                if label.text == "移动和缩放" {
                    label.text = NSLocalizedString("move_&_zoom", comment: "")
                }
            } else {
                return
            }
        }
        
        photoVC.view.allSubviews { (v) in
            if v is UIButton {
                let button = v as! UIButton
                if button.title(for: .normal) == "确定" {
                    button.setTitle(NSLocalizedString("Enter", comment: ""), for: .normal)
                    button.superview?.allSubviews(do: { (v) in
                        v.backgroundColor = UIColor.clear
                    })
                    button.superview?.backgroundColor = UIColor.getGreyColor()
                }
            }
        }
        
        //*** 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧 ****//
        
        picker.pushViewController(photoVC, animated: true)
    }
    
    func imageCropper(_ cropperViewController: PhotoViewController!, didFinished editedImage: UIImage!) {
        self.viewController()?.dismiss(animated: true, completion: nil)
        avatarView.setImage(editedImage, for: .normal)
        _ = AppTheme.KeyedArchiverName(NevoAllKeys.MEDAvatarKeyBeforeSave() as NSString, andObject: editedImage)
        
        (self.viewController() as! UserProfileController).isNewPush = false
    }
    
    func imageCropperDidCancel(_ cropperViewController: PhotoViewController!) {
        if self._sourceType == .photoLibrary {
            _ = cropperViewController.navigationController?.popViewController(animated: true)
        } else {
            cropperViewController.dismiss(animated: true, completion: nil)
        }
    }
}
