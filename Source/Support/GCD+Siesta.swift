//
//  GCD+Siesta.swift
//  Siesta
//
//  Created by Paul on 2015/8/27.
//  Copyright © 2015 Bust Out Solutions. All rights reserved.
//

import Foundation

// props to http://stackoverflow.com/a/24318861/239816
internal func dispatch_on_main_queue(after delay: NSTimeInterval, closure: Void -> Void)
    {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))),
        dispatch_get_main_queue(),
        closure)
    }
