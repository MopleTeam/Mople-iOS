//
//  MainNavigationController.swift
//  Group
//
//  Created by CatSlave on 10/15/24.
//

import UIKit

final class MainNavigationController: UINavigationController { }

extension MainNavigationController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}
