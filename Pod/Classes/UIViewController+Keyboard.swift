import ObjectiveC
import UIKit


//MARK: - Basic Keyboard Handling
@objc public protocol KeyboardHandler
{
    var handlesKeyboard: Bool { get set }
    var movesStuffForKeyboardFromBottom: Bool { get set }
    @objc func handleKeyboardDidChangeNotification(notification: NSNotification)
}


//MARK: - Managing the Active Text Element
@objc public protocol ActiveTextElementHandler: UITextFieldDelegate, UITextViewDelegate
{
    weak var currentTextElement: UIResponder? { get set }
}

private struct AssociationKeys
{
    static var CurrentTextElementKey = "CurrentTextElementKey"
    static var HandlesKeyboardKey = "HandlesKeyboardKey"
    static var BottomConstraintForKeyboardKey = "BottomConstraintForKeyboardKey"
    static var ViewToMoveForKeyboardKey = "ViewToMoveForKeyboardKey"
    static var OriginalConstantKey = "OriginalConstantKey"
    static var KeyboardReferenceKey = "KeyboardReferenceKey"
}

extension UIViewController: ActiveTextElementHandler
{
    weak public var currentTextElement: UIResponder? {
        get {
            if let result = objc_getAssociatedObject(self, &AssociationKeys.CurrentTextElementKey) as? UIResponder {
                return result
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &AssociationKeys.CurrentTextElementKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    //MARK: Text Field Delegate
    public func textFieldDidBeginEditing(textField: UITextField) {
        self.currentTextElement = textField
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        if self.currentTextElement == textField {
            self.currentTextElement = nil
        }
        
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Text View Delegate
    public func textViewDidBeginEditing(textView: UITextView) {
        self.currentTextElement = textView
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        if self.currentTextElement == textView {
            self.currentTextElement = nil
        }
    }
}


//MARK: - AutoLayout Keyboard Implementation

@objc public protocol AutoLayoutKeyboardHandler: KeyboardHandler
{
    var constraintsForKeyboard: [NSLayoutConstraint]? { get set }
}

@objc public protocol FrameBasedKeyboardHandler: KeyboardHandler
{
    var viewsToMoveForKeyboard: [UIView]? { get set }
}

extension UIViewController: AutoLayoutKeyboardHandler, FrameBasedKeyboardHandler
{
    @IBInspectable public var handlesKeyboard: Bool {
        get {
            if let result = objc_getAssociatedObject(self, &AssociationKeys.HandlesKeyboardKey) as? Bool {
                return result
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &AssociationKeys.HandlesKeyboardKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            //Dummy call to initialize the Keyboard singleton
            Keyboard.visible
            if newValue {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardHandler.handleKeyboardDidChangeNotification(_:)), name: Keyboard.DidChangeNotification, object: nil)
            } else {
                self.originalConstants = nil
                NSNotificationCenter.defaultCenter().removeObserver(self, name: Keyboard.DidChangeNotification, object: nil)
            }
        }
    }
    
    @IBInspectable public var movesStuffForKeyboardFromBottom: Bool {
        get {
            if let result = objc_getAssociatedObject(self, &AssociationKeys.KeyboardReferenceKey) as? Bool {
                return result
            }
            return true
        }
        set {
            objc_setAssociatedObject(self, &AssociationKeys.KeyboardReferenceKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBOutlet public var constraintsForKeyboard: [NSLayoutConstraint]? {
        get {
            if let nsArray = objc_getAssociatedObject(self, &AssociationKeys.BottomConstraintForKeyboardKey) as? NSArray {
                var result = [NSLayoutConstraint]()
                for object in nsArray {
                    result.append(object as! NSLayoutConstraint)
                }
                return result
            }
            return nil
        }
        set {
            if newValue != nil {
                if self.originalConstants == nil {
                    var constants = [CGFloat]()
                    for constraint in newValue! {
                        constants.append(constraint.constant)
                    }
                    self.originalConstants = constants
                }
            } else {
                self.originalConstants = nil
            }
            objc_setAssociatedObject(self, &AssociationKeys.BottomConstraintForKeyboardKey, newValue != nil ? NSArray(array: newValue!) : nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBOutlet public var viewsToMoveForKeyboard: [UIView]? {
        get {
            if let nsArray = objc_getAssociatedObject(self, &AssociationKeys.ViewToMoveForKeyboardKey) as? NSArray {
                var result = [UIView]()
                for object in nsArray {
                    result.append(object as! UIView)
                }
                return result
            }
            return nil
        }
        set {
            if newValue != nil {
                if self.originalConstants == nil {
                    var constants = [CGFloat]()
                    for view in newValue! {
                        constants.append(view.frame.origin.y)
                    }
                    self.originalConstants = constants
                }
            } else {
                self.originalConstants = nil
            }
            objc_setAssociatedObject(self, &AssociationKeys.ViewToMoveForKeyboardKey, newValue != nil ? NSArray(array: newValue!) : nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var originalConstants: [CGFloat]? {
        get {
            if let nsArray = objc_getAssociatedObject(self, &AssociationKeys.OriginalConstantKey) as? NSArray {
                var result = [CGFloat]()
                for object in nsArray {
                    result.append(object as! CGFloat)
                }
                return result
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &AssociationKeys.OriginalConstantKey, newValue != nil ? NSArray(array: newValue!) : nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc public func handleKeyboardDidChangeNotification(notification: NSNotification)
    {
        if self.originalConstants == nil
        { // Validating the View Controller's setup
            assertionFailure("To correctly handle the keyboard, View Controllers must either set 'constraintsForKeyboard' or 'viewsToMoveForKeyboard' in: \(self.classForCoder)")
        }
        if let keyboard = notification.userInfo?[Keyboard.NotificationInfo] as? Keyboard {
            var animationBlock: (() -> Void)?
            if keyboard.isPresenting {
                if let distance = Keyboard.howMuchShouldThisViewMove(self.currentTextElement as? UIView, withSender: self) {
                    animationBlock = self.createAnimationBlock(true, distance: CGFloat(distance))
                }
//                else {
//                    animationBlock = self.createAnimationBlock(true, distance: keyboard.finalTransitionRect.height)
//                }
            } else {
                animationBlock = self.createAnimationBlock(false, distance: nil)
            }
            if animationBlock == nil {
                return
            }
            UIView.animateWithDuration(keyboard.transitionDuration.doubleValue as NSTimeInterval,
                delay: 0.0,
                options: keyboard.transitionAnimationOptions,
                animations: animationBlock!,
                completion:
            { [unowned self] (finished: Bool) -> Void in
                if finished && !keyboard.forRotation && !keyboard.isPresenting {
                    self.currentTextElement?.resignFirstResponder()
                    self.currentTextElement = nil
                }
            })
        }
    }
    
    //MARK: Aux
    private func createAnimationBlock(isPresenting: Bool, distance: CGFloat?) -> () -> Void
    {
        var result: () -> Void
        let constants = self.originalConstants!
        if let constraints = self.constraintsForKeyboard {
            if isPresenting {
                let fromBottom = movesStuffForKeyboardFromBottom
                constraints.forEach { (constraint: NSLayoutConstraint) -> () in
                    constants.forEach { (constant: CGFloat) -> () in
                        constraint.constant = fromBottom ? CGFloat(distance!) + constant : CGFloat(distance!) - constant
                    }
                }
            } else {
                constraints.forEach { (constraint: NSLayoutConstraint) -> () in
                    constants.forEach { (constant: CGFloat) -> () in
                        constraint.constant = constant
                    }
                }
            }
            result = { [unowned self] ()->Void in
                self.view.layoutIfNeeded()
            }
        } else if let views = self.viewsToMoveForKeyboard {
            if isPresenting {
                let fromBottom = movesStuffForKeyboardFromBottom
                result = { ()->Void in
                    views.forEach { (view: UIView) -> () in
                        constants.forEach { (constant: CGFloat) -> () in
                            view.frame = CGRectMake(view.frame.origin.x, fromBottom ? constant - CGFloat(distance!) : constant + CGFloat(distance!), view.frame.size.width, view.frame.size.height)
                        }
                    }
                }
            } else {
                result = { ()->Void in
                    views.forEach { (view: UIView) -> () in
                        constants.forEach { (constant: CGFloat) -> () in
                            view.frame = CGRectMake(view.frame.origin.x, constant, view.frame.size.width, view.frame.size.height)
                        }
                    }
                }
            }
        } else {
            //We will never hit this part, but we still need to make Swift happy
            return { ()->Void in }
        }
        return result
    }
}
