//
//  CategoryViewController.swift
//  Todoey
//
//  Created by kudo koki on 2022/02/08.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

// 検索機能がないこと、セルをタップしたらそのCategoryをAttributeに設定してあるItemに絞って表示すること
// それ以外はTodoListViewControllerと一緒

class CategoryViewController: UITableViewController {

    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        cell.textLabel?.text = categories[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // segueを指定し画面遷移
        performSegue(withIdentifier: "goToItems", sender: self)

    }

    // 遷移前に実行。TodoListViewControllerのプロパティ<selectedCategory>に値をセット
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // 遷移先であるTodoListViewControllerを定義
        let destinationVC = segue.destination as! TodoListViewController

        // tableViewのプロパティ<indexPathForSelectedRow>で選択したセルのインデックスを取得できる
        // nilチェックをしてTodoListViewControllerのプロパティ<selectedCategory>にタップしたセルのCategoryをセット
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }

    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Category", style: .default) { action in

            if let inputedText = textField.text {

                let newCategory = Category(context: self.context)
                newCategory.name = inputedText

                self.categories.append(newCategory)

                self.saveCategory()
            }

        }

        alert.addTextField { (alerTextField) in
            alerTextField.placeholder = "Create new category"
            textField = alerTextField
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }

    func saveCategory() {
        do {
            try context.save()

        } catch {
            print("Error saving context: \(error)")
        }

        self.tableView.reloadData()
    }

    func loadCategory() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }

        self.tableView.reloadData()
    }


}
