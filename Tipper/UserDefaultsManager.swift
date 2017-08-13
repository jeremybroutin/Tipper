//
//  UserDefaultsManager.swift
//  Tipper
//
//  Created by Jeremy Broutin on 8/13/17.
//  Copyright © 2017 Jeremy Broutin. All rights reserved.
//

import Foundation

class UserDefaultsManager: NSObject {

  static let shared = UserDefaultsManager()
  private override init() {}

  private let userDefaults = UserDefaults.standard
  private let defaultTipKey = "tipperDefaultTip"
  private let timeInBackgroundKey = "timeInBackground"

  func saveDefaultTip(_ value: TipOptions) {
    userDefaults.set(value.rawValue, forKey: defaultTipKey)
  }

  func loadDefaultTip() -> TipOptions? {
    return matchDoubleToTipOption(userDefaults.double(forKey: defaultTipKey))
  }

  func matchDoubleToTipOption(_ double: Double) -> TipOptions? {
    switch double {
    case TipOptions.Low.rawValue: return .Low
    case TipOptions.Middle.rawValue: return .Middle
    case TipOptions.High.rawValue: return .High
    default: return nil
    }
  }

  func matchTipOptionToIndex(_ tipOption: TipOptions) -> Int {
    switch tipOption {
    case .Low: return 0
    case .Middle: return 1
    case .High: return 2
    }
  }

  func saveBackgroundDate(date: Date) {
    userDefaults.set(date, forKey: timeInBackgroundKey)
  }

  func getBackgroundDate() -> Date? {
    if let date = userDefaults.object(forKey: timeInBackgroundKey) as? Date {
      return date
    }
    return nil
  }

}
