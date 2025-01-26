//
//  TransformKeyboardResponsive.swift
//  Mople
//
//  Created by CatSlave on 1/23/25.
//

import UIKit

protocol TransformKeyboardResponsive: KeyboardResponsive {
    var adjustableView: UIView { get }
    var overlapOffsetY: CGFloat? { get set }
}

extension TransformKeyboardResponsive where Self: UIViewController {
    
    var floatingViewFrame: CGRect {
        containerView.convert(floatingView.frame,
                              from: floatingView.superview)
    }
    
    var adjustableViewFrame: CGRect {
        containerView.convert(adjustableView.frame,
                              from: adjustableView.superview)
    }
    
    var calculateOverlap: CGFloat {
        adjustableViewFrame.maxY - floatingViewFrame.minY + threshold
    }
    
    func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: .main) { [weak self] notification in
            self?.handleKeyboardShow(notification)
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: .main) { [weak self] notification in
            self?.handleKeyboardHide(notification)
        }
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func handleKeyboardShow(_ sender: Notification) {
        guard let height = getKeyboardHeight(from: sender),
              let duration = getKeyboardDuration(from: sender),
              let animation = getKeyboardAnimation(from: sender) else { return }
        handleKeyboard(duration: duration,
                       option: animation) { [weak self] in
            self?.floatingViewBottom?.update(inset: height)
        }
        handleOverlab(height: height)
        setKeyboardHeight(height)
    }

    private func handleKeyboardHide(_ sender: Notification) {
        guard let duration = getKeyboardDuration(from: sender),
              let animation = getKeyboardAnimation(from: sender) else { return }
        keyboardHeight = nil
        handleKeyboard(duration: duration,
                       option: animation) { [weak self] in
            self?.floatingViewBottom?.update(inset: UIScreen.getDefatulBottomInset())
            self?.resetScrollViewTransform()
        }
    }
    
    private func handleKeyboard(duration: CGFloat,
                                option: UIView.AnimationOptions,
                                animation: @escaping (() -> Void)) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: option,
            animations: {
                animation()
                self.view.layoutIfNeeded()
            }
        )
    }
}

extension TransformKeyboardResponsive where Self: UIViewController {
    private func handleOverlab(height : CGFloat) {
        if overlapOffsetY == nil {
            setTransform()
        } else {
            handleKeyboardHeight(height)
        }
    }
    
    private func setTransform() {
        guard calculateOverlap > 0 else { return }
        overlapOffsetY = -calculateOverlap
        adjustableView.transform = CGAffineTransform(translationX: 0, y: -calculateOverlap)
    }
    
    private func handleKeyboardHeight(_ height: CGFloat) {
        guard let overlapOffsetY else { return }
        let diffOffsetY = getKeyboardHeightDiff(height)
        
        if diffOffsetY > 0 {
            let calculateOverlapOffsetY : CGFloat = overlapOffsetY - diffOffsetY
            adjustableView.transform = CGAffineTransform(translationX: 0,
                                                         y: calculateOverlapOffsetY)
        } else {
            adjustableView.transform = CGAffineTransform(translationX: 0, y: overlapOffsetY)
        }
    }
    
    private func resetScrollViewTransform() {
        guard !adjustableView.transform.isIdentity else { return }
        self.adjustableView.transform = .identity
    }
}
