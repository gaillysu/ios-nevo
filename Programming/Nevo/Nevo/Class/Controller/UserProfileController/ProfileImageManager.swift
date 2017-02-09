 //
//  ProfileImageManager.swift
//  Nevo
//
//  Created by leiyuncun on 2016/11/21.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import Kingfisher

fileprivate let m:ProfileImageManager = ProfileImageManager()
public class ProfileImageManager {
    class var shared: ProfileImageManager {
        return m
    }
    
    fileprivate init() {
    }
    
    public func save(image: UIImage) -> Bool {
        if let imageData = DefaultCacheSerializer.default.data(with: image, original: nil) {
            let docuPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let avatarPath = docuPath.appending("/UserProfile_\(NevoAllKeys.MEDAvatarKeyAfterSave())")
            
            do {
                try imageData.write(to: URL(fileURLWithPath: avatarPath), options: .atomic)
            } catch {
                return false
            }
        }
        
        return true
    }
    
    public func getImage() -> UIImage? {
        let docuPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let avatarPath = docuPath.appending("/UserProfile_\(NevoAllKeys.MEDAvatarKeyAfterSave())")
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: avatarPath))
            if let image = DefaultCacheSerializer.default.image(with: data, options: nil) {
                return image
            }
        } catch {
        }
        
        return nil
    }
}
