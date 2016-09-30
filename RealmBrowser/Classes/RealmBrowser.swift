//
//  RealmBrowser.swift
//  Pods
//
//  Created by Koji Murata on 2016/07/14.
//
//

import UIKit
import RealmSwift

public final class RealmBrowser {
  static var moduleName = ""
  static var objectSearchEnabled = true
  
  public static var incorrectModuleNameMessage = "Please call RealmBrowser.instantiate with correct module name."
  
  public static func instantiate(moduleName: String, withNavigationController: Bool = true, objectSearchEnabled: Bool = true) -> UIViewController {
    RealmBrowser.moduleName = moduleName
    RealmBrowser.objectSearchEnabled = objectSearchEnabled
    
    let bundle = Bundle(path: Bundle(for: RealmBrowser.self).path(forResource: "RealmBrowser", ofType: "bundle")!)!
    let viewController = UIStoryboard(name: "RealmBrowser", bundle: bundle).instantiateInitialViewController() as! RealmSchemaTableViewController
    viewController.prepare(withNavigationController)
    if withNavigationController {
      return UINavigationController(rootViewController: viewController)
    } else {
      return viewController
    }
  }
}
