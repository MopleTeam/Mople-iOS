//
//  ScrollKeyboardResponsive.swift
//  Mople
//
//  Created by CatSlave on 1/23/25.
//

import UIKit
import RxSwift

protocol ScrollKeyboardResponsive: KeyboardResponsive {
    var scrollView: UIScrollView? { get }
    var scrollViewHeight: CGFloat? { get set }
    var startOffsetY: CGFloat { get set }
}

extension ScrollKeyboardResponsive where Self: UIViewController {

    func handleKeyboardShow(_ sender: Notification) {
        guard let height = getKeyboardHeight(from: sender),
              let duration = getKeyboardDuration(from: sender),
              let animation = getKeyboardAnimation(from: sender) else { return }
        handleKeyboard(duration: duration,
                       option: animation) { [weak self] in
            self?.floatingViewBottom?.update(inset: height)
            self?.handleContentOffsetY(height)
        }
        
        setKeyboardHeight(height)
    }

    func handleKeyboardHide(_ sender: Notification) {
        guard let duration = getKeyboardDuration(from: sender),
              let animation = getKeyboardAnimation(from: sender),
              let scrollView else { return }
        
        keyboardHeight = nil
        handleKeyboard(duration: duration,
                       option: animation) { [weak self] in
            guard let self else { return }
            self.floatingViewBottom?.update(inset: UIScreen.getBottomSafeAreaHeight())
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
            scrollView.contentOffset.y += height - UIScreen.getBottomSafeAreaHeight()
        } else {
            let diffOffsetY = getKeyboardHeightDiff(height)
            self.setContentOffsetY(scrollView: scrollView,
                                   offsetY: diffOffsetY)
        }
    }
    
    private func setContentOffsetY(scrollView: UIScrollView,
                                   offsetY: CGFloat) {
        if scrollView.isBottom() {
            scrollView.contentOffset.y = scrollView.contentOffsetMaxY
        } else {
            scrollView.contentOffset.y += offsetY
        }
    }
}

