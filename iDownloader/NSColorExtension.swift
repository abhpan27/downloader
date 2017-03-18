//
//  NSColorExtension.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

extension NSColor {
    
    convenience init(IDMr:CGFloat, g:CGFloat, b:CGFloat, alpha:CGFloat? = 1) {
         self.init(red: IDMr/255, green: g/255, blue: b/255, alpha: alpha!)
    }
}
