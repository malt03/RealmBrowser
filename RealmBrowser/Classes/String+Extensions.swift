//
//  String+Extensions.swift
//  Pods
//
//  Created by Koji Murata on 2016/07/19.
//
//

import Foundation

extension String {
  func index(_ index: Int) -> Index {
    return characters.index(startIndex, offsetBy: index)
  }
  
  func match(_ pattern: String) throws -> [Range<Index>] {
    let regex = try NSRegularExpression(pattern: pattern, options: [])
    let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, characters.count))
    return matches.map { index($0.range.location)..<index($0.range.location + $0.range.length) }
  }
  
  mutating func replace(_ pattern: String, handler: (_ match: Substring) -> String) throws {
    if let range = try match(pattern).first {
      let matchText = self[range]
      let replaced = handler(matchText)
      replaceSubrange(range, with: replaced)
    }
  }
  
  func stringByReplacing(_ pattern: String, handler: (_ match: Substring) -> String) throws -> String {
    var replaced = self
    try replaced.replace(pattern, handler: handler)
    return replaced
  }
  
  var snakeCaseString: String {
    return try! stringByReplacing("[a-z\\d][A-Z]") {
      let s = String($0)
      return String(s[s.index(0)]) + "_" + String(s[s.index(1)])
    }.lowercased()
  }
}
