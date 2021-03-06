//
//  SetBLEConnectionTimeoutRequest
//  Nevo
//
//  Created by Je dikke lul
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

class SetBLEConnectionTimeoutRequest: NevoRequest {

    fileprivate let minutes:UInt16

    class func HEADER() -> UInt8 {
        return 0x46
    }
    
    init(minutes:UInt16) {
        self.minutes = minutes
    }
    
    override func getRawDataEx() -> NSArray {
        let values1 :[UInt8] = [
            0x00,
            SetBLEConnectionTimeoutRequest.HEADER(),
            UInt8(minutes & 0xFF),
            UInt8((minutes >> 8) & 0xFF),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let values2 :[UInt8] = [
            0xFF,
            SetBLEConnectionTimeoutRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
}
