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

  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup UI.
    customizeUIElements(with:.Dark)

    // Subscribe to keyboard display notifications.
    NotificationCenter.default.addObserver(self, selector: #selector(TipViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(TipViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }

  func createButton(WithText text: String) -> UIButton {
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    // Framing
    button.setTitle("SETTINGS", for: .normal)
    button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 10)
    button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
    button.sizeToFit()
    // Customizing
    button.setTitleColor(UIColor.white, for: .normal)
    button.backgroundColor = darkThemeMainColor
    button.layer.cornerRadius = 5.0
    button.layer.shadowColor = darkThemeSecondColor.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: 2)
    button.layer.shadowRadius = 0.0
    button.layer.shadowOpacity = 0.6
    // Target
    button.addTarget(self, action: #selector(TipViewController.goToSettings), for: .touchUpInside)

    return button
  }

  func goToSettings() {
    performSegue(withIdentifier: settingsSegueIdentifier, sender: self)
  }

  func customizeUIElements(with theme: ColorTheme) {
    if theme == .Dark {
      amountTextField.delegate = self
      amountTextField.textColor = darkThemeMainColor
      amountTextField.attributedPlaceholder = NSAttributedString(string: defaultAmountPlaceHolderText, attributes: [NSForegroundColorAttributeName: darkThemeSecondColor])
//      let settingsButton = createButton(WithText: "Settings")
//      let settingsBarButtonItem = UIBarButtonItem(customView: settingsButton)
//      navigationItem.rightBarButtonItems = [settingsBarButtonItem]
    }
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
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      if view.frame.origin.y != 0 {
        view.frame.origin.y = 0
        topConstraint.constant = 30
        animateLayoutChanges()
      }
    }
  }


}

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
    tipResultLabel.text = "$ \(String(tip))"
    totalResultLabel.text = "$\(amount + tip)"
    return true
  }

}

