import Foundation
import UIKit

protocol KeyboardEvent: AnyObject {
    var transformView: UIView { get }
    var contentView: UIView { get }
    func setupKeyboardEvent()
    func removeKeyboardObserver()
}

#warning("contentView와 겹치는 부분이 발생하는 경우 대비")
extension KeyboardEvent where Self: UIViewController {
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
        print(#fileID, #function, #line, "- sender: \(sender)")
        
        if let keyboardSize = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
           let curve = sender.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        {
            
            let keyboardHeight = keyboardSize.height
            let animationOptions = UIView.AnimationOptions(rawValue: curve)
            
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: animationOptions,
                           animations: {
                self.contentView.snp.updateConstraints { make in
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(keyboardHeight + 10)
                }
                self.view.layoutIfNeeded()
            })
        }
    }
    
    private func handleKeyboardHide(_ sender: Notification) {
        print(#fileID, #function, #line, "- sender: \(sender)")
        
        if let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
           let curve = sender.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        {
            let animationOptions = UIView.AnimationOptions(rawValue: curve)
            
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: animationOptions,
                           animations: {
                self.contentView.snp.updateConstraints { make in
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset((UIScreen.hasNotch() ? 0 : 28))
                }
                self.view.layoutIfNeeded()
            })
        }
    }
}
