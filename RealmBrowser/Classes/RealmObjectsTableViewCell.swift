//
//  RealmObjectsTableViewCell.swift
//  Pods
//
//  Created by Koji Murata on 2016/07/15.
//
//

import UIKit
import RealmSwift

final class RealmObjectsTableViewCell: UITableViewCell {
  @IBOutlet private weak var primaryPropertyLabel: UILabel!
  @IBOutlet private weak var propertiesLabel: UILabel!
  
  func prepare(object: Object) {
    primaryPropertyLabel.text = object.primaryPropertyText
    propertiesLabel.text = object.propertiesText
  }
}
