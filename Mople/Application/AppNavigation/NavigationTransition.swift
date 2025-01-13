//
//  NavigationTransition.swift
//  Mople
//
//  Created by CatSlave on 1/12/25.
//

import UIKit

final class NavigationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    enum TransitionType {
        case present
        case dismiss
    }
    
    private let type: TransitionType
    private weak var animator: UIViewImplicitlyAnimating?
    private weak var viewController: UIViewController?
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    init(type: TransitionType) {
        self.type = type
        super.init()
    }
    
    // 필수 메서드 1: 애니메이션 시간 설정
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.3
    }
    
    private var transitionContext: UIViewControllerContextTransitioning?
       
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
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: .easeInOut) {
            toView.frame.origin.x = 0
            fromView.frame.origin.x = finalFromX
        }
        
        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        self.animator = animator
        
        if interactionController == nil {
            animator.startAnimation()
        }
    }
}

extension NavigationTransition {
    func setupDismissGesture(for viewController: UIViewController) {
        self.viewController = viewController
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        gesture.delegate = self
        viewController.view.addGestureRecognizer(gesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: view)
        let progress = abs(translation.x / view.bounds.width)
        
        switch gesture.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            viewController?.dismiss(animated: true)
            
        case .changed:
            interactionController?.update(progress)
            
        case .ended:
            let velocity = gesture.velocity(in: view).x
            let shouldComplete = progress > 0.5 || velocity > 500
            
            if shouldComplete {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
            
        default:
            interactionController?.cancel()
            interactionController = nil
        }
    }
}

extension NavigationTransition: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
//            return false
//        }
//        
//        // 제스처 시작 위치 확인
//        let location = panGesture.location(in: gestureRecognizer.view)
//        let edgeSize: CGFloat = 50  // 왼쪽 가장자리 영역 크기
//        
//        // x가 edgeSize보다 작을 때만(왼쪽 가장자리) 제스처 허용
//        return location.x <= edgeSize
//    }
}
