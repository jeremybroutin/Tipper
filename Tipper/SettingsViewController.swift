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

  let tipsOption = ["15%", "18%", "20%"]
  let themeOptions: [ColorTheme] = [.Dark, .Light]
  var lastSelectedTipIndexPath: IndexPath!
  var lastSelectedThemeIndexPath: IndexPath!

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Settings"
    navigationController?.view.backgroundColor = UIColor.black
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = UIColor.black
  }

}

extension SettingsViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return tipsOption.count
    } else if section == 1 {
      return themeOptions.count
    } else {
      return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
    cell.backgroundColor = UIColor.black
    cell.textLabel?.textColor = UIColor.darkThemeSecondColor
    cell.tintColor = UIColor.darkThemeMainColor
    cell.selectionStyle = .none
    if indexPath.section == 0 {
      cell.textLabel?.text = tipsOption[indexPath.row]
    } else if indexPath.section == 1 {
      let themeOption = themeOptions[indexPath.row]
      switch themeOption {
      case .Dark:
        cell.textLabel?.text = "Dark"
      case .Light:
        cell.textLabel?.text = "Light"
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
      headerTitle.textLabel?.textColor = UIColor.darkThemeMainColor
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      if lastSelectedTipIndexPath != nil {
        let lastCell = tableView.cellForRow(at: lastSelectedTipIndexPath)
        lastCell?.accessoryType = .none
      }
      tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
      lastSelectedTipIndexPath = indexPath
    } else if indexPath.section == 1 {
      if lastSelectedThemeIndexPath != nil {
        let lastCell = tableView.cellForRow(at: lastSelectedThemeIndexPath)
        lastCell?.accessoryType = .none
      }
      tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
      lastSelectedThemeIndexPath = indexPath
    }

  }

//  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//    tableView.cellForRow(at: indexPath)?.accessoryType = .none
//  }
}
