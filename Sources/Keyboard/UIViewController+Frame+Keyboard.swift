import ObjectiveC
import UIKit


//MARK: - ORIGINAL FRAMES
//MARK: - Assotiation Keys
private extension AssociationKeys {
    static var originalFrames = "com.bellapplab.originalFrames.key"
}


//MARK: - UIViewController + Original Frames
@nonobjc
internal extension UIViewController
{
    func makeOriginalFrames() {
        guard hasKeyboardViews else { return }
        if let keyboardViews = keyboardViews {
            var frames: [Int: CGRect] = [:]
            (0..<keyboardViews.count).forEach { i in
                let view = keyboardViews[i]
                view.tag = i
                frames[i] = view.frame
            }
            originalFrames = frames
        } else {
            originalFrames = nil
        }
    }

    private(set) var originalFrames: [Int: CGRect]? {
        get {
            guard handlesKeyboard,
                let nsDictionary = objc_getAssociatedObject(self, &AssociationKeys.originalFrames) as? NSDictionary
            else {
                return nil
            }

            var result = [Int: CGRect]()
            nsDictionary.forEach {
                if let key = $0.key as? Int, let frame = ($0.value as? NSValue)?.cgRectValue {
                    result[key] = frame
                }
            }
            return result
        }
        set {
            let nsDictionary: NSDictionary?
            let dictionary = newValue?.mapValues { NSValue(cgRect: $0) }
            if handlesKeyboard, dictionary != nil {
                nsDictionary = NSDictionary(dictionary: dictionary!)
            } else {
                nsDictionary = nil
            }
            objc_setAssociatedObject(self,
                                     &AssociationKeys.originalFrames,
                                     nsDictionary,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


//MARK: - KEYBOARD VIEWS
//MARK: - Assotiation Keys
private extension AssociationKeys {
    static var keyboardViews = "com.bellapplab.keyboardViews.key"
}


//MARK: - UIViewController + Keyboard Views
@nonobjc
internal extension UIViewController
{
    var hasKeyboardViews: Bool {
        return handlesKeyboard && keyboardViews?.isEmpty ?? true == false
    }

    func setKeyboardViewsToOriginal() {
        guard hasKeyboardViews else { return }
        keyboardViews?.forEach {
            let originalFrame = originalFrames![$0.tag]!
            $0.frame = originalFrame
        }
        view.setNeedsDisplay()
    }

    func setKeyboardFrames(intersection: CGRect) {
        guard hasKeyboardViews, intersection != .zero else { return }
        keyboardViews?.forEach {
            let originalFrame = originalFrames![$0.tag]!
            $0.frame = CGRect(x: originalFrame.origin.x,
                              y: originalFrame.origin.y - intersection.height,
                              width: originalFrame.width,
                              height: originalFrame.height)
        }
    }
}

@objc
public extension UIViewController
{
    /// The collection of views that should have their frames updated when the keyboard changes.
    /// - note: This should only be used if you are not using autolayout.
    @IBOutlet var keyboardViews: [UIView]? {
        get {
            if let nsArray = objc_getAssociatedObject(self, &AssociationKeys.keyboardViews) as? NSArray {
                #if swift(>=4.0)
                return nsArray.compactMap { $0 as? UIView }
                #else
                return nsArray.flatMap { $0 as? UIView }
                #endif
            }
            return nil
        }
        set {
            Keyboard.yo()
            objc_setAssociatedObject(self,
                                     &AssociationKeys.keyboardViews,
                                     newValue != nil ? NSArray(array: newValue!) : nil,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            makeOriginalFrames()
        }
    }
}
