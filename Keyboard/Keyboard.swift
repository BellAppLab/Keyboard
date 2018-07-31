import UIKit


//MARK: - MAIN
/// Encapsulates information about the keyboard.
public final class Keyboard: KeyboardChangeHandler, CustomStringConvertible
{
    //MARK: - Singleton
    /// The shared instance of `Keyboard` that keeps track of the keyboard state.
    @nonobjc
    public static let `default` = Keyboard()

    //MARK: - Public Properties
    /// Returns `true` if the keyboard is currently visible.
    @nonobjc
    public fileprivate(set) var isVisible: Bool = false
    /// Returns the keyboard's frame if it is currently visible, or `CGRect.zero` if it is not.
    @nonobjc
    public fileprivate(set) var currentFrame = CGRect.zero

    //MARK: - Setup
    deinit {
        resignKeyboardChangeHandler()
    }

    @nonobjc
    private init() {
        becomeKeyboardChangeHandler()
    }

    /// Dummy call to wake up the Keybaord singleton.
    @discardableResult
    @nonobjc
    internal static func yo() -> Keyboard {
        return Keyboard.default
    }

    //MARK: - Hashable
    @nonobjc
    public var hashValue: Int = {
        return Int.min
    }()
}


//MARK: - KEYBOARD CHANGE HANDLER
@nonobjc
public extension Keyboard
{
    public func handleKeyboardChange(_ change: Keyboard.Change) {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        let convertedFrame = keyWindow.convert(change.finalTransitionRect, to: nil)
        let intersection = convertedFrame.intersection(keyWindow.frame)
        isVisible = !(intersection.isNull == true || intersection.height == 0.0)
        if isVisible {
            currentFrame = convertedFrame
        } else {
            currentFrame = .zero
        }
    }
}

//MARK: - EQUATABLE & CUSTOM STRING CONVERTIBLE
@nonobjc
public extension Keyboard
{
    public static func ==(lhs: Keyboard, rhs: Keyboard) -> Bool {
        guard lhs.isVisible == rhs.isVisible else { return false }
        guard lhs.currentFrame == rhs.currentFrame else { return false }
        return true
    }

    public var description: String {
        return "Keyboard: {\n\tvisible: \(isVisible)\n\tcurrent frame: \(currentFrame)"
    }
}
