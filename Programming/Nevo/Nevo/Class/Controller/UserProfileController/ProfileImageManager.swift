//
//  ProfileImageManager.swift
//  Nevo
//
//  Created by leiyuncun on 2016/11/21.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation

fileprivate let m:ProfileImageManager = ProfileImageManager()
public class ProfileImageManager {
    class var manager:ProfileImageManager {
        return m
    }
    
    public func save(image:UIImage) {
        _ = AppTheme.KeyedArchiverName(NevoAllKeys.MEDAvatarKeyAfterSave(), andObject: image)
    }
    
    public func getImage() -> UIImage? {
        if let resultArray = AppTheme.LoadKeyedArchiverName(NevoAllKeys.MEDAvatarKeyAfterSave()) {
            return resultArray as? UIImage
        } else {
            return nil
        }
        
    }
}
