//
//  ViewController.swift
//  Todoey
//
//  Created by mike oshea on 12/28/18.
//  Copyright © 2018 Future Trends. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController, UISearchBarDelegate {

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
        tableView.separatorStyle = .none
        loaditemsByCategory()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let hexColor = category?.backGroundColor {
            title = category?.name
            let navColor = UIColor(hexString: hexColor)
            navigationController?.navigationBar.barTintColor = navColor
            searchBar.barTintColor = navColor
            let contrastColor = UIColor.init(contrastingBlackOrWhiteColorOn: navColor, isFlat: true)
            navigationController?.navigationBar.tintColor = contrastColor
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor!]
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let originalColor = UIColor(hexString: "1D98F6") else { fatalError()}
        let navBar = navigationController?.navigationBar
        navBar?.barTintColor = originalColor
        navBar?.tintColor = UIColor.flatWhite()
        navBar?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.flatWhite()]
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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let todo = itemResults?[indexPath.row] {
            cell.textLabel?.text = todo.text
            cell.accessoryType = todo.done == false ? .none : .checkmark
            let percentChange = 1 / CGFloat((itemResults?.count)!) * CGFloat(indexPath.row)
            let parentColor = itemResults?[indexPath.row].parentCategory.first?.backGroundColor
            cell.backgroundColor = UIColor(hexString: parentColor).darken(byPercentage: percentChange)
            let cellcolor = cell.backgroundColor
            let cellTextColor = UIColor.init(contrastingBlackOrWhiteColorOn: cellcolor, isFlat: true)
            cell.textLabel?.textColor = cellTextColor
            cell.tintColor = cellTextColor
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

    func deleteToDo(todo: ToDo) {
        do {
            try realm.write {
                realm.delete(todo)
            }
        } catch {
            print("Error deleting \(error)")
        }
    }
    
    override func deleteRow(row: Int) {
        deleteToDo(todo: (itemResults?[row])!)
    }

}

