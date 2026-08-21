//
//  UIImage+Extensions.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/20.
//

import Foundation
import UIKit

extension UIImage {
    
    func resizeTo(to targetSize: CGSize) -> UIImage? {
        
        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: scaledImageSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
