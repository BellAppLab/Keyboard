import ObjectiveC


//MARK: - Basic Keyboard Handling
@objc public protocol KeyboardHandler
{
    var handlesKeyboard: Bool { get set }
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
    weak var bottomConstraintForKeyboard: NSLayoutConstraint? { get set }
}

@objc public protocol FrameBasedKeyboardHandler: KeyboardHandler
{
    weak var viewToMoveForKeyboard: UIView? { get set }
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
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardDidChangeNotification:", name: KeyboardDidChangeNotification, object: nil)
            } else {
                self.originalConstant = nil
                NSNotificationCenter.defaultCenter().removeObserver(self, name: KeyboardDidChangeNotification, object: nil)
            }
        }
    }
    
    @IBOutlet public weak var bottomConstraintForKeyboard: NSLayoutConstraint? {
        get {
            if let result = objc_getAssociatedObject(self, &AssociationKeys.BottomConstraintForKeyboardKey) as? NSLayoutConstraint {
                return result
            }
            return nil
        }
        set {
            if newValue != nil {
                if self.originalConstant == nil {
                    self.originalConstant = newValue!.constant
                }
            } else {
                self.originalConstant = nil
            }
            objc_setAssociatedObject(self, &AssociationKeys.BottomConstraintForKeyboardKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @IBOutlet public weak var viewToMoveForKeyboard: UIView? {
        get {
            if let result = objc_getAssociatedObject(self, &AssociationKeys.ViewToMoveForKeyboardKey) as? UIView {
                return result
            }
            return nil
        }
        set {
            if newValue != nil {
                if self.originalConstant == nil {
                    self.originalConstant = newValue!.frame.origin.y
                }
            } else {
                self.originalConstant = nil
            }
            objc_setAssociatedObject(self, &AssociationKeys.ViewToMoveForKeyboardKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    private var originalConstant: CGFloat? {
        get {
            if let result = objc_getAssociatedObject(self, &AssociationKeys.OriginalConstantKey) as? CGFloat {
                return result
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &AssociationKeys.OriginalConstantKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc public func handleKeyboardDidChangeNotification(notification: NSNotification)
    {
        if self.originalConstant == nil
        { // Validating the View Controller's setup
            assertionFailure("To correctly handle the keyboard, View Controllers must either set 'bottomConstraintForKeyboard' or 'viewToMoveForKeyboard' in: \(self.classForCoder)")
        }
        if let keyboard = notification.userInfo?[KeyboardNotificationInfo] as? Keyboard {
            var animationBlock: (() -> Void)?
            if keyboard.isPresenting {
                if let distance = Keyboard.howMuchShouldThisViewMove(self.currentTextElement as? UIView, withSender: self) {
                    animationBlock = self.createAnimationBlock(true, distance: CGFloat(distance))
                }
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
        let constant = self.originalConstant!
        if let constraint = self.bottomConstraintForKeyboard {
            if isPresenting {
                constraint.constant = CGFloat(distance!) + constant
            } else {
                constraint.constant = constant
            }
            result = { [unowned self] ()->Void in
                self.view.layoutIfNeeded()
            }
        } else if let view = self.viewToMoveForKeyboard {
            if isPresenting {
                result = { ()->Void in
                    view.frame = CGRectMake(view.frame.origin.x, constant - CGFloat(distance!), view.frame.size.width, view.frame.size.height)
                }
            } else {
                result = { ()->Void in
                    view.frame = CGRectMake(view.frame.origin.x, constant, view.frame.size.width, view.frame.size.height)
                }
            }
        } else {
            //We will never hit this part, but we still need to make Swift happy
            return { ()->Void in }
        }
        return result
    }
}
