//
//  FoundationExtension.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Foundation


func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func runInMainThread(closure:@escaping ()->()) {
    DispatchQueue.main.async {
        closure()
    }
}

func runAfterDelay(delay:Double, closure:@escaping ()->()){
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

extension Date{
    
    var representableDate:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: self)
    }
}

extension URL {
    
    var urlAfterResolvingSytemLink:URL {
        return self.resolvingSymlinksInPath()
    }
}

