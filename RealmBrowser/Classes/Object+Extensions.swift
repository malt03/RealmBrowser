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
    return valueText(property: property)
  }
  
  var primaryPropertyText: String {
    guard let property = primaryProperty else { return "no properties" }
    return propertyText(property)
  }
  
  var propertiesText: String {
    guard let property = primaryProperty else { return "" }
    return objectSchema.properties.filter { $0.name != property.name }
      .map { propertyText($0) }
      .joined(separator: ", ")
  }

  private func propertyText(_ property: Property) -> String {
    return "\(property.name): \(valueText(property: property))"
  }
  
  func valueText(property: Property) -> String {
    guard let value = self[property.name] else { return "nil" }
    switch property.type {
    case .bool:
      return "\(value as! Bool)"
    case .double, .float, .int, .string:
      return "\(value)"
    case .date:
      let date = value as! Date
      let formatter = DateFormatter()
      formatter.dateStyle = .short
      formatter.timeStyle = .short
      return "(\(formatter.string(from: date)))"
    case .array:
      let array = value as! ListBase
      return "\(array.count) items"
    case .object:
      return "(\((value as! Object).primaryPropertyText))"
    case .linkingObjects:
      let linking = value as! LinkingObjects
      return "\(linking.count) items"
    case .data:
      return "NSData"
    case .any:
      return "Any"
    }
  }
}
