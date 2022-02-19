//
//  CategoryViewController.swift
//  Todoey
//
//  Created by kudo koki on 2022/02/08.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>?
    
    // MARK: - ビュー表示
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()
    }
    
    // MARK: - TableView デリゲードメソッド
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Category Added"
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].colourValue ?? "00D6FF")

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    // MARK: - TodoListページへ移動
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
        
    }
    
    // MARK: - 追加ボタン
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            
            if let inputedText = textField.text {
                
                let newCategory = Category()
                newCategory.name = inputedText
                newCategory.colourValue = UIColor.randomFlat().hexValue()
                self.save(category: newCategory)
            }
            
        }
        
        alert.addTextField { alerTextField in
            alerTextField.placeholder = "Create new category"
            textField = alerTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - データ保存
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
            
        } catch {
            print("Error saving context: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - データロード
    func loadCategory() {
        
        categories = realm.objects(Category.self)
        
        self.tableView.reloadData()
    }
    
    // MARK: - データ削除
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
            } catch {
                print("Error delete category: \(error)")
            }
        }
    }
    
}
