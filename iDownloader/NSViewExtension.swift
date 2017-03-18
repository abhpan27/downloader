//
//  NSViewExtension.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

extension NSView {
    final func addFittingSubView(subView:NSView){
        self.translatesAutoresizingMaskIntoConstraints = false
        subView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(subView)
        let topConstraints = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: subView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
        let bottomConstraints = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: subView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
        let leftConstraints = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: subView, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0)
        let rightConstraints = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: subView, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([topConstraints, bottomConstraints, leftConstraints, rightConstraints])
    }
}
