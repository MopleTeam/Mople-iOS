//
//  UINavigation+Common.swift
//  Mople
//
//  Created by CatSlave on 12/24/24.
//

import UIKit

extension UINavigationController {
    static func createFullScreenNavigation() -> UINavigationController {
        let navi = UINavigationController()
        navi.modalPresentationStyle = .fullScreen
        navi.navigationBar.isHidden = true
        return navi
    }
}
