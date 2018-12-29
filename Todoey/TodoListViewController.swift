//
//  ViewController.swift
//  Todoey
//
//  Created by mike oshea on 12/28/18.
//  Copyright © 2018 Future Trends. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [
        ToDo(text: "Read Book", done: false),
        ToDo(text: "Destroy Monster", done: false),
    ]

    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataFilePath)
        // Do any additional setup after loading the view, typically from a nib.
        loadItems()
        
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([ToDo].self, from: data)
            } catch {
                
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
        //print(indexPath.row, itemArray[indexPath.row])
        let item = itemArray[indexPath.row]
        item.done = !item.done
        tableView.cellForRow(at: indexPath)?.accessoryType = item.done == true ? .checkmark : .none
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        saveItems()
    }
    
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding: \(error)")
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
                let item = ToDo(text: textField.text!, done: false)
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

