//
//  Array+Extension.swift
//  Nevo
//
//  Created by Cloud on 2017/5/17.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit

extension Array where Iterator.Element == UInt8 {
    
    func Bytes2Data() -> Data {
        return Data(bytes: UnsafePointer<UInt8>(self), count: self.count)
    }
}
