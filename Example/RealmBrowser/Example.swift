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
  dynamic var boolValue = true
  dynamic var int8Value = Int8(0)
  dynamic var int16Value = Int16(0)
  dynamic var int32Value = Int32(0)
  dynamic var int64Value = Int64(0)
  dynamic var doubleValue = Double(0)
  dynamic var floatValue = Float(0)
  dynamic var stringValue = ""
  dynamic var dateValue = NSDate()
  dynamic var dataValue = NSData()
  let optionalBoolValue = RealmOptional<Bool>(true)
  let optionalIntValue = RealmOptional<Int>(0)
  let optionalDoubleValue = RealmOptional<Double>(0)
  let optionalFloatValue = RealmOptional<Float>(0)
  dynamic var optionalStringValue: String? = ""
  dynamic var optionalDateValue: NSDate? = NSDate()
  dynamic var optionalDataValue: NSData? = NSData()
  
  var child: Child?
  let children = List<Child>()
  
  override class func primaryKey() -> String? {
    return "stringValue"
  }
}
