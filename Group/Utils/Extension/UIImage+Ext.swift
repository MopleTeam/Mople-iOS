//
//  UIImage+Ext.swift
//  Group
//
//  Created by CatSlave on 8/25/24.
//

import UIKit

extension UIImage {
    func resize(size: CGSize? = nil, cornerRadius: CGFloat? = nil) -> UIImage? {
        
        var reSizeImage = self
        
        if let reSize = size {
            reSizeImage = UIGraphicsImageRenderer(size: reSize).image { _ in
                self.draw(in: CGRect(origin: .zero, size: reSize))
            }
        }
        
        if let radius = cornerRadius {
            reSizeImage = reSizeImage.roundedImage(withCornerRadius: radius)
        }
        
        return reSizeImage
    }
    
    private func roundedImage(withCornerRadius radius: CGFloat? = nil) -> UIImage {
         let maxRadius = min(size.width, size.height) / 2
         let cornerRadius: CGFloat
         if let radius = radius, radius > 0 && radius <= maxRadius {
             cornerRadius = radius
         } else {
             cornerRadius = maxRadius
         }
         
         let renderer = UIGraphicsImageRenderer(size: size)
         return renderer.image { context in
             let rect = CGRect(origin: .zero, size: size)
             context.cgContext.addPath(UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath)
             context.cgContext.clip()
             
             draw(in: rect)
         }
     }
}
