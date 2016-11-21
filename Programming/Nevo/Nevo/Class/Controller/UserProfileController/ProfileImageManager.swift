//
//  ProfileImageManager.swift
//  Nevo
//
//  Created by leiyuncun on 2016/11/21.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation

fileprivate let m:ProfileImageManager = ProfileImageManager()
open class ProfileImageManager {
    class var manager:ProfileImageManager {
        return m
    }
    
    open func save(image:UIImage) {
    }
}
