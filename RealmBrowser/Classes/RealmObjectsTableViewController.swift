//
//  RealmObjectsTableViewController.swift
//  Pods
//
//  Created by Koji Murata on 2016/07/14.
//
//

import UIKit
import RealmSwift

final class RealmObjectsTableViewController: UITableViewController, UISearchBarDelegate {
  private var objectSchema: ObjectSchema!
  private var results: Results<DynamicObject>!
  private var searchText = ""
  private var composedObject: Object?
  private var selectChild = false
  private var didSelectChildHandler: ((object: Object) -> Void)?
  
  private var searchedResults: [Object] {
    var objects = [Object]()
    
    if searchText == "" {
      for i in 0..<results.count {
        objects.append(results[i])
      }
    } else {
      let lower = searchText.lowercaseString
      for i in 0..<results.count {
        let object = results[i]
        let append = object.objectSchema.properties.reduce(false) {
          $0 || object.valueText($1).lowercaseString.rangeOfString(lower) != nil
        }
        if append { objects.append(object) }
      }
    }
    
    return objects
  }
  
  private func object(indexPath: NSIndexPath) -> Object {
    return RealmBrowser.objectSearchEnabled ? searchedResults[indexPath.row] : results[indexPath.row]
  }
  
  override func viewWillAppear(animated: Bool) {
    if let indexPath = tableView.indexPathForSelectedRow, cell = tableView.cellForRowAtIndexPath(indexPath) as? RealmObjectsTableViewCell {
      cell.prepare(object(indexPath))
    } else if let c = composedObject {
      let realm = try! Realm()
      try! realm.write {
        realm.add(c)
        composedObject = nil
        tableView.reloadData()
      }
    }
    super.viewWillAppear(animated)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if !RealmBrowser.objectSearchEnabled {
      tableView.tableHeaderView = nil
    }
  }
  
  func prepare(objectSchema: ObjectSchema) {
    self.objectSchema = objectSchema
    let realm = try! Realm()
    results = realm.dynamicObjects(objectSchema.className)
    title = objectSchema.className
  }
  
  func selectChild(property: Property, completionHandler: ((object: Object) -> Void)) {
    selectChild = true
    title = "Select \(property.name)"
    didSelectChildHandler = completionHandler
  }
  
  @IBAction private func compose() {
    guard let klass = NSClassFromString(RealmBrowser.moduleName + "." + objectSchema.className) as? Object.Type else {
      let alert = UIAlertController(title: "Error", message: RealmBrowser.incorrectModuleNameMessage, preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      presentViewController(alert, animated: true, completion: nil)
      return
    }
    composedObject = klass.init()
    performSegueWithIdentifier("showObject", sender: nil)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = segue.destinationViewController as? RealmPropertiesTableViewController {
      guard let o = (tableView.indexPathForSelectedRow.map { self.object($0) } ?? composedObject) else { return }
      vc.prepare(o, composed: composedObject != nil)
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return RealmBrowser.objectSearchEnabled ? searchedResults.count : results.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("default", forIndexPath: indexPath) as! RealmObjectsTableViewCell
    cell.prepare(object(indexPath))
    cell.accessoryType = selectChild ? .None : .DisclosureIndicator
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 44
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    let realm = try! Realm()
    try! realm.write {
      realm.delete(searchedResults[indexPath.row])
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if selectChild {
      didSelectChildHandler?(object: object(indexPath))
      navigationController?.popViewControllerAnimated(true)
    } else {
      performSegueWithIdentifier("showObject", sender: nil)
    }
  }
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    view.endEditing(true)
  }

  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    self.searchText = searchText
    tableView.reloadData()
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    view.endEditing(true)
  }
}
