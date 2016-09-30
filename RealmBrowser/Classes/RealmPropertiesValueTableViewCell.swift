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
  private var valueDidChangeHandler: ((_ value: AnyObject?) -> Void)!
  
  func prepare(_ object: Object, property: Property, composed: Bool, keyboardAccessoryView: UIView, valueDidChangeHandler: @escaping ((_ value: AnyObject?) -> Void)) {
    self.valueDidChangeHandler = valueDidChangeHandler
    
    valueTextField.inputAccessoryView = keyboardAccessoryView

    updateValue(object, property: property, composed: composed, animated: false)
  }
  
  func updateValue(_ object: Object, property: Property, composed: Bool, animated: Bool) {
    accessoryType = .none
    isUserInteractionEnabled = true
    valueTextField.isEnabled = true
    valueTextField.isHidden = false
    valueTextField.textColor = .black
    valueTextField.attributedPlaceholder = NSAttributedString(string: "input value", attributes: [
      NSForegroundColorAttributeName: UIColor.lightGray
    ])

    valueSwitch.isEnabled = true
    valueSwitch.isHidden = true
    
    self.object = object
    self.property = property
    
    valueTextField.text = object.valueText(property: property)

    let value = object[property.name]
    
    switch property.type {
    case .any, .array, .data, .date, .linkingObjects:
      valueTextField.isEnabled = false
    case .object:
      valueTextField.isEnabled = false
      accessoryType = .disclosureIndicator
    case .bool:
      valueSwitch.setOn(value as? Bool ?? false, animated: animated)
      valueTextField.isEnabled = false
      valueTextField.isHidden = true
      valueSwitch.isHidden = false
    case .double, .float:
      valueTextField.keyboardType = .decimalPad
    case .int:
      valueTextField.keyboardType = .numberPad
    case .string:
      valueTextField.keyboardType = .default
    }
    
    if object.objectSchema.primaryKeyProperty == property && !composed {
      valueTextField.isEnabled = false
      valueSwitch.isEnabled = false
      valueTextField.textColor = .lightGray
      isUserInteractionEnabled = false
    }
    
    if value == nil {
      valueTextField.text = ""
      valueTextField.attributedPlaceholder = NSAttributedString(string: "nil", attributes: [
        NSForegroundColorAttributeName: UIColor.red.withAlphaComponent(0.5)
      ])
    }
  }
  
  func tap() {
    if valueTextField.isEnabled { valueTextField.becomeFirstResponder() }
    if valueSwitch.isEnabled {
      valueSwitch.setOn(!valueSwitch.isOn, animated: true)
      switchValueDidChange(valueSwitch)
    }
  }
  
  @IBAction func valueDidChange(_ sender: UITextField) {
    valueTextField.attributedPlaceholder = NSAttributedString(string: "input value", attributes: [
      NSForegroundColorAttributeName: UIColor.lightGray
    ])
    let text = sender.text ?? ""
    let value: AnyObject?
    switch property.type {
    case .double: value = Double(text) as AnyObject?
    case .float:  value = Float(text) as AnyObject?
    case .int:    value = Int(text) as AnyObject?
    case .string: value = text as AnyObject?
    default: return
    }
    guard let v = value else { return }
    update(v)
  }

  @IBAction func didEndOnExit(_ sender: UITextField) {
    sender.resignFirstResponder()
  }

  @IBAction func switchValueDidChange(_ sender: UISwitch) {
    if property.type != .bool { return }
    update(sender.isOn as AnyObject)
  }
  
  private func update(_ value: AnyObject) {
    try! Realm().write {
      object.setValue(value, forKeyPath: property.name)
    }
    valueDidChangeHandler(value)
  }
}
