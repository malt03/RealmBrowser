//
//  String+Extensions.swift
//  Pods
//
//  Created by Koji Murata on 2016/07/19.
//
//

import Foundation

extension String {
  func index(index: Int) -> Index {
    return startIndex.advancedBy(index)
  }
  
  func match(pattern: String) throws -> [Range<Index>] {
    let regex = try NSRegularExpression(pattern: pattern, options: [])
    let matches = regex.matchesInString(self, options: [], range: NSMakeRange(0, characters.count))
    return matches.map { index($0.range.location)..<index($0.range.location + $0.range.length) }
  }
  
  mutating func replace(pattern: String, handler: (match: String) -> String) throws {
    while let range = try match(pattern).first {
      let matchText = substringWithRange(range)
      let replaced = handler(match: matchText)
      replaceRange(range, with: replaced)
    }
  }
  
  func stringByReplacing(pattern: String, handler: (match: String) -> String) throws -> String {
    var replaced = self
    try replaced.replace(pattern, handler: handler)
    return replaced
  }
  
  var snakeCaseString: String {
    return try! stringByReplacing("[a-z\\d][A-Z]") {
      return $0.substringToIndex(self.index(1)) + "_" + $0.substringFromIndex(self.index(1))
      }.lowercaseString
  }
}
