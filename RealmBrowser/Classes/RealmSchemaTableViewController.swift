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
  func prepare(_ doneButtonEnabled: Bool) {
    if doneButtonEnabled {
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
    }
  }
  
  @objc private func close() {
    self.dismiss(animated: true, completion: nil)
  }
  
  private let objectSchemas = try! Realm().schema.objectSchema.sorted { $0.className < $1.className }
  private var searchText = ""
  
  private var searchedObjectSchemas: [ObjectSchema] {
    if searchText == "" { return objectSchemas }
    let lower = searchText.lowercased()
    return objectSchemas.filter {
      $0.className.lowercased().range(of: lower) != nil ||
        $0.properties.reduce(false) { $0 || ($1.name.lowercased().range(of: lower) != nil) }
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchedObjectSchemas.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "default")!
    let schema = searchedObjectSchemas[indexPath.row]
    cell.textLabel?.text = schema.className
    cell.detailTextLabel?.text = schema.properties.map { $0.name }.joined(separator: ", ")
    return cell
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? RealmObjectsTableViewController {
      guard let indexPath = tableView.indexPathForSelectedRow else { return }
      vc.prepare(objectSchema: objectSchemas[indexPath.row])
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
