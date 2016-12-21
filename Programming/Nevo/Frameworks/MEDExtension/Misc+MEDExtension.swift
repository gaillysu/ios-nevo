//
//  Misc+MEDExtension.swift
//  Nevo
//
//  Created by Quentin on 21/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation

public func debugLog(_ items: Any...) {
    #if DEBUG
        print(items)
    #else
    
    #endif
}

public func debugLog(_ items: Any..., separator: String, terminator: String) {
    #if DEBUG
        print(items, separator: separator, terminator: terminator)
    #else
        
    #endif
}
