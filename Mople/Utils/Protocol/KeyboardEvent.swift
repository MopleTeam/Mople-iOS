
import UIKit
import SnapKit

protocol KeyboardEvent: AnyObject {
    var superView: UIView { get }
    var floatingView: UIView { get }
    var scrollView: UIScrollView { get }
    var overlappingView: UIView { get }
    var floatingViewBottom: Constraint? { get set }
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
           let curve = sender.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            let animationOptions = UIView.AnimationOptions(rawValue: curve)
            let threshold: CGFloat = 10
            let keyboardHeight = keyboardSize.height - UIScreen.getNotchSize()
            let newInset = keyboardHeight + threshold
            updateBottomInset(duration, animationOptions, newInset)
            handleOverlab(threshold)
        }
    }

    private func handleKeyboardHide(_ sender: Notification) {
        
        if let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
           let curve = sender.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        {
            let animationOptions = UIView.AnimationOptions(rawValue: curve)
            updateBottomInset(duration, animationOptions, UIScreen.getAdditionalBottomInset())
        }
        scrollView.contentOffset.y = 0
    }
    
    private func updateBottomInset(_ duration: CGFloat,_ option: UIView.AnimationOptions,_ inset: CGFloat) {
        UIView.animate(withDuration: duration, delay: 0, options: option, animations: {

            self.floatingViewBottom?.update(inset: inset)
            self.view.layoutIfNeeded()
        })
    }
    
    private func handleOverlab(_ threshold: CGFloat) {
        let floatingViewFrame = superView.convert(floatingView.frame,
                                                  from: floatingView.superview)
        
        let overlappingViewFrame = superView.convert(overlappingView.frame,
                                                     from: overlappingView.superview)

        let newOffset = overlappingViewFrame.maxY - floatingViewFrame.minY
        if newOffset > 0 {
            scrollView.contentOffset.y = newOffset + threshold
        }
    }
}


