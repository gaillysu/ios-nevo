//
//  WorldClockDidSelectedDelegate.swift
//  Nevo
//
//  Created by Karl-John Chow on 25/10/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import UIKit


protocol WorldClockDidSelectedDelegate:NSObjectProtocol {
    func didSelectedLocalTimeZone(_ cityId:Int)
}
