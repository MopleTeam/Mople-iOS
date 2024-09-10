import Foundation
import UIKit

protocol KeyboardEvent: AnyObject {
    var transformView: UIView { get }
    var transformScrollView: UIScrollView { get }
    var contentView: UIView { get }
    func setupKeyboardEvent()
}

extension KeyboardEvent where Self: UIViewController {
    func setupKeyboardEvent() {
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: .main) { [weak self] notification in
            self?.keyboardWillAppear(notification)
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: .main) { [weak self] notification in
            self?.keyboardWillDisappear(notification)
        }
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func keyboardWillAppear(_ sender: Notification) {

        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        transformScrollView.alwaysBounceVertical = true
        let convertedTextFieldFrame = transformView.convert(contentView.frame,
                                                  from: transformScrollView)
        
        let contentBottomY = convertedTextFieldFrame.maxY
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        
        if contentBottomY > keyboardTopY {
            let newFrame = contentBottomY - keyboardTopY
            self.transformScrollView.contentOffset.y = newFrame + 20
        }
    }
    
    private func keyboardWillDisappear(_ sender: Notification) {
        transformScrollView.alwaysBounceVertical = false
        
        if self.transformScrollView.contentOffset.y != 0 {
            self.transformScrollView.contentOffset.y = 0
        }
    }
}
