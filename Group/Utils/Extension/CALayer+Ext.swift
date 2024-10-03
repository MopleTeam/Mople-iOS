//
//  CALayer+Line.swift
//  Group
//
//  Created by CatSlave on 10/3/24.
//

import UIKit

extension CALayer {
    func makeLine(width: CGFloat) {
        self.borderWidth = width
        self.borderColor = AppDesign.Layer.lineColor.cgColor
    }
    
    func makeCornes(radius: CGFloat, corners: CACornerMask) {
        self.cornerRadius = radius
        self.maskedCorners = corners
    }
    
    func makeShadow(_ cgSize: CGSize) {
        self.shadowOpacity = 0.05
        self.shadowRadius = 24
        self.shadowColor = AppDesign.Layer.shadowColor.cgColor
        self.shadowOffset = cgSize
    }
}
