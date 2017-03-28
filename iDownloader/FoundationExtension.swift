//
//  FoundationExtension.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa


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
    
    /// Get extended attribute.
    func extendedAttribute(forName name: String) throws -> Data  {
        
        let data = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> Data in
            
            // Determine attribute size:
            let length = getxattr(fileSystemPath, name, nil, 0, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }
            
            // Create buffer with required size:
            var data = Data(count: length)
            
            // Retrieve attribute:
            let result =  data.withUnsafeMutableBytes {
                getxattr(fileSystemPath, name, $0, data.count, 0, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
            return data
        }
        return data
    }
    
    /// Set extended attribute.
    func setExtendedAttribute(data: Data, forName name: String) throws {
        
        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = data.withUnsafeBytes {
                setxattr(fileSystemPath, name, $0, data.count, 0, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
        }
    }
    
    /// Remove extended attribute.
    func removeExtendedAttribute(forName name: String) throws {
        
        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = removexattr(fileSystemPath, name, 0)
            guard result >= 0 else { throw URL.posixError(errno) }
        }
    }
    
    /// Get list of all extended attributes.
    func listExtendedAttributes() throws -> [String] {
        
        let list = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> [String] in
            let length = listxattr(fileSystemPath, nil, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }
            
            // Create buffer with required size:
            var data = Data(count: length)
            
            // Retrieve attribute list:
            let result = data.withUnsafeMutableBytes {
                listxattr(fileSystemPath, $0, data.count, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
            
            // Extract attribute names:
            let list = data.split(separator: 0).flatMap {
                String(data: Data($0), encoding: .utf8)
            }
            return list
        }
        return list
    }
    
    /// Helper function to create an NSError from a Unix errno.
    private static func posixError(_ err: Int32) -> NSError {
        return NSError(domain: NSPOSIXErrorDomain, code: Int(err),
                       userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(err))])
    }
}

extension Array where Element: FloatingPoint {
    var total: Element {
        return reduce(0, +)
    }
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}

extension NSDraggingInfo {
    func downloadURL() -> NSURL? {
        let pasteBoard = draggingPasteboard()
        let url = NSURL(from: pasteBoard)
        return url
    }
}

