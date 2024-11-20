//
//  UIStackView+Reverse.swift
//  Group
//
//  Created by CatSlave on 11/11/24.
//

import UIKit

extension UIStackView {

    func reverseSubviewsZIndex(setNeedsLayout: Bool = true) {
        let stackedViews = self.arrangedSubviews

        stackedViews.forEach {
            self.removeArrangedSubview($0)
        }
        
        stackedViews.reversed().forEach(addArrangedSubview(_:))
    }
}
