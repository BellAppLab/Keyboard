import ObjectiveC
import UIKit


//MARK: - ORIGINAL CONSTANTS
//MARK: - Assotiation Keys
private extension AssociationKeys {
    static var originalConstants = "com.bellapplab.originalConstants.key"
}


//MARK: - UIViewController + Original Constants
@nonobjc
internal extension UIViewController
{
    fileprivate(set) var originalConstants: [String: CGFloat]? {
        get {
            guard handlesKeyboard,
                let nsDictionary = objc_getAssociatedObject(self, &AssociationKeys.originalConstants) as? NSDictionary
            else {
                return nil
            }

            var result = [String: CGFloat]()
            nsDictionary.forEach {
                if let key = $0.key as? String, let constant = ($0.value as? NSNumber)?.doubleValue {
                    result[key] = CGFloat(constant)
                }
            }
            return result
        }
        set {
            let nsDictionary: NSDictionary?
            let dictionary = newValue?.mapValues { NSNumber(floatLiteral: Double($0)) }
            if handlesKeyboard, dictionary != nil {
                nsDictionary = NSDictionary(dictionary: dictionary!)
            } else {
                nsDictionary = nil
            }
            objc_setAssociatedObject(self,
                                     &AssociationKeys.originalConstants,
                                     nsDictionary,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


//MARK: - KEYBOARD CONSTRAINTS
//MARK: - Assotiation Keys
private extension AssociationKeys {
    static var keyboardConstraints = "com.bellapplab.keyboardConstraints.key"
}


//MARK: - UIViewController + Keyboard Constraints
@nonobjc
public extension UIViewController
{
    internal var hasKeyboardConstraints: Bool {
        return handlesKeyboard && keyboardConstraints?.isEmpty ?? true == false
    }

    internal func setKeyboardConstraintsToOriginal() {
        guard hasKeyboardConstraints else { return }
        keyboardConstraints?.forEach {
            $0.constant = originalConstants![$0.identifier!]!
        }
        view.layoutIfNeeded()
    }

    internal func setKeyboardConstraints(intersection: CGRect) {
        guard hasKeyboardConstraints, intersection != .zero else { return }
        keyboardConstraints?.forEach {
            if $0.isCenterY {
                $0.constant = originalConstants![$0.identifier!]! - intersection.height
            } else {
                $0.constant = originalConstants![$0.identifier!]! + intersection.height
            }
        }
    }

    /// The collection of `NSLayoutConstraint`s that should be updated when the keyboard changes.
    /// - note: This should only be used if you are using autolayout.
    @IBOutlet var keyboardConstraints: [NSLayoutConstraint]? {
        get {
            if let nsArray = objc_getAssociatedObject(self, &AssociationKeys.keyboardConstraints) as? NSArray {
                #if swift(>=4.0)
                return nsArray.compactMap { $0 as? NSLayoutConstraint }
                #else
                return nsArray.flatMap { $0 as? NSLayoutConstraint }
                #endif
            }
            return nil
        }
        set {
            Keyboard.yo()
            if newValue == nil {
                originalConstants = nil
            } else {
                var constants: [String: CGFloat] = [:]
                let token = "__bl__"
                (0..<newValue!.count).forEach { i in
                    let constraint = newValue![i]
                    if constraint.identifier?.contains(token) ?? false == false {
                        constraint.identifier = "\(constraint.identifier ?? "")\(token)\(i)"
                    }
                    constants[constraint.identifier!] = constraint.constant
                }
                originalConstants = constants
            }
            objc_setAssociatedObject(self,
                                     &AssociationKeys.keyboardConstraints,
                                     newValue != nil ? NSArray(array: newValue!) : nil,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


//MARK: - Aux
fileprivate extension NSLayoutConstraint
{
    var isCenterY: Bool {
        return firstAttribute == .centerY ||
            firstAttribute == .centerYWithinMargins ||
            secondAttribute == .centerY ||
            secondAttribute == .centerYWithinMargins
    }
}
