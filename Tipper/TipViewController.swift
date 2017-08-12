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
  @IBOutlet weak var tipStaticLabel: UILabel!
  @IBOutlet weak var tipResultLabel: UILabel!
  @IBOutlet weak var totalStaticLabel: UILabel!
  @IBOutlet weak var totalResultLabel: UILabel!

  let darkThemeSecondColor = UIColor(red:0.82, green:0.92, blue:0.86, alpha:1.0)
  let darkThemeMainColor = UIColor(red:0.55, green:0.93, blue:0.72, alpha:1.0)
  let defaultAmountPlaceHolderText = "Enter bill amount..."
  let tipOptions = [0.15, 0.18, 0.25]
  var selectedTip: Double!
  let maxAmountCharactersLength = 7

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
    // Default
    let settingsBarButtonItem = createBarButtonItem(WithText: "Settings")
    navigationItem.rightBarButtonItems = [settingsBarButtonItem]
    setTipOptions(forSegmentedControl: tipSegmentedControl)
    shouldDisplayTipResultLabels(false)
    addDoneButtonOnKeyboard()

    // Theme specifics.
    if theme == .Dark {
      amountTextField.delegate = self
      amountTextField.textColor = darkThemeMainColor
      amountTextField.attributedPlaceholder = NSAttributedString(string: defaultAmountPlaceHolderText, attributes: [
        NSForegroundColorAttributeName: darkThemeSecondColor,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 45)!
        ])
    }
  }

  func createBarButtonItem(WithText text: String) -> UIBarButtonItem {
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    button.setTitle(text, for: .normal)
    button.sizeToFit()
    button.setTitleColor(darkThemeMainColor, for: .normal)
    button.addTarget(self, action: #selector(TipViewController.goToSettings), for: .touchUpInside)
    let barButtonItem = UIBarButtonItem(customView: button)
    return barButtonItem
  }

  func setTipOptions(forSegmentedControl control: UISegmentedControl) {
    if control.numberOfSegments != 3 {
      print("Incorrect number of segments for tip options.")
      return
    }
    for i in 0...2 {
      control.setTitle("\(tipOptions[i]*100)%", forSegmentAt: i)
    }
    control.selectedSegmentIndex = 0
    selectedTip = tipOptions[control.selectedSegmentIndex]
  }

  func goToSettings() {
    performSegue(withIdentifier: settingsSegueIdentifier, sender: self)
  }

  func animateLayoutChanges() {
    UIView.animate(withDuration: 0.5, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }

  func shouldDisplayTipResultLabels(_ value:Bool) {
    tipStaticLabel.isHidden = !value
    tipResultLabel.isHidden = !value
    totalStaticLabel.isHidden = !value
    totalResultLabel.isHidden = !value
  }

  func addDoneButtonOnKeyboard() {
    let doneToolBar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
    doneToolBar.barStyle = UIBarStyle.blackTranslucent
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(TipViewController.doneButtonAction))
    var items = [UIBarButtonItem]()
    items.append(flexSpace)
    items.append(done)
    doneToolBar.items = items
    doneToolBar.sizeToFit()
    self.amountTextField.inputAccessoryView = doneToolBar
  }

  func doneButtonAction() {
    self.amountTextField.resignFirstResponder()
  }

  // MARK: - Tip calculation.

  func calculateTipAndTotal(fromAmount amount: String, completion: ((Bool) -> Void)?) {
    guard let amount = Double(amount), let tipPercent = selectedTip else {
      completion?(false)
      return
    }
    let tip = amount * tipPercent
    let total = amount + tip
    tipResultLabel.text = "$\(String(tip))"
    totalResultLabel.text = "$\(String(total))"
    completion?(true)
  }

  // MARK: - IBActions

  @IBAction func tappedTipOptions(_ sender: UISegmentedControl) {
    selectedTip = tipOptions[sender.selectedSegmentIndex]
    calculateTipAndTotal(fromAmount: amountTextField.text!, completion: nil)
  }

  @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
    if sender.text!.isEmpty {
      tipResultLabel.text = "$0.00"
      totalResultLabel.text = "$0.00"
    } else {
      calculateTipAndTotal(fromAmount: sender.text!, completion:  nil)
    }
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

  func textFieldDidBeginEditing(_ textField: UITextField) {
    shouldDisplayTipResultLabels(true)
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField.text!.isEmpty {
      shouldDisplayTipResultLabels(false)
    }
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    // Do not allow multiple dots.
    if string == "." {
      for c in text.characters {
        if c == "." { return false }
      }
      return true
    }
    // Limit max characters
    let length = text.characters.count + string.utf16.count - range.length
    return length <= maxAmountCharactersLength
  }
}

