//
//  TestMode.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class TestMode: NSObject {
    let packetData:[NSData]?

    init(data:[NSData]) {
        packetData = data
    }

    func isTestModel()->Bool {
        let header:UInt8 = NSData2Bytes(packetData![0])[1]
        let instruction:UInt8 = NSData2Bytes(packetData![0])[2]

        if(header == 0xF1 && (instruction == 0x00)){
            //|| instruction == 0x02
            return true;
        }else{
            return false
        }
    }

}
