//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    // 表示するコンテンツ
    var itemArray = [
        Item(title: "Find Mile"),
        Item(title: "Buy Eggos"),
        Item(title: "Destory Demogorogon")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
}

    // 表示するセルの数。基本的にコンテンツが入ってるリストの数を返す。
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    // cellを生成
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // 再利用可能なセル
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)

        // セルに組み込むコンテンツ
        let item = itemArray[indexPath.row]

        // セルのタイトル
        cell.textLabel?.text = item.title

        // doneプロパティの値からセルにチェックマークをつけるか判断
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }

    // セルをタップした時の処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // doneのBool値をスイッチ
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        tableView.reloadData() // リロード

        // 選択したことがわかるようにハイライト
        //tableView.deselectRow(at: indexPath, animated: true)
    }

    // 追加ボタン
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        //入力したテキストを保持するプロパティ
        var textField = UITextField()

        //UIAlertController作成
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        //項目
        let action = UIAlertAction(title: "AddItem", style: .default) { action in

            // 保持したテキストをリストに追加
            if let inputedText = textField.text {
                self.itemArray.append(Item(title: inputedText))

                // リロード
                self.tableView.reloadData()
            }


        }

        // アラートにTextField追加
        alert.addTextField { (alerTextField) in
            alerTextField.placeholder = "Create new item"
            textField = alerTextField // 入力したテキストを保持

        }

        //アラートに項目を追加
        alert.addAction(action)

        //アラートを表示
        present(alert, animated: true, completion: nil)
    }
}


