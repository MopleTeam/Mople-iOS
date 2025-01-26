//
//  ScrollKeyboardResponsive.swift
//  Mople
//
//  Created by CatSlave on 1/23/25.
//

import UIKit

protocol ScrollKeyboardResponsive: KeyboardResponsive {
    var scrollView: UIScrollView? { get }
    var scrollViewHeight: CGFloat? { get set }
    var startOffsetY: CGFloat { get set }
    var remainingOffsetY: CGFloat { get set }
}

extension ScrollKeyboardResponsive where Self: UIViewController {
 
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
        handleContentOffsetY(height)
        setKeyboardHeight(height)
    }

    private func handleKeyboardHide(_ sender: Notification) {
        guard let duration = getKeyboardDuration(from: sender),
              let animation = getKeyboardAnimation(from: sender),
              let scrollView else { return }
        
        keyboardHeight = nil
        handleKeyboard(duration: duration,
                       option: animation) { [weak self] in
            guard let self else { return }
            self.floatingViewBottom?.update(inset: UIScreen.getDefatulBottomInset())
            scrollView.contentOffset.y = self.startOffsetY
        }
    }

    private func handleKeyboard(duration: CGFloat,
                                option: UIView.AnimationOptions,
                                animation: @escaping (() -> Void)) {
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: option,
            animations: { [weak self] in
                guard let self else { return }
                animation()
                self.view.layoutIfNeeded()
            }
        )
    }
}

extension ScrollKeyboardResponsive where Self: UIViewController {
    private var isScroll: Bool {
        guard let scrollView,
              let scrollViewHeight else { return false }
        return scrollViewHeight < scrollView.contentSize.height
    }
    
    private func handleContentOffsetY(_ height: CGFloat) {
        guard isScroll,
              let scrollView else { return }
        
        if keyboardHeight == nil {
            startOffsetY = scrollView.contentOffset.y
            scrollView.contentOffset.y += height
        } else {
            let diffOffsetY = getKeyboardHeightDiff(height)
            self.setRemaingOffsetY(scrollView: scrollView,
                                   offsetY: diffOffsetY)
            self.setContentOffsetY(scrollView: scrollView,
                                   offsetY: diffOffsetY)
        }
    }
    
    private func setContentOffsetY(scrollView: UIScrollView,
                                   offsetY: CGFloat) {
        if scrollView.isBottom() {
            scrollView.contentOffset.y += remainingOffsetY
        } else {
            scrollView.contentOffset.y += offsetY
        }
    }
    
    private func setRemaingOffsetY(scrollView: UIScrollView,
                                   offsetY: CGFloat) {
        guard offsetY > 0 else { return }
        let contentHeight = scrollView.contentSize.height
        let maxY = scrollView.contentOffsetMaxY
        let calculateOffsetY = contentHeight - maxY
        remainingOffsetY = calculateOffsetY.truncatingRemainder(dividingBy: offsetY)
        remainingOffsetY.negate()
    }
}
