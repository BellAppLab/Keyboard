import UIKit


//MARK: - MAIN
@nonobjc
public extension Keyboard {
    /// Encapsulates the changes happening to the keyboard.
    public struct Change: Equatable, CustomStringConvertible {
        //MARK: - Public Properties
        /// The keyboard's initial frame when a change began.
        public let initialTransitionRect: CGRect
        /// The keyboard's final frame when a change began.
        public let finalTransitionRect: CGRect
        /// The keyboard's transition duration.
        public let transitionDuration: Double
        /// The keyboard's transition animation options.
        public let transitionAnimationOptions: UIViewAnimationOptions

        //MARK: - Setup
        private init(initialTransitionRect: CGRect,
                     finalTransitionRect: CGRect,
                     transitionDuration: Double,
                     transitionAnimationOptions: UIViewAnimationOptions)
        {
            self.initialTransitionRect = initialTransitionRect
            self.finalTransitionRect = finalTransitionRect
            self.transitionDuration = transitionDuration
            self.transitionAnimationOptions = transitionAnimationOptions
        }

        fileprivate init?(userInfo: [AnyHashable: Any])
        {
            guard let initialRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
                let finalRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
                let options = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
            else { return nil }
            let animationOptions = UIViewAnimationOptions(rawValue: options).union(.beginFromCurrentState)
            self.init(initialTransitionRect: initialRect,
                      finalTransitionRect: finalRect,
                      transitionDuration: duration,
                      transitionAnimationOptions: animationOptions)
        }
    }
}


//MARK: - CALCULATING FRAMES
public extension Keyboard.Change
{
    /// Calculates the intersaction between a view's frame and the keyboard's final transition rect.
    /// - parameters:
    ///     - view:         the view whose `frame` is to be intersected with the keyboard's frame.
    ///     - margin:       the margin to be added to the view's frame `height`.
    ///     - superview:    the root view of which `view` is a descendant.
    /// - returns: A `CGRect` encapsulating the intersaction between the view's frame and the keyboard's final transition rect, or `CGRect.zero` if they don't intersect.
    public func intersectionOfFinalRect(with view: UIView?,
                                        andMargin margin: CGFloat,
                                        in superview: UIView) -> CGRect
    {
        guard let view = view else { return .zero }

        let convertedKeyboardRect = superview.convert(finalTransitionRect,
                                                      to: nil)

        let convertedViewRect: CGRect
        if view.superview == superview {
            convertedViewRect = view.frame
        } else {
            convertedViewRect = view.convert(view.frame,
                                             to: superview)
        }

        let result = convertedKeyboardRect.intersection(convertedViewRect)

        if result.height > 0.0 {
            return CGRect(x: result.origin.x,
                          y: result.origin.y,
                          width: result.width,
                          height: result.height + margin)
        }
        return result
    }
}


//MARK: - EQUATABLE & CUSTOM STRING CONVERTIBLE
public extension Keyboard.Change
{
    public static func ==(lhs: Keyboard.Change, rhs: Keyboard.Change) -> Bool {
        guard lhs.initialTransitionRect == rhs.initialTransitionRect else { return false }
        guard lhs.finalTransitionRect == rhs.finalTransitionRect else { return false }
        guard lhs.transitionDuration == rhs.transitionDuration else { return false }
        guard lhs.transitionAnimationOptions == rhs.transitionAnimationOptions else { return false }
        return true
    }

    public var description: String {
        return "Keyboard Change: {\n\tinitial transition rect: \(initialTransitionRect)\n\tfinal transition rect: \(finalTransitionRect)\n\ttransition duration: \(transitionDuration)\n\ttransition animation options: \(transitionAnimationOptions)"
    }
}


//MARK: - KEYBOARD CHANGE HANDLER
/// Handles changes in the keyboard.
public protocol KeyboardChangeHandler: AnyObject, Hashable {
    /// Handles changes in the keyboard.
    /// - parameters:
    ///     - change:   A `Keyboard.Change` structure encapsulating the changes happening to the keyboard.
    func handleKeyboardChange(_ change: Keyboard.Change)
}


public extension KeyboardChangeHandler
{
    /// Makes the receiver start handling keyboard notifications.
    public func becomeKeyboardChangeHandler() {
        NotificationCenter.default.registerKeyboardNotificationHandler(self)
    }

    /// Makes the receiver stop handling keyboard notifications.
    public func resignKeyboardChangeHandler() {
        NotificationCenter.default.unregisterKeyboardNotificationHandler(self)
    }
}


//MARK: - Notification Center + Keyboard Change Handler
@nonobjc
fileprivate extension NotificationCenter
{
    static var tokens: [Int: [NSObjectProtocol]] = [:]

    func registerKeyboardNotificationHandler<H: KeyboardChangeHandler>(_ handler: H) {
        let tokens = Notification.allKeyboardNotifications.map { (notificationName) -> NSObjectProtocol in
            return addObserver(forName: notificationName,
                               object: nil,
                               queue: OperationQueue.main)
            { [weak handler] (notification) in
                guard let change = notification.keyboardChange else { return }
                handler?.handleKeyboardChange(change)
            }
        }
        NotificationCenter.tokens[handler.hashValue] = tokens
    }

    func unregisterKeyboardNotificationHandler<H: KeyboardChangeHandler>(_ handler: H) {
        guard let token = NotificationCenter.tokens[handler.hashValue] else { return }
        removeObserver(token)
    }
}


//MARK: - Notification + Keyboard Change Handler
fileprivate extension Notification
{
    static var allKeyboardNotifications = [
        Notification.Name.UIKeyboardWillChangeFrame
    ]

    var keyboardChange: Keyboard.Change? {
        guard Notification.allKeyboardNotifications.contains(name) else { return nil }
        guard let userInfo = userInfo else { return nil }
        return Keyboard.Change(userInfo: userInfo)
    }
}
