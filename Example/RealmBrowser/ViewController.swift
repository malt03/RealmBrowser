//
//  ViewController.swift
//  RealmBrowser
//
//  Created by Koji Murata on 07/14/2016.
//  Copyright (c) 2016 Koji Murata. All rights reserved.
//

import UIKit
import RealmSwift
import RealmBrowser

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
//    let owner = Person()
//    print(owner.objectSchema.properties)
//    
//    let realm = try! Realm()
//    let dog = Dog()
//    owner.name = nil
//    dog.name = "Rex"
//    dog.age = 10
//    dog.owner = owner
//    print(Dog.className())
//    try! realm.write {
//      realm.add(dog)
//      dog.setValue(true, forKeyPath: "hoge")
//      print(dog["hoge"])
//      print(owner.dogs)
//    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    presentViewController(RealmBrowser.instantiate("RealmBrowser_Example"), animated: true, completion: nil)
  }
}
