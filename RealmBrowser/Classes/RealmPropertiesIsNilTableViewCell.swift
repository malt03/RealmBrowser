//
//  RealmPropertiesIsNilTableViewCell.swift
//  Pods
//
//  Created by Koji Murata on 2016/07/15.
//
//

import UIKit
import RealmSwift

final class RealmPropertiesIsNilTableViewCell: UITableViewCell {
  @IBOutlet fileprivate weak var nilSwitch: UISwitch!
  fileprivate var object: Object!
  fileprivate var property: Property!
  fileprivate var didUpdateHandler: ((_ isNotNil: Bool) -> Void)!
  
  func prepare(_ object: Object, property: Property, didUpdateHandler: @escaping ((_ isNotNil: Bool) -> Void)) {
    self.object = object
    self.property = property
    self.didUpdateHandler = didUpdateHandler
    
    if !property.isOptional { return }
    nilSwitch.isOn = (object[property.name] != nil)
  }
  
  func updateNil(_ isNotNil: Bool) {
    nilSwitch.setOn(isNotNil, animated: true)
  }
  
  @IBAction fileprivate func nilChanged(_ sender: UISwitch) {
    didUpdateHandler(sender.isOn)
  }
}
