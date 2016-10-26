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

        let alert:ActionSheetView = ActionSheetView(title: "Choose picture source", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1:UIAlertAction = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.default) { (action) in
            let imagepicker = UIImagePickerController()
            imagepicker.navigationBar.backgroundColor =  UIColor.black
            imagepicker.delegate = self
            imagepicker.sourceType = .photoLibrary
            self._sourceType = .photoLibrary
            self.viewController()?.present(imagepicker, animated: true, completion: nil)
        }
        action1.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
        alert.addAction(action1)
        
        let action2:AlertAction = AlertAction(title: "Choose from Camera", style: UIAlertActionStyle.default) { (action) in
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
        
        let action3:AlertAction = AlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
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
        photoVC.cropWidth = 250
        photoVC.cropHeight = 250
        photoVC.delegate = self
        picker.pushViewController(photoVC, animated: true)
    }
    
    func imageCropper(_ cropperViewController: PhotoViewController!, didFinished editedImage: UIImage!) {
        self.viewController()?.dismiss(animated: true, completion: nil)
        avatarView.setImage(editedImage, for: .normal)
        AppTheme.KeyedArchiverName(NevoAllKeys.MEDAvatarKey() as NSString, andObject: editedImage)
    }
    
    func imageCropperDidCancel(_ cropperViewController: PhotoViewController!) {
        if self._sourceType == .photoLibrary {
            cropperViewController.navigationController?.popViewController(animated: true)
        } else {
            cropperViewController.dismiss(animated: true, completion: nil)
        }
    }
}
