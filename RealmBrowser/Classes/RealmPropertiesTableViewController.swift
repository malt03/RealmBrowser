//
//  RealmPropertiesTableViewController.swift
//  Pods
//
//  Created by Koji Murata on 2016/07/15.
//
//

import UIKit
import RealmSwift

final class RealmPropertiesTableViewController: UITableViewController {
  @IBOutlet private var keyboardAccessoryView: UIToolbar!
  
  @IBAction private func endEditing() {
    view.endEditing(true)
  }
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    view.endEditing(true)
  }
  
  private var changeNotNilProperty: Property?
  private var object: Object!
  private var properties: [Property] {
    return object.objectSchema.properties
  }
  
  private func propertyAt(indexPath: NSIndexPath) -> Property? {
    if indexPath.row != 0 { return nil }
    return properties[indexPath.section]
  }
  
  func prepare(object: Object) {
    self.object = object
    title = object.primaryValueText
  }
  
  override func viewWillAppear(animated: Bool) {
    tableView.reloadData()
    super.viewWillAppear(animated)
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let property = propertyAt(indexPath) else {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      return
    }

    switch property.type {
    case .Double, .Float, .Int, .String, .Bool:
      guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? RealmPropertiesValueTableViewCell else { break }
      cell.tap()
    case .Object:
      let vc = storyboard?.instantiateViewControllerWithIdentifier("RealmPropertiesTableViewController") as! RealmPropertiesTableViewController
      vc.prepare(object[property.name] as! Object)
      navigationController?.pushViewController(vc, animated: true)
      return
    case .Date:
      break
    case .Any, .Array, .Data, .LinkingObjects:
      break
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return properties[section].name
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return properties.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1 + (properties[section].optional ? 1 : 0)
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let propertyIndexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
    let property = propertyAt(propertyIndexPath)!
    switch indexPath.row {
    case 0:
      let cell = tableView.dequeueReusableCellWithIdentifier("value", forIndexPath: indexPath) as! RealmPropertiesValueTableViewCell
      cell.prepare(object, property: property, keyboardAccessoryView: keyboardAccessoryView)
      return cell
    case 1:
      let cell = tableView.dequeueReusableCellWithIdentifier("isNil", forIndexPath: indexPath) as! RealmPropertiesIsNilTableViewCell
      cell.prepare(object, property: property) { [weak self] (isNotNil) in
        guard let s = self else { return }
        s.updateIsNotNil(isNotNil, property: property, indexPath: propertyIndexPath)
      }
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  private func updateIsNotNil(isNotNil: Bool, property: Property, indexPath: NSIndexPath) {
    let value: AnyObject?
    
    if isNotNil {
      property.objectClassName
      switch property.type {
      case .Any:    value = ""
      case .Array:  value = []
      case .Bool:   value = false
      case .Data:   value = NSData()
      case .Date:   value = NSDate()
      case .Double: value = Double(0)
      case .Float:  value = Float(0)
      case .Int:    value = Int(0)
      case .String: value = ""
      case .Object:
        changeNotNilProperty = property
        performSegueWithIdentifier("selectChild", sender: nil)
        return
      default: return
      }
    } else {
      value = nil
    }
    
    try! Realm().write {
      object.setValue(value, forKeyPath: property.name)
    }
    
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! RealmPropertiesValueTableViewCell
    cell.prepare(object, property: property, keyboardAccessoryView: keyboardAccessoryView)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = segue.destinationViewController as? RealmObjectsTableViewController,
      property = changeNotNilProperty,
      className = property.objectClassName
    {
      for schema in try! Realm().schema.objectSchema {
        if schema.className == className {
          vc.prepare(schema)
          vc.selectChild(property) { [weak self] (object) in
            guard let s = self else { return }
            try! Realm().write {
              s.object.setValue(object, forKeyPath: property.name)
            }
          }
        }
      }
    }
  }
}
