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
  private var didSelectChildHandler: ((_ object: Object) -> Void)?
  
  private var searchedResults: [Object] {
    var objects = [Object]()
    
    if searchText == "" {
      for i in 0..<results.count {
        objects.append(results[i])
      }
    } else {
      let lower = searchText.lowercased()
      for i in 0..<results.count {
        let object = results[i]
        let append = object.objectSchema.properties.reduce(false) {
          $0 || object.valueText(property: $1).lowercased().range(of: lower) != nil
        }
        if append { objects.append(object) }
      }
    }
    
    return objects
  }
  
  private func object(_ indexPath: IndexPath) -> Object {
    return RealmBrowser.objectSearchEnabled ? searchedResults[indexPath.row] : results[indexPath.row]
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if let indexPath = tableView.indexPathForSelectedRow, let cell = tableView.cellForRow(at: indexPath) as? RealmObjectsTableViewCell {
      cell.prepare(object: object(indexPath))
    } else if let c = composedObject {
      let realm = try! Realm()
      try! realm.write {
        realm.add(c)
        composedObject = nil
        tableView.reloadData()
      }
    }
    if let selected = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selected, animated: true)
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
  
  func selectChild(property: Property, completionHandler: @escaping ((_ object: Object) -> Void)) {
    selectChild = true
    title = "Select \(property.name)"
    didSelectChildHandler = completionHandler
  }
  
  @IBAction private func compose() {
    guard let klass = NSClassFromString(RealmBrowser.moduleName + "." + objectSchema.className) as? Object.Type else {
      let alert = UIAlertController(title: "Error", message: "The module name \"\(RealmBrowser.moduleName)\" is incorrect. " + RealmBrowser.incorrectModuleNameMessage, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
      return
    }
    composedObject = klass.init()
    performSegue(withIdentifier: "showObject", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? RealmPropertiesTableViewController {
      guard let o = (tableView.indexPathForSelectedRow.map { self.object($0) } ?? composedObject) else { return }
      vc.prepare(o, composed: composedObject != nil)
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return RealmBrowser.objectSearchEnabled ? searchedResults.count : results.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! RealmObjectsTableViewCell
    cell.prepare(object: object(indexPath))
    cell.accessoryType = selectChild ? .none : .disclosureIndicator
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    let realm = try! Realm()
    try! realm.write {
      realm.delete(searchedResults[indexPath.row])
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if selectChild {
      didSelectChildHandler?(object(indexPath))
      _ = navigationController?.popViewController(animated: true)
    } else {
      performSegue(withIdentifier: "showObject", sender: nil)
    }
  }
  
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    view.endEditing(true)
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.searchText = searchText
    tableView.reloadData()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    view.endEditing(true)
  }
}
