//
//  UIViewController+RootNavi.swift
//  Mople
//
//  Created by CatSlave on 7/3/25.
//

import UIKit

extension UIViewController {
    func findCurrentNavigation() -> UINavigationController? {
        if let nav = self.navigationController {
            return nav
        }
        if let parent = self.parent {
            return parent.findCurrentNavigation()
        }
        if let presenter = self.presentingViewController {
            return presenter.findCurrentNavigation()
        }
        return nil
    }
}
