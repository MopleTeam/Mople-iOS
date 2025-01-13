//
//  AppNavigationController.swift
//  Mople
//
//  Created by CatSlave on 1/12/25.
//

import UIKit

final class AppNaviViewController: UINavigationController {
    
    private let presentTransition = NavigationTransition(type: .present)
    private let dismissTransition = NavigationTransition(type: .dismiss)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        initalSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initalSetup() {
        self.navigationBar.isHidden = true
        self.modalPresentationStyle = .fullScreen
        self.dismissTransition.setupDismissGesture(for: self)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.transitioningDelegate = self
        super.present(viewControllerToPresent,
                      animated: flag,
                      completion: completion)
    }
}

extension AppNaviViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
    
    func interactionControllerForDismissal(using animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
        return dismissTransition.interactionController
    }
}

