//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [
        Item(title: "Find Mile"),
        Item(title: "Buy Eggos"),
        Item(title: "Destory Demogorogon")
    ]

    // 保存場所のファイルパス
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")

    override func viewDidLoad() {
        super.viewDidLoad()

        loadItems() // 画面読み込み時にデータをロード
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)

        let item = itemArray[indexPath.row]

        cell.textLabel?.text = item.title

        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        saveItems() // 保存
    }


    // チェックマーク更新時とItem追加時にデータを保存
    func saveItems() {
        // エンコーダーの生成
        let encoder = PropertyListEncoder()

        // データをエンコードしてローカルファイルに保存
        do {
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Encode Error: \(error)")
        }

        self.tableView.reloadData()
    }

    // 保存したデータを読み込み
    func loadItems() {

        // まずはデータがパスにあるか確認
        if let data = try? Data(contentsOf: dataFilePath!) {

            // デコーダー生成
            let decoder = PropertyListDecoder()

            // デコード
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                    print("Decode Error: \(error)")
            }

        }
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "AddItem", style: .default) { action in

            if let inputedText = textField.text {
                self.itemArray.append(Item(title: inputedText))

                self.saveItems() // 保存
            }


        }

        alert.addTextField { (alerTextField) in
            alerTextField.placeholder = "Create new item"
            textField = alerTextField

        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


