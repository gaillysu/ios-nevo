//
//  PostConnectionState.swift
//  Nevo
//
//  Created by Cloud on 2017/5/17.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit

class PostConnectionState: NSObject {
    var isConnected: Bool?
    var fromAddress: UUID?
    var isFirstPair: Bool?
    
    init(_ state: Bool?, address: UUID?, pairState: Bool?) {
        super.init()
        isConnected = state
        fromAddress = address
        isFirstPair = pairState
    }
}
