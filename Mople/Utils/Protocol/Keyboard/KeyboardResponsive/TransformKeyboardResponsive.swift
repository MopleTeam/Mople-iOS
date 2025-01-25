//
//  TransformKeyboardResponsive.swift
//  Mople
//
//  Created by CatSlave on 1/23/25.
//

import UIKit

protocol TransformKeyboardResponsive: KeyboardResponsive {
    var adjustableView: UIView { get }
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
    
    var overlapOffsetY: CGFloat {
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
        guard let keyBoardheight = getKeyboardHeight(from: sender),
              let duration = getKeyboardDuration(from: sender),
              let animation = getKeyboardAnimation(from: sender) else { return }
        
        handleKeyboard(duration: duration,
                       option: animation) { [weak self] in
            self?.floatingViewBottom?.update(inset: keyBoardheight)
        }
        handleOverlab(isRespon: true)
    }

    private func handleKeyboardHide(_ sender: Notification) {
        guard let duration = getKeyboardDuration(from: sender),
              let animation = getKeyboardAnimation(from: sender) else { return }
        handleKeyboard(duration: duration,
                       option: animation) { [weak self] in
            self?.floatingViewBottom?.update(inset: UIScreen.getDefatulBottomInset())
            self?.handleOverlab(isRespon: false)
        }
    }
    
    private func handleOverlab(isRespon: Bool) {
        if isRespon {
            adjustScrollViewTransform()
        } else {
            resetScrollViewTransform()
        }
    }
    
    private func adjustScrollViewTransform() {
        guard overlapOffsetY > 0 else { return }
        adjustableView.transform = CGAffineTransform(translationX: 0, y: -overlapOffsetY)
    }
    
    private func resetScrollViewTransform() {
        guard !adjustableView.transform.isIdentity else { return }
        self.adjustableView.transform = .identity
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
