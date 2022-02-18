//
//  CategoryViewController.swift
//  Todoey
//
//  Created by kudo koki on 2022/02/08.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm() // Realm初期化

    // 自動更新してくれるResultsクラス
    // CoreDataの時のように配列に追加するような処理はいらない
    var categories: Results<Category>?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // 継承元のCell生成メソッドを実行しCellを取得
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Category Added"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: "goToItems", sender: self)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let destinationVC = segue.destination as! TodoListViewController

        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }

    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Category", style: .default) { action in

            if let inputedText = textField.text {

                let newCategory = Category()
                newCategory.name = inputedText

                self.save(category: newCategory) // Categoryを渡して保存
            }

        }

        alert.addTextField { alerTextField in
            alerTextField.placeholder = "Create new category"
            textField = alerTextField
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }

    func save(category: Category) {
        do {
            // 保存
            try realm.write {
                realm.add(category)
            }

        } catch {
            print("Error saving context: \(error)")
        }

        self.tableView.reloadData()
    }

    func loadCategory() {

        // Realmからデータを取得し変数にセット
        // realm.objects(欲しいデータのタイプ。selfをつけるだけでいい)
        categories = realm.objects(Category.self)

        self.tableView.reloadData()
    }

    // 親クラスで定義したupdateModelの処理内容をこのクラスで実装する
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
