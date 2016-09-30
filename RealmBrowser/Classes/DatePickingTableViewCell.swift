//
//  DatePickingTableViewCell.swift
//  Pods
//
//  Created by Koji Murata on 2016/07/15.
//
//

import UIKit
import RealmSwift

final class DatePickingTableViewCell: UITableViewCell {
  @IBOutlet fileprivate var datePicker: UIDatePicker!
  
  fileprivate var object: Object!
  fileprivate var property: Property!
  fileprivate var dateChangeHandler: (() -> Void)!
  
  func prepare(_ object: Object, property: Property, dateChangeHandler: @escaping (() -> Void)) {
    self.object = object
    self.property = property
    self.dateChangeHandler = dateChangeHandler
    guard let date = object[property.name] as? Date else { return }
    datePicker.setDate(date, animated: false)
  }
  
  @IBAction fileprivate func dateChanged(_ sender: UIDatePicker) {
    try! Realm().write {
      object.setValue(sender.date, forKeyPath: property.name)
      dateChangeHandler()
    }
  }
}
