//
//  IDMMouseEventBlockingView.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

protocol MouseDownDelgate:class {
    func didMouseDown()
}

class IDMMouseEventBlockingView: NSView {

    weak var delegate:MouseDownDelgate?
    override func mouseDown(with event: NSEvent) {
        delegate?.didMouseDown()
    }

}
