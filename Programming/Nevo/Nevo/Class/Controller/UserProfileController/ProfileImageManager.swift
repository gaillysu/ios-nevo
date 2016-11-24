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
        _ = AppTheme.KeyedArchiverName(NevoAllKeys.MEDAvatarKeyAfterSave() as NSString, andObject: image)
    }
    
    public func getImage() -> UIImage? {
        let resultArray:NSArray = AppTheme.LoadKeyedArchiverName(NevoAllKeys.MEDAvatarKeyAfterSave() as NSString) as! NSArray
        if resultArray.count > 0 {
            return resultArray.object(at: 0) as? UIImage
        } else {
            return nil
        }
        
    }
}
