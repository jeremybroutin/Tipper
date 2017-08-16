//
//  ViewController.swift
//  Tipper
//
//  Created by Jeremy Broutin on 8/11/17.
//  Copyright © 2017 Jeremy Broutin. All rights reserved.
//

import UIKit

enum ColorTheme: String {
  case Light = "Light"
  case Dark = "Dark"
}

enum TipOptions: Double {
  case Low = 0.15
  case Middle = 0.18
  case High = 0.20
}

extension UIColor {
  static let darkThemeSecondColor = UIColor(red:0.82, green:0.92, blue:0.86, alpha:1.0)
  static let darkThemeMainColor = UIColor(red:0.55, green:0.93, blue:0.72, alpha:1.0)
}

class TipViewController: UIViewController {

  @IBOutlet weak var topConstraint: NSLayoutConstraint!
  @IBOutlet weak var amountTextField: UITextField!
  @IBOutlet weak var tipSegmentedControl: UISegmentedControl!
  @IBOutlet weak var tipStaticLabel: UILabel!
  @IBOutlet weak var tipResultLabel: UILabel!
  @IBOutlet weak var totalStaticLabel: UILabel!
  @IBOutlet weak var totalResultLabel: UILabel!


  // Constants.
  let defaultAmountPlaceHolderText = "Enter bill amount..."
  let tipOptions: [Double] = [TipOptions.Low.rawValue, TipOptions.Middle.rawValue, TipOptions.High.rawValue]
  let maxAmountCharactersLength = 7
  let defaultCurrencyCharacter = "$"
  let manager = UserDefaultsManager.shared
  let settingsSegueIdentifier = "GoToSettings"

  // Variables.
  var defaultTipOption: TipOptions!
  var selectedTip: Double!
  var formatter: NumberFormatter!

  // MARK: - View life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    // View title.
    navigationItem.title = "Tipper"
    // Setup UI.
    customizeUIElements(with:.Dark)
    // Defaults.
    defaultTipOption = manager.loadDefaultTip()
    // Subscribe to keyboard display notifications.
    NotificationCenter.default.addObserver(self, selector: #selector(TipViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(TipViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    // Initialize formatter once.
    formatter = NumberFormatter()
    formatter.numberStyle = .currency

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
      amountTextField.textColor = UIColor.darkThemeSecondColor
      amountTextField.attributedPlaceholder = NSAttributedString(string: defaultAmountPlaceHolderText, attributes: [
        NSForegroundColorAttributeName: UIColor.darkThemeSecondColor,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 45)!
        ])
    }
  }

  func resetAll() {
    amountTextField.text = ""
    textFieldEditingDidChange(amountTextField)
    shouldDisplayTipResultLabels(false)
  }

  func createBarButtonItem(WithText text: String) -> UIBarButtonItem {
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    button.setTitle(text, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
    button.sizeToFit()
    button.setTitleColor(UIColor.black, for: .normal)
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

    if manager.loadDefaultTip() != nil {
      defaultTipOption = manager.loadDefaultTip()
      control.selectedSegmentIndex = manager.matchTipOptionToIndex(defaultTipOption)
    } else {
      control.selectedSegmentIndex = 0
    }
    selectedTip = tipOptions[control.selectedSegmentIndex]
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
    tipResultLabel.text = "\(defaultCurrencyCharacter)\(String(tip))"
    totalResultLabel.text = "\(defaultCurrencyCharacter)\(String(total))"
    completion?(true)
  }

  // MARK: - IBActions

  @IBAction func tappedTipOptions(_ sender: UISegmentedControl) {
    selectedTip = tipOptions[sender.selectedSegmentIndex]
    calculateTipAndTotal(fromAmount: amountTextField.text!, completion: nil)
  }

  @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
    if sender.text!.isEmpty {
      tipResultLabel.text = "\(defaultCurrencyCharacter)0.00"
      totalResultLabel.text = "\(defaultCurrencyCharacter)0.00"
    } else {

      // Reformat the user entry.
      if let amountString = sender.text?.currencyInputFormatting() {
        sender.text = amountString
        // Start calculating tip.
        let amountNumber = formatter.number(from: sender.text!)
        calculateTipAndTotal(fromAmount: String(describing: amountNumber!), completion:  nil)
      }

    }
  }

  func goToSettings() {
    view.endEditing(true)
    performSegue(withIdentifier: settingsSegueIdentifier, sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let vc = segue.destination as! SettingsViewController
    vc.delegate = self
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
}

// MARK: - Protocol for custom delegation.

protocol Updatable {
  func updateDefaults()
}

extension TipViewController: Updatable {

  func updateDefaults() {
    if let defaultTip = manager.loadDefaultTip() {
      tipSegmentedControl.selectedSegmentIndex = manager.matchTipOptionToIndex(defaultTip)
      calculateTipAndTotal(fromAmount: amountTextField.text!, completion: nil)
    }
    if let defaultTheme = manager.getPreferredTheme() {
      switch defaultTheme {
      case .Light: view.backgroundColor = UIColor.white
      case .Dark: view.backgroundColor = UIColor.black
      }
    }
  }
}

extension String {

  // Formatting text for currency textField.
  func currencyInputFormatting() -> String {

    var number: NSNumber!
    let formatter = NumberFormatter()
    formatter.numberStyle = .currencyAccounting
    formatter.currencySymbol = "$"
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2

    var amountWithPrefix = self

    // Remove from String: "$", ".", ","
    let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
    amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix,
                                                      options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                                      range: NSMakeRange(0, self.characters.count),
                                                      withTemplate: "")

    let double = (amountWithPrefix as NSString).doubleValue
    number = NSNumber(value: (double / 100))

    // If first number is 0 or all numbers were deleted.
    guard number != 0 as NSNumber else {
      return ""
    }

    return formatter.string(from: number)!
  }
}

