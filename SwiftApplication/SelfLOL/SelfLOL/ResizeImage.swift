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
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newWidth))
    image.drawInRect(CGRectMake(0, 0, newWidth, newWidth))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}

public func UIColorFromRGB(colorCode: String, alpha: Float = 1.0) -> UIColor {
    let scanner = NSScanner(string:colorCode)
    var color:UInt32 = 0;
    scanner.scanHexInt(&color)
    
    let mask = 0x000000FF
    let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
    let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
    let b = CGFloat(Float(Int(color) & mask)/255.0)
    
    return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
}

public func tint(image: UIImage, color: UIColor) -> UIImage
{
    let ciImage = CIImage(image: image)
    let filter = CIFilter(name: "CIMultiplyCompositing")
    
    let colorFilter = CIFilter(name: "CIConstantColorGenerator")
    let ciColor = CIColor(color: color)
    colorFilter!.setValue(ciColor, forKey: kCIInputColorKey)
    let colorImage = colorFilter!.outputImage
    
    filter!.setValue(colorImage, forKey: kCIInputImageKey)
    filter!.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
    
    return UIImage(CIImage: filter!.outputImage!)
}

public func aroundBorder(imageView: UIImageView) {
    imageView.layer.cornerRadius = 5.0
    imageView.layer.borderColor = UIColor.blackColor().CGColor
    imageView.layer.borderWidth = 1.0
    imageView.layer.masksToBounds = true
    
}

public func getEmptyItemImage() -> UIImage {
    return resizeImage(UIImage(named: "empty")!, newWidth: 25)
}

public func getValue<T>(jsonData: NSDictionary, fieldName: String) -> T? {
    if let value: T? = jsonData.objectForKey(fieldName) as? T? {
        return value
    }
    else {
        return nil
    }
}


