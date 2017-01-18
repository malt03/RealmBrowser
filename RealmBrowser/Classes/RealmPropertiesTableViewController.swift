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
  
  override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    view.endEditing(true)
  }
  
  private var changeNotNilProperty: Property?
  private var object: Object!
  private var showDatePickerSections = Set<Int>()
  private var composed = false
  private var properties: [Property] {
    return object.objectSchema.properties
  }
  
  private func propertyAt(_ indexPath: IndexPath) -> Property? {
    if indexPath.row != 0 { return nil }
    return properties[indexPath.section]
  }
  
  func prepare(_ object: Object, composed: Bool) {
    self.composed = composed
    self.object = object
    title = composed ? "Compose \(object.objectSchema.className)" : object.primaryValueText
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tableView.reloadData()
    super.viewWillAppear(animated)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let property = propertyAt(indexPath) else {
      tableView.deselectRow(at: indexPath, animated: true)
      return
    }

    switch property.type {
    case .double, .float, .int, .string, .bool:
      guard let cell = tableView.cellForRow(at: indexPath) as? RealmPropertiesValueTableViewCell else { break }
      cell.tap()
    case .object:
      if let value = object[property.name] as? Object {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RealmPropertiesTableViewController") as! RealmPropertiesTableViewController
        vc.prepare(value, composed: false)
        navigationController?.pushViewController(vc, animated: true)
        return
      }
    case .date:
      let dateIndexPath = IndexPath(row: 1, section: (indexPath as NSIndexPath).section)
      if showDatePickerSections.contains((indexPath as NSIndexPath).section) {
        showDatePickerSections.remove((indexPath as NSIndexPath).section)
        tableView.deleteRows(at: [dateIndexPath], with: .fade)
      } else {
        showDatePickerSections.insert((indexPath as NSIndexPath).section)
        tableView.insertRows(at: [dateIndexPath], with: .fade)
      }
    case .any, .array, .data, .linkingObjects:
      break
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return try! properties[section].name.snakeCaseString.stringByReplacing("_") { _ in " " }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return properties.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1 + (properties[section].isOptional ? 1 : 0) + (showDatePickerSections.contains(section) ? 1 : 0)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let propertyIndexPath = IndexPath(row: 0, section: (indexPath as NSIndexPath).section)
    let property = propertyAt(propertyIndexPath)!
    switch (indexPath as NSIndexPath).row {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: "value", for: indexPath) as! RealmPropertiesValueTableViewCell
      cell.prepare(object, property: property, composed: composed, keyboardAccessoryView: keyboardAccessoryView) { [weak self] (value) in
        guard let s = self,
          let cellForNil = s.tableView.cellForRow(at: IndexPath(row: 1, section: indexPath.section)) as? RealmPropertiesIsNilTableViewCell ??
            s.tableView.cellForRow(at: IndexPath(row: 2, section: indexPath.section)) as? RealmPropertiesIsNilTableViewCell else
        {
          return
        }
        cellForNil.updateNil(isNotNil: true)
      }
      return cell
    case 1:
      if showDatePickerSections.contains((indexPath as NSIndexPath).section) {
        return createDateCell(indexPath, property: property)
      }
      return createIsNilCell(indexPath, property: property)
    case 2:
      return createIsNilCell(indexPath, property: property)
    default:
      return UITableViewCell()
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44
  }
  
  private func createIsNilCell(_ indexPath: IndexPath, property: Property) -> RealmPropertiesIsNilTableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "isNil", for: indexPath) as! RealmPropertiesIsNilTableViewCell
    cell.prepare(object: object, property: property) { [weak self] (isNotNil) in
      guard let s = self else { return }
      s.updateIsNotNil(isNotNil, property: property, indexPath: IndexPath(row: 0, section: indexPath.section))
    }
    return cell
  }
  
  private func createDateCell(_ indexPath: IndexPath, property: Property) -> DatePickingTableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "datePicker", for: indexPath) as! DatePickingTableViewCell
    cell.prepare(object: object, property: property) { [weak self] in
      guard let s = self else { return }
      guard let cellForValue = s.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section)) as? RealmPropertiesValueTableViewCell else { return }
      cellForValue.updateValue(s.object, property: property, composed: s.composed, animated: true)
      
      if let cellForNil = s.tableView.cellForRow(at: IndexPath(row: 2, section: indexPath.section)) as? RealmPropertiesIsNilTableViewCell {
        cellForNil.updateNil(isNotNil: true)
      }
    }
    return cell
  }
  
  private func updateIsNotNil(_ isNotNil: Bool, property: Property, indexPath: IndexPath) {
    let value: AnyObject?
    
    if isNotNil {
      switch property.type {
      case .any:    value = "" as AnyObject?
      case .array:  value = [] as AnyObject?
      case .bool:   value = false as AnyObject?
      case .data:   value = Data() as AnyObject?
      case .date:   value = Date() as AnyObject?
      case .double: value = Double(0) as AnyObject?
      case .float:  value = Float(0) as AnyObject?
      case .int:    value = Int(0) as AnyObject?
      case .string: value = "" as AnyObject?
      case .object:
        changeNotNilProperty = property
        performSegue(withIdentifier: "selectChild", sender: nil)
        return
      default: return
      }
    } else {
      value = nil
    }
    
    try! Realm().write {
      object.setValue(value, forKeyPath: property.name)
    }
    
    let cell = tableView.cellForRow(at: indexPath) as! RealmPropertiesValueTableViewCell
    cell.updateValue(object, property: property, composed: composed, animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? RealmObjectsTableViewController,
      let property = changeNotNilProperty,
      let className = property.objectClassName
    {
      for schema in try! Realm().schema.objectSchema {
        if schema.className == className {
          vc.prepare(objectSchema: schema)
          vc.selectChild(property: property) { [weak self] (object) in
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
