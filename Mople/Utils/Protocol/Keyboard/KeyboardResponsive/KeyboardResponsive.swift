
import UIKit
import SnapKit

protocol KeyboardResponsive: AnyObject {
    var containerView: UIView { get }
    var floatingView: UIView { get }
    var floatingViewBottom: Constraint? { get }
    var threshold: CGFloat { get }
}

extension KeyboardResponsive where Self: UIViewController {
    var containerView: UIView { self.view }
    var threshold: CGFloat { 10 }
    
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
}
