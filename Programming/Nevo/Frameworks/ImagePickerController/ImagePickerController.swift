//
//  ImagePickerController.swift
//  Nevo
//
//  Created by Cloud on 2016/10/26.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

protocol MEDSelectedImagePickerDelegate:NSObjectProtocol {
    func selectedImagePicker(_ imageData:Data)
}

class ImagePickerController: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    fileprivate let pickerController:UIViewController?
    var delegate:MEDSelectedImagePickerDelegate?
    
    init(_ controller:UIViewController) {
        pickerController = controller
        super.init()
    }

    /**调用相机*/
    func openCamera() {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            let picker:UIImagePickerController = UIImagePickerController()
            picker.delegate = self
            //资源类型为照相机
            picker.sourceType = UIImagePickerControllerSourceType.camera;
            pickerController!.present(picker, animated: true, completion: { () -> Void in
            })
        }else{
            let alert:UIAlertController = UIAlertController(title: "Is not camera", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let action1:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action) in
                
            }
            action1.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
            alert.addAction(action1)
            
            pickerController!.present(alert, animated: true, completion: nil)
        }
    }
    
    func openPicLibrary() {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)) {
            let picker:UIImagePickerController = UIImagePickerController()
            //picker.delegate = self
            //资源类型为相册
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            pickerController!.present(picker, animated: true, completion: { () -> Void in
            })
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //获取照片的原图
        let infoDict:NSDictionary = info as NSDictionary
        let original:UIImage = (info as NSDictionary).object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
        let data:Data = UIImageJPEGRepresentation(original, 0.3)!;
        
        delegate?.selectedImagePicker(data)
        
        if (picker.sourceType == UIImagePickerControllerSourceType.photoLibrary) {
            
            
        }else{
            UIImageWriteToSavedPhotosAlbum(((info as NSDictionary).object(forKey: UIImagePickerControllerOriginalImage) as! UIImage), self, nil, nil)
        }
        pickerController!.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        pickerController!.dismiss(animated: true, completion: nil)
    }
}
