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
  @IBOutlet private var datePicker: UIDatePicker!
  
  private var object: Object!
  private var property: Property!
  private var dateChangeHandler: (() -> Void)!
  
  func prepare(object: Object, property: Property, dateChangeHandler: (() -> Void)) {
    self.object = object
    self.property = property
    self.dateChangeHandler = dateChangeHandler
    guard let date = object[property.name] as? NSDate else { return }
    datePicker.setDate(date, animated: false)
  }
  
  @IBAction private func dateChanged(sender: UIDatePicker) {
    try! Realm().write {
      object.setValue(sender.date, forKeyPath: property.name)
      dateChangeHandler()
    }
  }
}
