//
//  ResizeImage.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 2/7/16.
//  Copyright © 2016 lit.wa.yuen. All rights reserved.
//

import Foundation
import UIKit



public func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}
