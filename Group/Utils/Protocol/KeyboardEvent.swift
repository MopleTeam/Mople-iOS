
import UIKit
import SnapKit

protocol KeyboardEvent: AnyObject {
    var contentView: UIView { get }
    var bottomConstraints: Constraint? { get set }
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
        if let keyboardSize = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
           let curve = sender.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        {
            let threshold: CGFloat = 10
            let keyboardHeight = keyboardSize.height + threshold
            let animationOptions = UIView.AnimationOptions(rawValue: curve)
            let newInset = keyboardHeight - UIScreen.safeInsetBottom()
            updateBottomInset(duration, animationOptions, newInset)
        }
    }
    
    private func handleKeyboardHide(_ sender: Notification) {
        if let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
           let curve = sender.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        {
            let animationOptions = UIView.AnimationOptions(rawValue: curve)
            let defaultInset: CGFloat = UIScreen.hasNotch() ? 0 : 28
            updateBottomInset(duration, animationOptions, defaultInset)
        }
    }
    
    private func updateBottomInset(_ duration: CGFloat,_ option: UIView.AnimationOptions,_ inset: CGFloat) {
        UIView.animate(withDuration: duration, delay: 0, options: option, animations: {

            self.bottomConstraints?.update(inset: inset)
            self.view.layoutIfNeeded()
        })
    }
}

