//
//  ViewController.swift
//  Todoey
//
//  Created by mike oshea on 12/28/18.
//  Copyright © 2018 Future Trends. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray = [ToDo]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var defaults = UserDefaults.standard
    var category : Category? {
        didSet {
            loaditemsByCategory()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // print(dataFilePath)
        //loadItems(query: ToDo.fetchRequest())
        searchBar.delegate = self
        print("selected category",category?.name ?? "None")
    }

    func loadItems(query: NSFetchRequest<ToDo>) {
        do {
            itemArray = try context.fetch(query)
            tableView.reloadData()
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
    
    func loaditemsByCategory() {
        do {
            let query : NSFetchRequest<ToDo> = ToDo.fetchRequest()
            query.predicate = NSPredicate(format: "parentCategory.name MATCHES %@", category!.name!)
            itemArray = try context.fetch(query)
            tableView.reloadData()
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<ToDo> = ToDo.fetchRequest()
        let predicateSearch = NSPredicate(format: "text CONTAINS[cd] %@", searchBar.text!)
        let predicateCategory = NSPredicate(format: "parentCategory.name MATCHES %@", category!.name!)
        let fullPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:[predicateSearch,predicateCategory])
        request.predicate = fullPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
        loadItems(query: request)
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
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoitemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].text
        cell.accessoryType = itemArray[indexPath.row].done == false ? .none : .checkmark
        return cell
    }

    //MARK: - Tableview touch
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemArray[indexPath.row]
        item.done = !item.done
        tableView.cellForRow(at: indexPath)?.accessoryType = item.done == true ? .checkmark : .none
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        saveItems()
    }
    
    func saveItems() {
        do {
            try context.save()
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
                let item = ToDo(context: self.context)
                item.text = textField.text!
                item.done = false
                item.parentCategory = self.category
                self.itemArray.append(item)
                self.saveItems()
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

