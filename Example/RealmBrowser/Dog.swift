//
//  Dog.swift
//  RealmBrowser
//
//  Created by Koji Murata on 2016/07/14.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Dog: Object {
  dynamic var name = ""
  dynamic var age = 0
  let hoge = RealmOptional<Bool>()
  dynamic var owner: Person?
}
