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
        self.borderColor = ColorStyle.App.stroke.cgColor
    }
    
    func makeCornes(radius: CGFloat, corners: CACornerMask) {
        self.cornerRadius = radius
        self.maskedCorners = corners
    }
    
    func makeShadow(_ cgSize: CGSize) {
        self.shadowOpacity = 0.05
        self.shadowRadius = 24
        self.shadowColor = ColorStyle.Gray._01.cgColor
        self.shadowOffset = cgSize
    }
}
