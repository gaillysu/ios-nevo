//
//  UIImage+MEDExtension.swift
//  Nevo
//
//  Created by Quentin on 28/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

extension UIImage {
    public func sameSizeWith(image: UIImage) -> UIImage {
        let toSize: CGSize = image.size
        
        UIGraphicsBeginImageContextWithOptions(toSize, true, UIScreen.main.scale)
        draw(in: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: toSize))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public class func dotImageWith(color: UIColor, backgroundColor: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(backgroundColor.cgColor)
        context?.fill(rect)
        
        context?.addEllipse(in: rect)
        context?.setFillColor(color.cgColor)
        context?.fillEllipse(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /**
     Access to resources image
     
     :param: imageName resource name picture
     
     :returns: Return to obtain images of the object
     */
    open class func getFolderFile(_ name:String, type:String) -> UIImage {
        let imagePath:String = Bundle.main.path(forResource: name, ofType: type)!
        return UIImage(contentsOfFile: imagePath)!
        
    }
}
