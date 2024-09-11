//
//  UIView+Masking.swift
//  Group
//
//  Created by CatSlave on 9/11/24.
//

import UIKit

extension UIView {
    func addMasking() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            AppDesign.mainBackColor.cgColor,
            UIColor.clear.cgColor
        ]

        gradientLayer.frame = self.bounds
        
        self.layer.mask = gradientLayer
    }
}
