//
//  Example.swift
//  RealmBrowser
//
//  Created by Koji Murata on 2016/07/19.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import RealmSwift

class Example: Object {
  @objc dynamic var boolValue = true
  @objc dynamic var int8Value = Int8(0)
  @objc dynamic var int16Value = Int16(0)
  @objc dynamic var int32Value = Int32(0)
  @objc dynamic var int64Value = Int64(0)
  @objc dynamic var doubleValue = Double(0)
  @objc dynamic var floatValue = Float(0)
  @objc dynamic var stringValue = ""
  @objc dynamic var dateValue = NSDate()
  @objc dynamic var dataValue = NSData()
  let optionalBoolValue = RealmOptional<Bool>(true)
  let optionalIntValue = RealmOptional<Int>(0)
  let optionalDoubleValue = RealmOptional<Double>(0)
  let optionalFloatValue = RealmOptional<Float>(0)
  @objc dynamic var optionalStringValue: String? = ""
  @objc dynamic var optionalDateValue: NSDate? = NSDate()
  @objc dynamic var optionalDataValue: NSData? = NSData()
  
  @objc dynamic var child: Child?
  let children = List<Child>()
  
  override class func primaryKey() -> String? {
    return "stringValue"
  }
}
