import UIKit


public class Keyboard: CustomStringConvertible, CustomDebugStringConvertible
{
    //MARK: Consts
    private static let privateKeyboard = Keyboard()
    public static func domain() -> String {
        return  "com.bellapplab.Keyboard"
    }
    public static let DidChangeNotification = "\(Keyboard.domain()).DidChangeNotification"
    public static let NotificationInfo = "NotificationInfo"
    
    //MARK: Private
    //Handling notifications and the keyboard rect
    private var isKeyboardVisible: Bool = false
    private var currentKeyboardFrame = CGRectZero
    private var rotationCount = 0
    private var areWeRotating: Bool {
        return rotationCount > 0
    }
    
    private convenience init()
    {
        self.init(finalTransitionRect: CGRectZero, transitionDuration: 0, transitionAnimationOptions: UIViewAnimationOptions(), isPresenting: false, forRotation: false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Keyboard.handleKeyboardNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Keyboard.handleKeyboardNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Keyboard.handleRotationNotification(_:)), name: UIApplicationWillChangeStatusBarFrameNotification, object: UIApplication.sharedApplication())
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification)
    {
        let wereRotating = areWeRotating
        
        if wereRotating {
            rotationCount -= 1
        }
        
        let userInfo = notification.userInfo!
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let animationOptions = UIViewAnimationOptions(rawValue: (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedLongValue).union(.BeginFromCurrentState)
        self.isKeyboardVisible = notification.name == UIKeyboardWillShowNotification
        self.currentKeyboardFrame = self.isKeyboardVisible ? UIApplication.sharedApplication().keyWindow!.convertRect((userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue(), fromWindow: nil) : CGRectZero
        let keyboardInfo = Keyboard(finalTransitionRect: self.currentKeyboardFrame, transitionDuration: duration, transitionAnimationOptions: animationOptions, isPresenting: self.isKeyboardVisible, forRotation: wereRotating)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(Keyboard.DidChangeNotification, object: nil, userInfo: [Keyboard.NotificationInfo: keyboardInfo])
        })
    }
    
    @objc func handleRotationNotification(notification: NSNotification)
    {
        if !isKeyboardVisible {
            rotationCount = 0
            return
        }
        if notification.name == UIApplicationWillChangeStatusBarFrameNotification {
            rotationCount = 4
        }
    }
    
    private init(finalTransitionRect: CGRect, transitionDuration: NSNumber, transitionAnimationOptions: UIViewAnimationOptions, isPresenting: Bool, forRotation: Bool)
    {
        self.finalTransitionRect = finalTransitionRect
        self.transitionDuration = transitionDuration
        self.transitionAnimationOptions = transitionAnimationOptions
        self.isPresenting = isPresenting
        self.forRotation = forRotation
    }
    
    //MARK: Public
    //Keyboard info posted as a notification
    public let finalTransitionRect: CGRect
    public let transitionDuration: NSNumber
    public let transitionAnimationOptions: UIViewAnimationOptions
    public let isPresenting: Bool
    public let forRotation: Bool
    
    //The keyboard's visibility status
    public static var visible: Bool {
        return privateKeyboard.isKeyboardVisible
    }
    
    //Checking if the keyboard is being laid out over an element
    public static func howMuchShouldThisViewMove(view: UIView?, withSender sender: UIViewController) -> Double?
    {
        guard let finalView = view else { return nil }
        let viewRect = sender.view.convertRect(finalView.frame, fromView: nil)
        let viewsBottom = viewRect.origin.y + viewRect.size.height + 40
        let keyboardsTop = sender.view.bounds.size.height - privateKeyboard.currentKeyboardFrame.size.height
        guard viewsBottom > keyboardsTop else { return nil }
        return Double(viewsBottom - keyboardsTop)
    }
    
    //MARK: Printable
    public var description: String {
        return "Keyboard: {\n    visible: \(Keyboard.visible)\n    finalTransitionRect: \(finalTransitionRect)\n    transitionDuration: \(transitionDuration)\n     transitionAnimationOptions: \(transitionAnimationOptions)\n    isPresenting: \(isPresenting)"
    }
    
    //MARK: Debug Printable
    public var debugDescription: String {
        #if DEBUG
            return "Keyboard: {\n    visible: \(Keyboard.visible)\n    finalTransitionRect: \(finalTransitionRect)\n    transitionDuration: \(transitionDuration)\n     transitionAnimationOptions: \(transitionAnimationOptions)\n    isPresenting: \(isPresenting)\n    currentKeyboardFrame: \(currentKeyboardFrame)"
        #else
            return self.description
        #endif
    }
}
