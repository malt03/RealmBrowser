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
  @IBOutlet private weak var nilSwitch: UISwitch!
  private var object: Object!
  private var property: Property!
  private var didUpdateHandler: ((_ isNotNil: Bool) -> Void)!
  
  func prepare(object: Object, property: Property, didUpdateHandler: @escaping ((_ isNotNil: Bool) -> Void)) {
    self.object = object
    self.property = property
    self.didUpdateHandler = didUpdateHandler
    
    if !property.isOptional { return }
    nilSwitch.isOn = (object[property.name] != nil)
  }
  
  func updateNil(isNotNil: Bool) {
    nilSwitch.setOn(isNotNil, animated: true)
  }
  
  @IBAction private func nilChanged(_ sender: UISwitch) {
    didUpdateHandler(sender.isOn)
  }
}
