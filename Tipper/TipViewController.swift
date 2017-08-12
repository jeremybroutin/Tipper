//
//  ViewController.swift
//  Tipper
//
//  Created by Jeremy Broutin on 8/11/17.
//  Copyright © 2017 Jeremy Broutin. All rights reserved.
//

import UIKit

enum ColorTheme {
  case Light, Dark
}

class TipViewController: UIViewController {

  @IBOutlet weak var topConstraint: NSLayoutConstraint!
  @IBOutlet weak var amountTextField: UITextField!
  @IBOutlet weak var tipSegmentedControl: UISegmentedControl!
  @IBOutlet weak var tipResultLabel: UILabel!
  @IBOutlet weak var totalResultLabel: UILabel!

  let darkThemeSecondColor = UIColor(red:0.82, green:0.92, blue:0.86, alpha:1.0)
  let darkThemeMainColor = UIColor(red:0.55, green:0.93, blue:0.72, alpha:1.0)
  let defaultAmountPlaceHolderText = "Enter amount..."

  let settingsSegueIdentifier = "GoToSettings"

  // MARK: - View life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup UI.
    customizeUIElements(with:.Dark)

    // Subscribe to keyboard display notifications.
    NotificationCenter.default.addObserver(self, selector: #selector(TipViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(TipViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }

  // MARK: - UI Setup helper methods

  func customizeUIElements(with theme: ColorTheme) {
    if theme == .Dark {
      amountTextField.delegate = self
      amountTextField.textColor = darkThemeMainColor
      amountTextField.attributedPlaceholder = NSAttributedString(string: defaultAmountPlaceHolderText, attributes: [
        NSForegroundColorAttributeName: darkThemeSecondColor,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 45)!
        ])
      let settingsBarButtonItem = createBarButtonItem(WithText: "Settings")
      navigationItem.rightBarButtonItems = [settingsBarButtonItem]
    }
  }

  func createBarButtonItem(WithText text: String) -> UIBarButtonItem {
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    // Framing
    button.setTitle(text, for: .normal)
    button.sizeToFit()
    // Customizing
    button.setTitleColor(darkThemeMainColor, for: .normal)
    button.addTarget(self, action: #selector(TipViewController.goToSettings), for: .touchUpInside)
    // Converting
    let barButtonItem = UIBarButtonItem(customView: button)
    return barButtonItem
  }

  func goToSettings() {
    performSegue(withIdentifier: settingsSegueIdentifier, sender: self)
  }

  func animateLayoutChanges() {
    UIView.animate(withDuration: 0.5, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }


  // MARK: - Keyboard display listeners

  func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if view.frame.origin.y == 0{
        view.frame.origin.y -= keyboardSize.height
        topConstraint.constant += keyboardSize.height
        animateLayoutChanges()
      }
    }
  }

  func keyboardWillHide(notification: NSNotification) {
    if view.frame.origin.y != 0 {
      view.frame.origin.y = 0
      topConstraint.constant = 30
      animateLayoutChanges()
    }
  }
}

// MARK: - Textfield delegate methods

extension TipViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

    if string == "." {
      return true // do nothing.
    }

    var amount: Double = 0.0
    if let existingText = textField.text, let stringValue = Double(string) {
      if existingText.isEmpty {
        amount = stringValue
      } else {
        let amountText: String = existingText + string
        guard let amountValue = Double(amountText) else { return true }
        amount = amountValue
      }
    }
    let tip: Double = amount * 0.15
    tipResultLabel.text = "$\(String(tip))"
    totalResultLabel.text = "$\(amount + tip)"
    return true
  }

}

