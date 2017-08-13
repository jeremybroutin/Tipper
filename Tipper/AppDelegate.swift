//
//  AppDelegate.swift
//  Tipper
//
//  Created by Jeremy Broutin on 8/11/17.
//  Copyright © 2017 Jeremy Broutin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  let manager = UserDefaultsManager.shared
  let resetWindow: Double = 600.0

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    if let nav = window?.rootViewController as? UINavigationController {
      let vc = nav.visibleViewController as! TipViewController
      vc.view.endEditing(true)
    }
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    manager.saveBackgroundDate(date: Date())
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    let now = Date()
    if let before = manager.getBackgroundDate() {
      if now.timeIntervalSince(before) > resetWindow {
        if let nav = window?.rootViewController as? UINavigationController {
          let vc = nav.visibleViewController as! TipViewController
          if let _ = vc.amountTextField, let _ = vc.tipResultLabel, let _ = vc.totalResultLabel {
            vc.resetAll()
          }
        }
      }
    }
  }
}

