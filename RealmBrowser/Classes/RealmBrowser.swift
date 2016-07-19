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
  
  public static var incorrectModuleNameMessage = "The module name \"\(RealmBrowser.moduleName)\" is incorrect. Please call RealmBrowser.instantiate with correct module name."
  
  public static func instantiate(moduleName moduleName: String, withNavigationController: Bool = true, objectSearchEnabled: Bool = true) -> UIViewController {
    RealmBrowser.moduleName = moduleName
    RealmBrowser.objectSearchEnabled = objectSearchEnabled
    
    let bundle = NSBundle(path: NSBundle(forClass: RealmBrowser.self).pathForResource("RealmBrowser", ofType: "bundle")!)!
    let viewController = UIStoryboard(name: "RealmBrowser", bundle: bundle).instantiateInitialViewController() as! RealmSchemaTableViewController
    viewController.prepare(withNavigationController)
    if withNavigationController {
      return UINavigationController(rootViewController: viewController)
    } else {
      return viewController
    }
  }
}
