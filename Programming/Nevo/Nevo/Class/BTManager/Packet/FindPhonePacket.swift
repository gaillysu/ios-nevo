//
//  FindPhonePacket.swift
//  Nevo
//
//  Created by Cloud on 2016/10/20.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class FindPhonePacket: NevoPacket {
    /*
     This header is the key by find phone
     */
    class func HEADER() -> UInt8 {
        return 0x45
    }
}
