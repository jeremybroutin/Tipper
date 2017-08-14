//
//  SettingsViewController.swift
//  Tipper
//
//  Created by Jeremy Broutin on 8/12/17.
//  Copyright © 2017 Jeremy Broutin. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  var delegate: Updatable!

  let tipOptions: [TipOptions] = [.Low, .Middle, .High]
  let themeOptions: [ColorTheme] = [.Dark, .Light]
  var lastSelectedTipIndexPath: IndexPath!
  var lastSelectedThemeIndexPath: IndexPath!
  var defaultTipOption: TipOptions!
  var defaultTheme: ColorTheme = .Dark
  let manager = UserDefaultsManager.shared

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Settings"
    navigationController?.view.backgroundColor = UIColor.black
    tableView.dataSource = self
    tableView.delegate = self
    loadUIColor()
  }

  func getDefaults() {
    defaultTipOption = manager.loadDefaultTip()
    if let theme = manager.getPreferredTheme() {
      defaultTheme = theme
    }
  }

  func loadUIColor() {
    getDefaults()
    switch defaultTheme {
    case .Light:
      tableView.backgroundColor = UIColor.white
    case .Dark:
      tableView.backgroundColor = UIColor.black
    }
    tableView.reloadData()
  }
}

extension SettingsViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return tipOptions.count
    } else if section == 1 {
      return themeOptions.count
    } else {
      return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
    switch defaultTheme {
    case .Light:
      cell.backgroundColor = UIColor.white
    case .Dark:
      cell
        .backgroundColor = UIColor.black
    }
    cell.textLabel?.textColor = UIColor.darkThemeSecondColor
    cell.tintColor = UIColor.darkThemeMainColor
    cell.selectionStyle = .none
    // Tip options cells.
    if indexPath.section == 0 {
      let rawTip = tipOptions[indexPath.row].rawValue
      cell.textLabel?.text = "\(rawTip*100)%"
      if rawTip == defaultTipOption?.rawValue {
        cell.accessoryType = .checkmark
        lastSelectedTipIndexPath = indexPath
      }
    }
    // Color theme options cells.
    else if indexPath.section == 1 {
      let themeOption = themeOptions[indexPath.row]
      cell.textLabel?.text = themeOption.rawValue
      if themeOption == defaultTheme {
        cell.accessoryType = .checkmark
        lastSelectedThemeIndexPath = indexPath
      }
    }
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Select default tip"
    } else if section == 1 {
      return "Select color theme"
    } else {
      return nil
    }
  }
}

extension SettingsViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    if let headerTitle = view as? UITableViewHeaderFooterView {
      switch defaultTheme {
      case .Light:
        headerTitle.textLabel?.textColor = UIColor.darkGray
        headerTitle.tintColor = UIColor.white
      case .Dark:
        headerTitle.textLabel?.textColor = UIColor.darkThemeMainColor
        headerTitle.tintColor = UIColor.clear
      }
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let currentCell = tableView.cellForRow(at: indexPath) else { return }
    if indexPath.section == 0 {
      if lastSelectedTipIndexPath != nil {
        let lastCell = tableView.cellForRow(at: lastSelectedTipIndexPath)
        lastCell?.accessoryType = .none
      }
      currentCell.accessoryType = .checkmark
      lastSelectedTipIndexPath = indexPath
      // Save as default tip.
      if let cellText = currentCell.textLabel?.text {
        let truncatedText = cellText.substring(to: cellText.index(before: cellText.endIndex))
        guard
          let doubleValue = Double(truncatedText),
          let tipOption = manager.matchDoubleToTipOption(doubleValue/100)
        else {
          return
        }
        manager.saveDefaultTip(tipOption)
      }
    }
    else if indexPath.section == 1 {
      if lastSelectedThemeIndexPath != nil {
        let lastCell = tableView.cellForRow(at: lastSelectedThemeIndexPath)
        lastCell?.accessoryType = .none
      }
      tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
      lastSelectedThemeIndexPath = indexPath
      // Save as default theme.
      if let cellText = currentCell.textLabel?.text {
        switch cellText {
        case ColorTheme.Light.rawValue: manager.savePreferredTheme(theme: .Light)
        case ColorTheme.Dark.rawValue: manager.savePreferredTheme(theme: .Dark)
        default: break
        }
      }
      loadUIColor()
    }
    // Propagate changes to TipViewController.
    delegate.updateDefaults()
  }

}
