import Keyboard

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

extension UIViewController: ActiveTextElementHandler
{
    @IBOutlet weak public var currentTextElement: UIResponder? {
        get {
            if var result = objc_getAssociatedObject(self, "currentTextElement") as? UIResponder {
                return result
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, "currentTextElement", newValue, UInt(OBJC_ASSOCIATION_ASSIGN) as objc_AssociationPolicy)
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

public var KeyboardInconsistencyCurrentViewControllerUserInfoKey: String {
    return "KeyboardInconsistencyCurrentViewControllerUserInfoKey"
}

extension UIViewController: AutoLayoutKeyboardHandler, FrameBasedKeyboardHandler
{
    @IBInspectable public var handlesKeyboard: Bool {
        get {
            if var result = objc_getAssociatedObject(self, "handlesKeyboard") as? Bool {
                return result
            }
            return false
        }
        set {
            if self.bottomConstraintForKeyboard == nil && self.viewToMoveForKeyboard == nil
            { // Validating the View Controller's setup
                NSException(name: NSInternalInconsistencyException, reason: "To correctly handle the keyboard, View Controllers must either set 'bottomConstraintForKeyboard' or 'viewToMoveForKeyboard'.", userInfo: [KeyboardInconsistencyCurrentViewControllerUserInfoKey: self]).raise()
                return
            }
            
            objc_setAssociatedObject(self, "handlesKeyboard", newValue, UInt(OBJC_ASSOCIATION_RETAIN) as objc_AssociationPolicy)
            //Dummy call to initialize the Keyboard singleton
            Keyboard.visible
            if newValue != self.handlesKeyboard {
                if newValue {
                    if self.originalConstant == nil {
                        self.originalConstant = self.bottomConstraintForKeyboard != nil ? self.bottomConstraintForKeyboard!.constant : self.viewToMoveForKeyboard!.frame.origin.y
                    }
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardDidChangeNotification:", name: KeyboardDidChangeNotification, object: nil)
                } else {
                    self.originalConstant = nil
                    NSNotificationCenter.defaultCenter().removeObserver(self, name: KeyboardDidChangeNotification, object: nil)
                }
            }
        }
    }
    
    @IBOutlet public weak var bottomConstraintForKeyboard: NSLayoutConstraint? {
        get {
            if var result = objc_getAssociatedObject(self, "bottomConstraintForKeyboard") as? NSLayoutConstraint {
                return result
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, "bottomConstraintForKeyboard", newValue, UInt(OBJC_ASSOCIATION_ASSIGN) as objc_AssociationPolicy)
        }
    }
    
    @IBOutlet public weak var viewToMoveForKeyboard: UIView? {
        get {
            if var result = objc_getAssociatedObject(self, "viewToMoveForKeyboard") as? UIView {
                return result
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, "viewToMoveForKeyboard", newValue, UInt(OBJC_ASSOCIATION_ASSIGN) as objc_AssociationPolicy)
        }
    }
    
    private var originalConstant: CGFloat? {
        get {
            if var result = objc_getAssociatedObject(self, "originalConstant") as? CGFloat {
                return result
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, "originalConstant", newValue, UInt(OBJC_ASSOCIATION_RETAIN) as objc_AssociationPolicy)
        }
    }
    
    @objc public func handleKeyboardDidChangeNotification(notification: NSNotification)
    {
        if var keyboard = notification.userInfo?[KeyboardNotificationInfo] as? Keyboard {
            var animationBlock: (() -> Void)?
            if keyboard.isPresenting {
                if var distance = Keyboard.howMuchShouldThisViewMove(self.currentTextElement! as? UIView, withSender: self) {
                    animationBlock = self.createAnimationBlock(true, distance: CGFloat(distance))
                }
            } else {
                animationBlock = self.createAnimationBlock(false, distance: nil)
            }
            UIView.animateWithDuration(keyboard.transitionDuration.doubleValue as NSTimeInterval,
                delay: 0.0,
                options: keyboard.transitionAnimationOptions,
                animations: animationBlock!,
                completion: nil)
        }
    }
    
    //MARK: Aux
    private func createAnimationBlock(isPresenting: Bool, distance: CGFloat?) -> () -> Void
    {
        var result: () -> Void
        let constant = self.originalConstant!
        if var constraint = self.bottomConstraintForKeyboard {
            if isPresenting {
                result = { ()->Void in
                    constraint.constant = CGFloat(distance!) + constant
                }
            } else {
                result = { ()->Void in
                    constraint.constant = constant
                }
            }
        } else if var view = self.viewToMoveForKeyboard {
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
