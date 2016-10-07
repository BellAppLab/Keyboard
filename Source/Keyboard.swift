import UIKit


final class Keyboard: CustomStringConvertible, CustomDebugStringConvertible
{
    //MARK: Consts
    private static var privateKeyboard: Keyboard!
    public struct Consts {
        public static func domain() -> String {
            return  "com.bellapplab.Keyboard"
        }
        public static let didChangeNotification = "\(Keyboard.Consts.domain()).DidChangeNotification"
        public static let notificationInfo = "NotificationInfo"
    }
    
    //MARK: Private
    //Handling notifications and the keyboard rect
    private var isKeyboardVisible: Bool = false
    private var currentKeyboardFrame = CGRect.zero
    private var rotationCount = 0
    private var areWeRotating: Bool {
        return rotationCount > 0
    }
    
    private convenience init()
    {
        self.init(finalTransitionRect: CGRect.zero, transitionDuration: 0, transitionAnimationOptions: UIViewAnimationOptions(), isPresenting: false, forRotation: false)
        NotificationCenter.default.addObserver(self, selector: #selector(Keyboard.handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Keyboard.handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Keyboard.handleRotationNotification(_:)), name: NSNotification.Name.UIApplicationWillChangeStatusBarFrame, object: UIApplication.shared)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardNotification(_ notification: NSNotification)
    {
        let wereRotating = areWeRotating
        
        if wereRotating {
            rotationCount -= 1
        }
        
        let userInfo = notification.userInfo!
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let animationOptions = UIViewAnimationOptions(rawValue: (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue).union(.beginFromCurrentState)
        self.isKeyboardVisible = notification.name == NSNotification.Name.UIKeyboardWillShow
        self.currentKeyboardFrame = self.isKeyboardVisible ? UIApplication.shared.keyWindow!.convert((userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue, from: nil) : CGRect.zero
        let keyboardInfo = Keyboard(finalTransitionRect: self.currentKeyboardFrame, transitionDuration: duration, transitionAnimationOptions: animationOptions, isPresenting: self.isKeyboardVisible, forRotation: wereRotating)
        OperationQueue.main.addOperation { 
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Keyboard.Consts.didChangeNotification), object: nil, userInfo: [Keyboard.Consts.notificationInfo: keyboardInfo])
        }
    }
    
    @objc func handleRotationNotification(_ notification: NSNotification)
    {
        if !isKeyboardVisible {
            rotationCount = 0
            return
        }
        if notification.name == NSNotification.Name.UIApplicationWillChangeStatusBarFrame {
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
    public static var isVisible: Bool {
        return privateKeyboard.isKeyboardVisible
    }
    
    public static func hey() {
        privateKeyboard = Keyboard()
    }
    
    //Checking if the keyboard is being laid out over an element
    public static func howMuchShouldThisViewMove(_ view: UIView?, withSender sender: UIViewController) -> Double?
    {
        guard let finalView = view else { return nil }
        let viewRect = sender.view.convert(finalView.frame, from: nil)
        let viewsBottom = viewRect.origin.y + viewRect.size.height + 40
        let keyboardsTop = sender.view.bounds.size.height - privateKeyboard.currentKeyboardFrame.size.height
        guard viewsBottom > keyboardsTop else { return nil }
        return Double(viewsBottom - keyboardsTop)
    }
    
    //MARK: Printable
    public var description: String {
        return "Keyboard: {\n    visible: \(Keyboard.isVisible)\n    finalTransitionRect: \(finalTransitionRect)\n    transitionDuration: \(transitionDuration)\n     transitionAnimationOptions: \(transitionAnimationOptions)\n    isPresenting: \(isPresenting)"
    }
    
    //MARK: Debug Printable
    public var debugDescription: String {
        #if DEBUG
            return "Keyboard: {\n    visible: \(Keyboard.isVisible)\n    finalTransitionRect: \(finalTransitionRect)\n    transitionDuration: \(transitionDuration)\n     transitionAnimationOptions: \(transitionAnimationOptions)\n    isPresenting: \(isPresenting)\n    currentKeyboardFrame: \(currentKeyboardFrame)"
        #else
            return self.description
        #endif
    }
}
