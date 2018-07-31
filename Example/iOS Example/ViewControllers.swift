import UIKit
import Keyboard


class AutolayoutViewController: UIViewController, KeyboardChangeHandler
{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        becomeKeyboardChangeHandler()
    }

    override func viewWillDisappear(_ animated: Bool) {
        resignKeyboardChangeHandler()

        super.viewWillDisappear(animated)
    }
}


extension AutolayoutViewController
{
    @IBAction func dismissTapped(_ sender: UITapGestureRecognizer) {
        view.currentFirstResponder?.resignFirstResponder()
    }
}


class FrameViewController: UIViewController, KeyboardChangeHandler
{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        becomeKeyboardChangeHandler()
    }

    override func viewWillDisappear(_ animated: Bool) {
        resignKeyboardChangeHandler()

        super.viewWillDisappear(animated)
    }
}


extension FrameViewController
{
    @IBAction func dismissTapped(_ sender: UITapGestureRecognizer) {
        view.currentFirstResponder?.resignFirstResponder()
    }
}


class MultipleViewController: UIViewController, KeyboardChangeHandler, UITextFieldDelegate
{
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        becomeKeyboardChangeHandler()
    }

    override func viewWillDisappear(_ animated: Bool) {
        resignKeyboardChangeHandler()

        super.viewWillDisappear(animated)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstTextField {
            secondTextField.becomeFirstResponder()
        }
        return true
    }
}


extension MultipleViewController
{
    @IBAction func dismissTapped(_ sender: UITapGestureRecognizer) {
        view.currentFirstResponder?.resignFirstResponder()
    }
}

