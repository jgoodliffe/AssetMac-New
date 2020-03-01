//
//  ImageResizer.swift
//  Production Manager Pro
//
//  Created by James Goodliffe on 01/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Foundation
import AppKit
import Cocoa

class ImageResizer{
    /**
     Resizes images.
     */
    func resize(image: NSImage, w: Int, h: Int) -> NSImage {
        let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
}
