//
//  ItemViewController.swift
//  ToDoList
//
//  Created by Shawn on 21/08/2018.
//  Copyright © 2018 Shawn. All rights reserved.
//

import Foundation
import RealmSwift
import ChameleonFramework


class ItemViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let colorHex = selectedCategory?.cellColor else{fatalError("Navigation controller error")}
        
        updateNavBarColor(colorHexCode: colorHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBarColor(colorHexCode: "FF7E79")
        
    }
    
    func updateNavBarColor (colorHexCode: String){
        
        title = selectedCategory?.name
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError("Navigation controller error")}
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller error")}
        
        //Navigation bar background color
        navBar.barTintColor = navBarColor
        
        //SearchBar color
        searchBar.barTintColor = navBarColor
        
        //Title color
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        
        //Tint color
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
    }
    
    //MARK:- TableView Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let items = todoItems?[indexPath.row]{
            
            cell.textLabel?.text = items.title
            
            
            if let color = UIColor(hexString: selectedCategory!.cellColor)?.darken(byPercentage:CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
                    cell.backgroundColor = color
                    cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                }
            
            cell.accessoryType = items.done ? .checkmark : .none
        }
        else{
            
            cell.textLabel?.text = "No Items Added"
            
        }
        
        return cell
        
    }
    
    //MARK:- TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let items = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    items.done = !items.done
                }
            }catch{
                print("Error when selecting items, \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK:- Add New Items
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory{
                do {
                    
                    try self.realm.write {
                        
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                        
                    }
                } catch{
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
            
        }
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Data Manipulation Methods
    func save(item: Item){
        do{
            try realm.write {
                realm.add(item)
            }
        }catch{
            print("Error when saving, \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Delete Data Method
    override func updateDataModel(at indexPath: IndexPath) {
        
        if let itemsToBeDeleted = self.todoItems?[indexPath.row]{
            do{
                try realm.write {
                    realm.delete(itemsToBeDeleted)
                }
            } catch{
                print("Error when deleting item, \(error)")
            }
        }
        
    }
    
    func loadItems(){
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
        
    }
    
}



//MARK:- SearchBar Methods

extension ItemViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("SearchBar1")
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("SearchBar3")
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

