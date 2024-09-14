//
//  UIView+BounceAnimate.swift
//  Group
//
//  Created by CatSlave on 9/15/24.
//

import UIKit

extension UIView {
    static func bounceAnimate(animations: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.3,
                       options: .curveEaseInOut,
                       animations: animations)
    }
}
