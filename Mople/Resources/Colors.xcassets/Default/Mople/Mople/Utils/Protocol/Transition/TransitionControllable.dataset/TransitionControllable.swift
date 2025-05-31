//
//  TransitionControllable.swift
//  Mople
//
//  Created by CatSlave on 1/14/25.
//

import UIKit

// MARK: - 플로우 용도
protocol TransitionControllable: NSObject, UIViewControllerTransitioningDelegate {
    var presentTransition: AppTransition { get }
    var dismissTransition: AppTransition { get }
    func setupTransition()
}

extension TransitionControllable where Self: UIViewController {
    
    func setupTransition() {
        modalPresentationStyle = .fullScreen
        dismissTransition.setupDismissGesture(for: self)
    }
    
    func presentWithTransition(_ viewController: UIViewController,
                               completion: (() -> Void)? = nil) {
        viewController.transitioningDelegate = self
        present(viewController, animated: true, completion: completion)
    }
}

// MARK: - 뷰 Dismiss 제스처 용도
protocol DismissTansitionControllabel: NSObject {
    var dismissTransition: AppTransition { get }
    func setupTransition()
}

extension DismissTansitionControllabel where Self: UIViewController {
    func setupTransition() {
        guard self.navigationController == nil else { return }
        modalPresentationStyle = .fullScreen
        dismissTransition.setupDismissGesture(for: self)
    }
}
