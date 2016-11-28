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
}
