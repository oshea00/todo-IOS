//
//  CategoryViewController.swift
//  Todoey
//
//  Created by mike oshea on 12/29/18.
//  Copyright © 2018 Future Trends. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.separatorStyle = .none
    }

    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            if category.backGroundColor == "#FFFFFF" {
                let backgroundColor = UIColor.randomFlat()!
                cell.backgroundColor = backgroundColor
                do {
                    try realm.write {
                        category.backGroundColor = backgroundColor.hexValue()
                    }
                } catch {
                    print("Error updating background color on category")
                }
            } else {
                cell.backgroundColor = UIColor(hexString: category.backGroundColor)
            }
            cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: cell.backgroundColor, isFlat: true)
        } else {
            cell.textLabel?.text = "No Category Added"
        }
        
        return cell
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // What will happen once user clicks the add item button
            if (textField.text! != "") {
                let category = Category()
                category.name = textField.text!
                self.save(category: category)
            }
        }
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "New Category"
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let vc = segue.destination as! TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.category = categories?[indexPath.row]
            }
            
        }
    }

    //MARK: Data Manipulation
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving \(error)")
        }
        tableView.reloadData()
    }
    
    func deleteCategory(category: Category) {
        do {
            try realm.write {
                realm.delete(category)
            }
        } catch {
            print("Error deleting \(error)")
        }
    }
    
    override func deleteRow(row: Int) {
        deleteCategory(category: (categories?[row])!)
    }
}

