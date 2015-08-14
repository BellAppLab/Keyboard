import UIKit

public class Keyboard: Printable, DebugPrintable
{
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
        self.init(finalTransitionRect: CGRectZero, transitionDuration: 0, transitionAnimationOptions: UIViewAnimationOptions.allZeros, isPresenting: false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleRotationNotification:", name: UIApplicationWillChangeStatusBarFrameNotification, object: UIApplication.sharedApplication())
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification)
    {
        var visible = notification.name == UIKeyboardDidShowNotification
        var wereRotating = areWeRotating
        
        //Workaround to deal with the nasty iOS 8's behaviour of sending 4 keyboard notifications when rotating
        if areWeRotating {
            if !visible {
                return
            } else {
                rotationCount--
            }
        }
        if areWeRotating {
            return
        }
        
        let userInfo = notification.userInfo!
        var duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        if wereRotating && duration.integerValue == 0 {
            duration = NSNumber(double: 0.25)
        }
        let animationOptions = UIViewAnimationOptions(rawValue: (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedLongValue) | .BeginFromCurrentState
        self.isKeyboardVisible = visible
        self.currentKeyboardFrame = self.isKeyboardVisible ? UIApplication.sharedApplication().keyWindow!.convertRect((userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue(), fromWindow: nil) : CGRectZero
        let keyboardInfo = Keyboard(finalTransitionRect: self.currentKeyboardFrame, transitionDuration: duration, transitionAnimationOptions: animationOptions, isPresenting: self.isKeyboardVisible)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(KeyboardDidChangeNotification, object: nil, userInfo: [KeyboardNotificationInfo: keyboardInfo])
        })
    }
    
    @objc func handleRotationNotification(notification: NSNotification)
    {
        if notification.name == UIApplicationWillChangeStatusBarFrameNotification {
            //Workaround to deal with the nasty iOS 8's behaviour of sending 4 keyboard notifications when rotating
            rotationCount = 2
        }
    }
    
    private init(finalTransitionRect: CGRect, transitionDuration: NSNumber, transitionAnimationOptions: UIViewAnimationOptions, isPresenting: Bool)
    {
        self.finalTransitionRect = finalTransitionRect
        self.transitionDuration = transitionDuration
        self.transitionAnimationOptions = transitionAnimationOptions
        self.isPresenting = isPresenting
    }
    
    //MARK: Public
    //Keyboard info posted as a notification
    public let finalTransitionRect: CGRect
    public let transitionDuration: NSNumber
    public let transitionAnimationOptions: UIViewAnimationOptions
    public let isPresenting: Bool
    
    //The keyboard's visibility status
    public static var visible: Bool {
        return privateKeyboard.isKeyboardVisible
    }
    
    //Checking if the keyboard is being laid out over an element
    public static func howMuchShouldThisViewMove(view: UIView?, withSender sender: UIViewController) -> Double?
    {
        if var finalView = view {
            let viewRect = sender.view.convertRect(finalView.frame, fromView: nil)
            let viewsBottom = viewRect.origin.y + viewRect.size.height
            let keyboardsTop = sender.view.bounds.size.height - privateKeyboard.currentKeyboardFrame.size.height
            if viewsBottom > keyboardsTop {
                return Double(viewsBottom - keyboardsTop + 40)
            }
        }
        return nil
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
private let privateKeyboard = Keyboard()
public let KeyboardDidChangeNotification = "com.bellapplab.KeyboardDidChangeNotification"
public let KeyboardNotificationInfo = "KeyboardNotificationInfo"
