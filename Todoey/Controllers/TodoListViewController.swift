import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()

    // コンテキストを取得
    // Appdelegateクラスから直接呼び出すのではなく、UIApplicationのシングルトンsharedにdelegateプロパティがあるのでそれをキャストしてコンテキストを呼び出す。
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // 保存したデータがあるフォルダのパスを確認
        print(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask))

        loadItems()
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

        // 項目を削除
        // 先にDBから削除しないとインデックスレンジエラーになる
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)

        saveItems()

    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "AddItem", style: .default) { action in

            if let inputedText = textField.text {

                // コンテキストにItemデータを作成
                let newItem = Item(context: self.context)
                newItem.title = inputedText
                newItem.done = false

                self.itemArray.append(newItem)

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

    func saveItems() {
        do {
            try context.save() // コンテキストの内容を保存
        } catch {
            print("コンテキストへの保存時にエラー発生: \(error)")
        }

        self.tableView.reloadData()
    }


    // リクエストをもとにDBからデータを取得
    // 引数のwithキーワードを使うと関数呼び出し時に引数がwithになり直感的に把握しやすくなる
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {

        do {
            // contextからデータ取得をリクエスト
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
}


// 検索機能追加
extension TodoListViewController: UISearchBarDelegate {

    // 検索機能を定義するデリゲートメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // NSFetchRequestクラスを生成し、そのプロパティに検索条件を指定する個別のNSクラスを定義する

        // リクエスト
        let request: NSFetchRequest<Item> = Item.fetchRequest()


        // フィルター
        // NSPredicate(format: <検索条件の文字列>, <検索条件の中にある"@"に代入される値>)
        // 検索条件の設定方法は動画のURLから飛べるページを参考にする
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

        // ソート
        // [NSSortDescriptor(key: ソート対象のデータ名, ascending: trueなら昇順)]
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        // withキーワードのおかげで(request: request)のように変数名が被らないので見やすい
        loadItems(with: request)

        tableView.reloadData()
    }

    // 入力テキストが無い時に全てのデータを表示させる
    // バー右端のキャンセルボタンを押したときと、キーボードでテキストを削除した時に実行される
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {


        if searchText.isEmpty {
            loadItems()

            tableView.reloadData()

            // キーボードを下げる
            // UIの変更はメインスレッドで行う
            // 元々メインスレッドで行っている処理のはずだが、DispatchQueueで移動しないと検索バーの×ボタンを押した時にキーボードが閉じなくなる
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
