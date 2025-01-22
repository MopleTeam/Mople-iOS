//
//  ScrollKeyboardResponsive.swift
//  Mople
//
//  Created by CatSlave on 1/23/25.
//

import UIKit

protocol ScrollKeyboardResponsive: KeyboardResponsive {
    var scrollView: UIScrollView { get }
    var startOffsetY: CGFloat { get set }
}

extension ScrollKeyboardResponsive where Self: UIViewController {
    private var isScroll: Bool {
        scrollView.bounds.height < scrollView.contentSize.height
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
        let currentScrollState = isScroll
        
        guard let keyBoardheight = getKeyboardHeight(from: sender),
              let duration = getKeyboardDuration(from: sender),
              let animation = getKeyboardAnimation(from: sender) else { return }

        handleKeyboard(duration: duration,
                       option: animation) { [weak self] in
            self?.floatingViewBottom?.update(inset: keyBoardheight)
        }
            
        guard currentScrollState else { return }
        startOffsetY = scrollView.contentOffset.y
        scrollView.contentOffset.y += keyBoardheight
    }

    private func handleKeyboardHide(_ sender: Notification) {
        guard let duration = getKeyboardDuration(from: sender),
              let animation = getKeyboardAnimation(from: sender) else { return }

        handleKeyboard(duration: duration,
                       option: animation) { [weak self] in
            guard let self else { return }
            self.floatingViewBottom?.update(inset: UIScreen.getDefatulBottomInset())
            self.scrollView.contentOffset.y = self.startOffsetY
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
