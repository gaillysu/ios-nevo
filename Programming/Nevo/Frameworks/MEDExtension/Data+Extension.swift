//
//  Data+Extension.swift
//  Nevo
//
//  Created by Cloud on 2017/5/16.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import Foundation

extension Data {
    func data2Bytes() -> [UInt8] {
        let bytes = UnsafeBufferPointer<UInt8>(start: (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count), count:self.count)
        var ret:[UInt8] = []
        for  byte in bytes {
            ret.append(byte)
        }
        return ret
    }
}
