//
//  ResizeImage.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 2/7/16.
//  Copyright © 2016 lit.wa.yuen. All rights reserved.
//

import Foundation
import UIKit



public func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
    
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newWidth))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newWidth))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

public func UIColorFromRGB(_ colorCode: String, alpha: Float = 1.0) -> UIColor {
    let scanner = Scanner(string:colorCode)
    var color:UInt32 = 0;
    scanner.scanHexInt32(&color)
    
    let mask = 0x000000FF
    let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
    let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
    let b = CGFloat(Float(Int(color) & mask)/255.0)
    
    return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
}

public func tint(_ image: UIImage, color: UIColor) -> UIImage
{
    let ciImage = CIImage(image: image)
    let filter = CIFilter(name: "CIMultiplyCompositing")
    
    let colorFilter = CIFilter(name: "CIConstantColorGenerator")
    let ciColor = CIColor(color: color)
    colorFilter!.setValue(ciColor, forKey: kCIInputColorKey)
    let colorImage = colorFilter!.outputImage
    
    filter!.setValue(colorImage, forKey: kCIInputImageKey)
    filter!.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
    
    return UIImage(ciImage: filter!.outputImage!)
}

public func aroundBorder(_ imageView: UIImageView) {
    imageView.layer.cornerRadius = 5.0
    imageView.layer.borderColor = UIColor.black.cgColor
    imageView.layer.borderWidth = 1.0
    imageView.layer.masksToBounds = true
    
}

public func getEmptyItemImage() -> UIImage {
    return resizeImage(UIImage(named: "empty")!, newWidth: 25)
}

public func getValue<T>(_ jsonData: NSDictionary, fieldName: String) -> T? {
    if let value: T? = jsonData.object(forKey: fieldName) as? T? {
        return value
    }
    else {
        return nil
    }
}


