
import UIKit
import SnapKit

protocol KeyboardResponsive: AnyObject {
    var keyboardHeight: CGFloat? { get set }
    var keyboardHeightDiff: CGFloat? { get set }
    var containerView: UIView { get }
    var floatingView: UIView { get }
    var floatingViewBottom: Constraint? { get }
    var threshold: CGFloat { get }
}

extension KeyboardResponsive where Self: UIViewController {
    var containerView: UIView { self.view }
    var threshold: CGFloat { 10 }
    
    func getKeyboardHeightDiff(_ height: CGFloat) -> CGFloat {
        guard let keyboardHeight else { return .zero }
        
        if height > keyboardHeight {
            let diff = height - keyboardHeight
            keyboardHeightDiff = diff
            return diff
        } else {
            guard var keyboardHeightDiff else { return .zero }
            keyboardHeightDiff.negate()
            return keyboardHeightDiff
        }
        
    }
    
    func getKeyboardHeight(from notification: Notification) -> CGFloat? {
        guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                as? CGRect else { return nil }
        return keyboardSize.height - UIScreen.getNotchSize() + threshold
    }
    
    func getKeyboardDuration(from notification: Notification) -> TimeInterval? {
        notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
    }
    
    func getKeyboardAnimation(from notification: Notification) -> UIView.AnimationOptions? {
        guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey]
                as? UInt else { return nil}
        return UIView.AnimationOptions(rawValue: curve)
    }
    
    func setKeyboardHeight(_ height: CGFloat?) {
        guard keyboardHeight == nil else { return }
        keyboardHeight = height
    }
}
