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
  @IBOutlet fileprivate weak var primaryPropertyLabel: UILabel!
  @IBOutlet fileprivate weak var propertiesLabel: UILabel!
  
  func prepare(_ object: Object) {
    primaryPropertyLabel.text = object.primaryPropertyText
    propertiesLabel.text = object.propertiesText
  }
}
