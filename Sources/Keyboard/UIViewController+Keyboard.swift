import ObjectiveC
import UIKit


internal struct AssociationKeys {}


private extension AssociationKeys {
    static var handlesKeyboard = "com.bellapplab.handlesKeyboard.key"
    static var keyboardMargin = "com.bellapplab.keyboardMargin.key"
}


@objc
public extension UIViewController
{
    /// Toggles the `Keyboard` framework in this view controller.
    @IBInspectable var handlesKeyboard: Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociationKeys.handlesKeyboard) as? NSNumber)?.boolValue ?? true
        }
        set {
            Keyboard.yo()
            objc_setAssociatedObject(self,
                                     &AssociationKeys.handlesKeyboard,
                                     NSNumber(booleanLiteral: newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Sets a margin between the keyboard and the currently active text input.
    ///
    /// Defaults to 40.0.
    @IBInspectable var keyboardMargin: NSNumber {
        get {
            return (objc_getAssociatedObject(self, &AssociationKeys.keyboardMargin) as? NSNumber) ?? NSNumber(floatLiteral: 40.0)
        }
        set {
            Keyboard.yo()
            objc_setAssociatedObject(self,
                                     &AssociationKeys.handlesKeyboard,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


private extension AssociationKeys {
    static var keyboardWasVisible = "com.bellapplab.handlesKeyboard.key"
}


fileprivate extension UIViewController
{
    var margin: CGFloat {
        return CGFloat(keyboardMargin.doubleValue) + 20.0
    }

    var keyboardWasVisible: Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociationKeys.keyboardWasVisible) as? NSNumber)?.boolValue ?? false
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociationKeys.keyboardWasVisible,
                                     NSNumber(booleanLiteral: newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


public extension KeyboardChangeHandler where Self: UIViewController
{
    func handleKeyboardChange(_ change: Keyboard.Change)
    {
        // Validating the View Controller's setup
        guard hasKeyboardConstraints || hasKeyboardViews else {
            assertionFailure("Keyboard says: \n\tTo correctly handle the keyboard, View Controllers must either set 'keyboardConstraints' or 'keyboardViews' in: \(self.classForCoder)")
            return
        }

        setKeyboardConstraintsToOriginal()
        let keyboardIsVisible = Keyboard.default.isVisible
        if keyboardWasVisible == false && keyboardIsVisible {
            makeOriginalFrames()
        }
        setKeyboardViewsToOriginal()

        let intersection = change.intersectionOfFinalRect(with: view.currentFirstResponder,
                                                          andMargin: margin,
                                                          in: view)
        setKeyboardConstraints(intersection: intersection)

        let animations: () -> Void = { [weak self] in
            if self?.hasKeyboardConstraints ?? false {
                self?.view.layoutIfNeeded()
            }
            self?.setKeyboardFrames(intersection: intersection)
        }

        UIView.animate(withDuration: change.transitionDuration,
                       delay: 0.0,
                       options: change.transitionAnimationOptions,
                       animations: animations)
        { [weak self] finished in
            guard finished else { return }
            self?.keyboardWasVisible = keyboardIsVisible
        }
    }
}
