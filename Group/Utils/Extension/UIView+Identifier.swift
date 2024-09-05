//
//  UIView+Identifier.swift
//  Group
//
//  Created by CatSlave on 9/5/24.
//

import UIKit

extension UIView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
