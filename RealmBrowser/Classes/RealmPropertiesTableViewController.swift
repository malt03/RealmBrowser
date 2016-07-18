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
  private var showDatePickerSections = Set<Int>()
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
      if let value = object[property.name] as? Object {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("RealmPropertiesTableViewController") as! RealmPropertiesTableViewController
        vc.prepare(value)
        navigationController?.pushViewController(vc, animated: true)
        return
      }
    case .Date:
      let dateIndexPath = NSIndexPath(forRow: 1, inSection: indexPath.section)
      if showDatePickerSections.contains(indexPath.section) {
        showDatePickerSections.remove(indexPath.section)
        tableView.deleteRowsAtIndexPaths([dateIndexPath], withRowAnimation: .Fade)
      } else {
        showDatePickerSections.insert(indexPath.section)
        tableView.insertRowsAtIndexPaths([dateIndexPath], withRowAnimation: .Fade)
      }
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
    return 1 + (properties[section].optional ? 1 : 0) + (showDatePickerSections.contains(section) ? 1 : 0)
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let propertyIndexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
    let property = propertyAt(propertyIndexPath)!
    switch indexPath.row {
    case 0:
      let cell = tableView.dequeueReusableCellWithIdentifier("value", forIndexPath: indexPath) as! RealmPropertiesValueTableViewCell
      cell.prepare(object, property: property, keyboardAccessoryView: keyboardAccessoryView) { [weak self] (value) in
        guard let s = self,
          cellForNil = s.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: indexPath.section)) as? RealmPropertiesIsNilTableViewCell ??
            s.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: indexPath.section)) as? RealmPropertiesIsNilTableViewCell else
        {
          return
        }
        cellForNil.updateNil(true)
      }
      return cell
    case 1:
      if showDatePickerSections.contains(indexPath.section) {
        return createDateCell(indexPath, property: property)
      }
      return createIsNilCell(indexPath, property: property)
    case 2:
      return createIsNilCell(indexPath, property: property)
    default:
      return UITableViewCell()
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 44
  }
  
  private func createIsNilCell(indexPath: NSIndexPath, property: Property) -> RealmPropertiesIsNilTableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("isNil", forIndexPath: indexPath) as! RealmPropertiesIsNilTableViewCell
    cell.prepare(object, property: property) { [weak self] (isNotNil) in
      guard let s = self else { return }
      s.updateIsNotNil(isNotNil, property: property, indexPath: NSIndexPath(forRow: 0, inSection: indexPath.section))
    }
    return cell
  }
  
  private func createDateCell(indexPath: NSIndexPath, property: Property) -> DatePickingTableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("datePicker", forIndexPath: indexPath) as! DatePickingTableViewCell
    cell.prepare(object, property: property) { [weak self] in
      guard let s = self else { return }
      guard let cellForValue = s.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: indexPath.section)) as? RealmPropertiesValueTableViewCell else { return }
      cellForValue.updateValue(s.object, property: property)
      
      if let cellForNil = s.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: indexPath.section)) as? RealmPropertiesIsNilTableViewCell {
        cellForNil.updateNil(true)
      }
    }
    return cell
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
    cell.updateValue(object, property: property)
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
