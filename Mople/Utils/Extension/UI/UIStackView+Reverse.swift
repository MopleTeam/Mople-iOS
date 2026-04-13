//
//  UIStackView+Reverse.swift
//  Group
//
//  Created by CatSlave on 11/11/24.
//

import UIKit
import Domain

extension UIStackView {

    func reverseSubviewsZIndex() {
        let stackedViews = self.arrangedSubviews

        stackedViews.forEach {
            self.removeArrangedSubview($0)
        }
        
        stackedViews.reversed().forEach(addArrangedSubview(_:))
    }
}
