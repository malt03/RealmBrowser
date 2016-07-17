//
//  RealmPropertiesValueTableViewCell.swift
//  Pods
//
//  Created by Koji Murata on 2016/07/15.
//
//

import UIKit
import RealmSwift

final class RealmPropertiesValueTableViewCell: UITableViewCell {
  @IBOutlet private weak var valueTextField: UITextField!
  @IBOutlet private weak var valueSwitch: UISwitch!
  
  private var object: Object!
  private var property: Property!
  
  func prepare(object: Object, property: Property, keyboardAccessoryView: UIView) {
    accessoryType = .None
    userInteractionEnabled = true
    valueTextField.enabled = true
    valueTextField.hidden = false
    valueTextField.textColor = .blackColor()
    valueSwitch.enabled = true
    valueSwitch.hidden = true
    
    self.object = object
    self.property = property
    
    let value = object[property.name]
    
    valueTextField.inputAccessoryView = keyboardAccessoryView
    valueTextField.text = object.valueText(property)
    
    switch property.type {
    case .Any, .Array, .Data, .Date, .LinkingObjects:
      valueTextField.enabled = false
    case .Object:
      valueTextField.enabled = false
      accessoryType = .DisclosureIndicator
    case .Bool:
      valueSwitch.setOn(value as? Bool ?? false, animated: true)
      valueTextField.enabled = false
      valueTextField.hidden = true
      valueSwitch.hidden = false
    case .Double, .Float:
      valueTextField.keyboardType = .DecimalPad
    case .Int:
      valueTextField.keyboardType = .NumberPad
    case .String:
      valueTextField.keyboardType = .Default
    }
    
    if object.objectSchema.primaryKeyProperty == property || value == nil {
      valueTextField.enabled = false
      valueSwitch.enabled = false
      valueTextField.textColor = .lightGrayColor()
      userInteractionEnabled = false
    }
  }
  
  func tap() {
    if valueTextField.enabled { valueTextField.becomeFirstResponder() }
    if valueSwitch.enabled {
      valueSwitch.setOn(!valueSwitch.on, animated: true)
      switchValueDidChange(valueSwitch)
    }
  }
  
  @IBAction func valueDidChange(sender: UITextField) {
    let text = sender.text ?? ""
    let value: AnyObject?
    switch property.type {
    case .Double: value = Double(text)
    case .Float:  value = Float(text)
    case .Int:    value = Int(text)
    case .String: value = text
    default: return
    }
    guard let v = value else { return }
    update(v)
  }

  @IBAction func didEndOnExit(sender: UITextField) {
    sender.resignFirstResponder()
  }

  @IBAction func switchValueDidChange(sender: UISwitch) {
    if property.type != .Bool { return }
    update(sender.on)
  }
  
  private func update(value: AnyObject) {
    try! Realm().write {
      object.setValue(value, forKeyPath: property.name)
    }
  }
}
