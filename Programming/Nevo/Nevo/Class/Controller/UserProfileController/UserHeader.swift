//
//  UserHeader.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/19.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class UserHeader: UITableViewHeaderFooterView,MEDSelectedImagePickerDelegate {

    @IBAction func uploadAction(_ sender: AnyObject) {

        let alert:ActionSheetView = ActionSheetView(title: "Choose picture source", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1:UIAlertAction = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.default) { (action) in
            let imagePicker:ImagePickerController = ImagePickerController(self.viewController()!)
            imagePicker.delegate = self
            imagePicker.openPicLibrary()
        }
        action1.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
        alert.addAction(action1)
        
        let action2:AlertAction = AlertAction(title: "Choose from Camera", style: UIAlertActionStyle.default) { (action) in
            let imagePicker:ImagePickerController = ImagePickerController(self.viewController()!)
            imagePicker.delegate = self
            imagePicker.openCamera()
        }
        action2.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
        alert.addAction(action2)
        
        let action3:AlertAction = AlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            
        }
        action3.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
        alert.addAction(action3)
        viewController()?.present(alert, animated: true, completion: nil)
        
    }
    
    func selectedImagePicker(_ imageData:Data){
        print("imageData:\(imageData)");
    }
}
