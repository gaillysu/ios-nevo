//
//  Dispatch+MEDExtension.swift
//  Nevo
//
//  Created by Quentin on 14/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import Dispatch

extension DispatchQueue {
    fileprivate static var _onceMarker: [String] = []
    
    /// Do the block once!
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceMarker.contains(token) {
            return
        }
        
        _onceMarker.append(token)
        block()
    }
}
