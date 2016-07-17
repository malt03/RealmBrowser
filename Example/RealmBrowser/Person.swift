//
//  Person.swift
//  RealmBrowser
//
//  Created by Koji Murata on 2016/07/14.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import RealmSwift

class Person: Object {
  dynamic var name: String? = ""
  dynamic var birthdate: NSDate? = NSDate(timeIntervalSince1970: 682095600)
  let piyo = RealmOptional<Bool>(false)
  dynamic var now = NSDate()
  dynamic var hoge = false
  let dogs = LinkingObjects(fromType: Dog.self, property: "owner")
}
