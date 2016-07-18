//
//  Child.swift
//  RealmBrowser
//
//  Created by Koji Murata on 2016/07/19.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import RealmSwift

class Child: Object {
  dynamic var boolValue = true
  dynamic var intValue = 0
  dynamic var doubleValue = Double(0)
  dynamic var floatValue = Float(0)
  dynamic var stringValue = ""
  dynamic var dateValue = NSDate()
  dynamic var dataValue = NSData()
  
  override class func primaryKey() -> String? {
    return "stringValue"
  }
}
