//
//  ViewController.swift
//  Todoey
//
//  Created by mike oshea on 12/28/18.
//  Copyright © 2018 Future Trends. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController, UISearchBarDelegate {

    var realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    var itemResults : Results<ToDo>?
    var defaults = UserDefaults.standard
    var category : Category? {
        didSet {
            loaditemsByCategory()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        print("selected category",category?.name ?? "None")
        loaditemsByCategory()
    }

    func loaditemsByCategory() {
        itemResults = category?.todos.sorted(byKeyPath: "text", ascending: true)
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemResults = itemResults?.filter("text CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "created", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loaditemsByCategory()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemResults?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoitemCell", for: indexPath)
        if let todo = itemResults?[indexPath.row] {
            cell.textLabel?.text = todo.text
            cell.accessoryType = todo.done == false ? .none : .checkmark
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }

    //MARK: - Tableview touch
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let todo = itemResults?[indexPath.row] {
            do {
                try realm.write {
                    todo.done = !todo.done
                }
            } catch {
                print("Error updating todo")
            }
        }
        tableView.reloadData()
    }
    
    func save(todo : ToDo) {
        do {
            try realm.write {
                realm.add(todo)
            }
        } catch {
            print("Error saving \(error)")
        }
        self.tableView.reloadData()

    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once user clicks the add item button
            if (textField.text! != "") {
                if let currCat = self.category {
                    do {
                        try self.realm.write {
                            let item = ToDo()
                            item.text = textField.text!
                            item.created = Date()
                            currCat.todos.append(item)
                        }
                    } catch {
                        print("Error saving")
                    }
                }
                self.tableView.reloadData()
            }
        }
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Create New Item"
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

