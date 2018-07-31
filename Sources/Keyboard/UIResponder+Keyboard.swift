import UIKit


//MARK: + UIResponder + Keyboard
@nonobjc
public extension UIResponder
{
    /// The `UIResponder` that is currently the first responder.
    public static var currentFirstResponder: UIResponder? {
        return UIApplication.shared.keyWindow?.currentFirstResponder
    }
}


//MARK: - UIView + Keyboard
@nonobjc
public extension UIView
{
    /// The `UIView` that is currently the first responder.
    /// Traverses the receiver's `subviews` if needed.
    public var currentFirstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for view in subviews {
            if let responder = view.currentFirstResponder {
                return responder
            }
        }

        return nil
    }
}
