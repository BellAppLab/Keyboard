import UIKit


//MARK: - MAIN
/// Encapsulates information about the keyboard.
public final class Keyboard: KeyboardChangeHandler, CustomStringConvertible
{
    //MARK: - Singleton
    /// The shared instance of `Keyboard` that keeps track of the keyboard state.
    public static let `default` = Keyboard()

    //MARK: - Public Properties
    /// Returns `true` if the keyboard is currently visible.
    public fileprivate(set) var isVisible: Bool = false
    /// Returns the keyboard's frame if it is currently visible, or `CGRect.zero` if it is not.
    public fileprivate(set) var currentFrame = CGRect.zero

    //MARK: - Setup
    deinit {
        resignKeyboardChangeHandler()
    }

    private init() {
        becomeKeyboardChangeHandler()
    }

    /// Dummy call to wake up the Keybaord singleton.
    @discardableResult
    internal static func yo() -> Keyboard {
        return Keyboard.default
    }

    //MARK: - Hashable
    public var hashValue: Int = Int.min

    public func hash(into hasher: inout Hasher) {
        hasher.combine(Int.min)
    }
}


//MARK: - KEYBOARD CHANGE HANDLER
@nonobjc
public extension Keyboard
{
    func handleKeyboardChange(_ change: Keyboard.Change) {
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
    static func ==(lhs: Keyboard, rhs: Keyboard) -> Bool {
        guard lhs.isVisible == rhs.isVisible else { return false }
        guard lhs.currentFrame == rhs.currentFrame else { return false }
        return true
    }

    var description: String {
        return "Keyboard: {\n\tvisible: \(isVisible)\n\tcurrent frame: \(currentFrame)"
    }
}
