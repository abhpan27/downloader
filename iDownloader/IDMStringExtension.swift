//
//  IDMStringExtension.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

extension String {
    
    var isValidUrl:Bool {
        // create NSURL instance
        if let _ = URL(string: self) {
            return true
        }
        return false
    }
    
    var stringForFilePath: String {
        //taken from here - https://kb.acronis.com/content/39790
        let characterSet = NSCharacterSet(charactersIn: "\"\\/?<>:*|") as CharacterSet
        
        return components(separatedBy: characterSet).joined(separator: "-")
    }
    
    var percentEncoded:String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
    
    var encrypted:String?{
        let password = Constants.encyptionKey
        let encrypted = AES256CBC.encryptString(self, password: password)
        return encrypted
    }
    
    var decrypted:String? {
        let decrypted = AES256CBC.decryptString(self, password: Constants.encyptionKey)
        return decrypted
    }
}
