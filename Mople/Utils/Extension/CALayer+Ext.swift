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
        self.borderColor = ColorStyle.App.storke.cgColor
    }
    
    func makeCornes(radius: CGFloat, corners: CACornerMask) {
        self.cornerRadius = radius
        self.maskedCorners = corners
    }
    
    func makeShadow(opactity: Float,
                    radius: CGFloat,
                    offset: CGSize = .init(width: 0, height: -4),
                    color: UIColor = UIColor.black) {
        self.shadowOpacity = opactity
        self.shadowRadius = radius
        self.shadowOffset = offset
        self.shadowColor = color.cgColor
    }
}
