//
//  NavigationTransition.swift
//  Mople
//
//  Created by CatSlave on 1/12/25.
//

import UIKit

enum TransitionType {
    case present
    case dismiss
}

final class AppTransition: NSObject {
    
    // MARK: - Present, Dismiss 애니메이션 용도
    private var transitionContext: UIViewControllerContextTransitioning?
    private let type: TransitionType
    private weak var animator: UIViewImplicitlyAnimating?
    
    // MARK: - 제스처 활용 용도
    private var initialFrame: CGRect?
    private weak var currentView: UIView?
    private weak var viewController: UIViewController?
    private weak var previousViewController: UIViewController?
    private var dismissCompletion: (() -> Void)?
    
    // MARK: - LifeCycle
    init(type: TransitionType) {
        print(#function, #line, "Path : #0412 \(type) 트랜지션 생성 ")
        self.type = type
        super.init()
    }
    
    deinit {
        print(#function, #line, "Path : #0412 \(type) 트랜지션 해제 ")
    }
    
    public func setDismissGestureCompletion(completion: (() -> Void)?) {
        self.dismissCompletion = completion
    }
}

extension AppTransition: UIViewControllerAnimatedTransitioning {
    
    /// 애니메이션 실행시간
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.3
    }
       
    /// 애니메이션 설정
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        let container = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else { return }
        
        container.addSubview(toView)
        
        let screenWidth = container.bounds.width
        let initialX = type == .present ? screenWidth : -screenWidth
        let finalFromX = type == .present ? -screenWidth : screenWidth
        
        toView.frame = fromView.frame
        toView.frame.origin.x = initialX
        
        let timing = UICubicTimingParameters(animationCurve: .easeInOut)
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext),
                                             timingParameters: timing)
        
        animator.addAnimations {
            toView.frame.origin.x = 0
            fromView.frame.origin.x = finalFromX
        }
        
        animator.addCompletion { [weak self] _ in
            self?.animator = nil
            self?.transitionContext = nil
            transitionContext.completeTransition(true)
            if self?.type == .dismiss {
                fromView.removeFromSuperview()
            }
        }
        
        self.animator = animator
        
        animator.startAnimation()
    }
}

extension AppTransition: UIGestureRecognizerDelegate {
    func setupDismissGesture(for viewController: UIViewController) {
        self.viewController = viewController
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        gesture.edges = .left
        gesture.delegate = self
        viewController.view.addGestureRecognizer(gesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view,
              let presentingVC = viewController?.presentingViewController else { return }
        
        let translation = gesture.translation(in: view)
        let progress = min(1, translation.x / view.bounds.width)
        
        switch gesture.state {
        case .began:
            currentView = view
            initialFrame = view.frame
            previousViewController = presentingVC
            if let presentingView = presentingVC.view {
                view.superview?.insertSubview(presentingView, belowSubview: view)
                presentingView.frame = view.frame
                presentingView.frame.origin.x = -presentingView.frame.width * 0.3
            }
        case .changed:
            guard let presentingView = previousViewController?.view else { return }
            view.frame.origin.x = translation.x
            presentingView.frame.origin.x = -presentingView.frame.width * 0.3 * (1 - progress)
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view).x
            let shouldComplete = progress > 0.5 || velocity > 500
            
            if shouldComplete {
                animateTransitionToComplete(currentView: view)
            } else {
                animateTransitionToCancel(currentView: view)
            }
            initialSet()
        default:
            animateTransitionToCancel(currentView: view)
            initialSet()
        }
    }
    
    private func initialSet() {
        currentView = nil
        initialFrame = nil
    }
    
    private func animateTransitionToComplete(currentView: UIView) {
        animateTransition(duration: 0.2,
                          animations: { [weak self] in
            guard let self else { return }
            currentView.frame.origin.x = currentView.frame.width
            self.previousViewController?.view.frame.origin.x = 0
        }, completion: { [weak self] _ in
            currentView.removeFromSuperview()
            self?.viewController?.dismiss(animated: false)
            self?.dismissCompletion?()
        })
    }
    
    private func animateTransitionToCancel(currentView: UIView) {
        animateTransition(duration: 0.2,
                          animations: { [weak self] in
            guard let self else { return }
            currentView.frame.origin.x = 0
            previousViewController?.view.frame.origin.x = -currentView.frame.width
        }, completion: { [weak self] _ in
            self?.previousViewController?.view.removeFromSuperview()
        })
    }
    
    private func animateTransition(duration: CGFloat,
                                animations: @escaping (() -> Void), completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: animations,
                       completion: completion)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let viewController else { return false }

        switch viewController {
        case let navi as UINavigationController:
            return navi.viewControllers.count == 1
        default :
            return true
        }
    }
}
