//
//  NSColorExtension.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

extension NSObject {
    
    func RGB(r:CGFloat, g:CGFloat, b:CGFloat, alpha:CGFloat? = 1) -> NSColor {
        return NSColor(red: r/255, green: g/255, blue: b/255, alpha: alpha!)
    }
}
