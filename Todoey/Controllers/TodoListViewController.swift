import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController {

    let realm = try! Realm() // Realm初期化
    var items: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems() // 更新されるたびにロードする
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title

            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Item Added"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status: \(error)")
            }
        }
        self.tableView.reloadData()
    }

    //SwipeKitを使わない場合のセル削除機能実装コード
    //UITableViewCellのメソッドに既にあるが、細かいカスタマイズをしたい場合はSwipeKitの方が良さげ
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //
    //        if let item = items?[indexPath.row] {
    //            do {
    //                try realm.write {
    //                    realm.delete(item)
    //                }
    //            } catch {
    //                print("Error delete item: \(error)")
    //            }
    //        }
    //        self.tableView.reloadData()
    //    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "AddItem", style: .default) { action in

            if !textField.text!.isEmpty {
                // 項目を追加する処理
                // selectedCategoryをアンラップ
                if let currentCategory = self.selectedCategory {
                    do {
                        // 追加する処理をrealm.write関数のコードブロック内に書くことで値の更新ができる
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.createdDate = Date()
                            currentCategory.items.append(newItem)
                        }

                    } catch {
                        print("Error adding NewItem: \(error)")
                    }
                }

                self.tableView.reloadData()
            }
        }

        alert.addTextField { (alerTextField) in
            alerTextField.placeholder = "Create new item"
            textField = alerTextField

        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }

    func saveItems(item: Item) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("コンテキストへの保存時にエラー発生: \(error)")
        }

        self.tableView.reloadData()
    }

    func loadItems() {

        // キーパス（Itemのtitle）とソート順を指定してデータを取得
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }

    override func updateModel(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error delete item: \(error)")
            }
        }
    }
}


// 検索機能追加
extension TodoListViewController: UISearchBarDelegate {

    // 検索機能を定義するデリゲートメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // titleで検索し追加日でソート
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createdDate", ascending: true)

        tableView.reloadData()
    }

    // 入力テキストが無い時に全てのデータを表示させる
    // バー右端のキャンセルボタンを押したときと、キーボードでテキストを削除した時に実行される
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {


        if searchText.isEmpty {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
