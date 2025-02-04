//
//  TransitionControllable.swift
//  Mople
//
//  Created by CatSlave on 1/14/25.
//

import UIKit

protocol TransitionControllable: NSObject, UIViewControllerTransitioningDelegate {
    var presentTransition: AppTransition { get set }
    var dismissTransition: AppTransition { get set }
    func setupTransition()
}

extension TransitionControllable where Self: UIViewController {
    func setupTransition() {
        modalPresentationStyle = .fullScreen
        dismissTransition.setupDismissGesture(for: self)
    }
    
    func presentWithTransition(_ viewControllerToPresent: UIViewController,
                               completion: (() -> Void)? = nil) {
        viewControllerToPresent.transitioningDelegate = self
        present(viewControllerToPresent, animated: true, completion: completion)
    }
}
