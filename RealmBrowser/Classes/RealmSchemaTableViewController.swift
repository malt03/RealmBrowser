//
//  RealmSchemaTableViewController.swift
//  Pods
//
//  Created by Koji Murata on 2016/07/14.
//
//

import UIKit
import RealmSwift

final class RealmSchemaTableViewController: UITableViewController, UISearchBarDelegate {
  func prepare(doneButtonEnabled: Bool) {
    if doneButtonEnabled {
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismiss))
    }
  }
  
  @objc private func dismiss() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  private let objectSchemas = try! Realm().schema.objectSchema.sort { $0.className < $1.className }
  private var searchText = ""
  
  private var searchedObjectSchemas: [ObjectSchema] {
    if searchText == "" { return objectSchemas }
    let lower = searchText.lowercaseString
    return objectSchemas.filter {
      $0.className.lowercaseString.rangeOfString(lower) != nil ||
        $0.properties.reduce(false) { $0 || ($1.name.lowercaseString.rangeOfString(lower) != nil) }
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchedObjectSchemas.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("default")!
    let schema = searchedObjectSchemas[indexPath.row]
    cell.textLabel?.text = schema.className
    cell.detailTextLabel?.text = schema.properties.map { $0.name }.joinWithSeparator(", ")
    return cell
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = segue.destinationViewController as? RealmObjectsTableViewController {
      guard let indexPath = tableView.indexPathForSelectedRow else { return }
      vc.prepare(objectSchemas[indexPath.row])
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
