//
//  Object+Extensions.swift
//  Pods
//
//  Created by Koji Murata on 2016/07/15.
//
//

import RealmSwift

extension Object {
  private var primaryProperty: Property? {
    return objectSchema.primaryKeyProperty ?? objectSchema.properties.first
  }
  
  var primaryValueText: String {
    guard let property = primaryProperty else { return "no properties" }
    return valueText(property)
  }
  
  var primaryPropertyText: String {
    guard let property = primaryProperty else { return "no properties" }
    return propertyText(property)
  }
  
  var propertiesText: String {
    guard let property = primaryProperty else { return "" }
    return objectSchema.properties.filter { $0.name != property.name }
      .map { propertyText($0) }
      .joinWithSeparator(", ")
  }

  private func propertyText(property: Property) -> String {
    return "\(property.name): \(valueText(property))"
  }
  
  func valueText(property: Property) -> String {
    guard let value = self[property.name] else { return "nil" }
    switch property.type {
    case .Bool:
      return "\(value as! Bool)"
    case .Double, .Float, .Int, .String:
      return "\(value)"
    case .Date:
      let date = value as! NSDate
      let formatter = NSDateFormatter()
      formatter.dateStyle = .ShortStyle
      formatter.timeStyle = .ShortStyle
      return "(\(formatter.stringFromDate(date)))"
    case .Array:
      let array = value as! ListBase
      return "\(array.count) items"
    case .Object:
      return "(\((value as! Object).primaryPropertyText))"
    case .LinkingObjects:
      let linking = value as! LinkingObjects
      return "\(linking.count) items"
    case .Data:
      return "NSData"
    case .Any:
      return "Any"
    }
  }
}
