import UIKit
import RealmSwift
import ChameleonFramework

//TODO: カテゴリのリストの左側だけに丸みをつけたい
//TODO: カテゴリのリストの下側にマージンを入れたい

class TodoListViewController: SwipeTableViewController, UINavigationBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    var items: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    // MARK: - ライフサイクルメソッド
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none // セパレート無し
    }

    // ビュー表示後（viewDidLoad実行後）に実行される
    // viewDidLoadでナビゲーションの設定をいじろうとするとナビゲーションスタックに入る前に実行されてしまいエラーになる
    override func viewWillAppear(_ animated: Bool) {

        // ナビゲーションのタイトルをカテゴリ名にする
        title = selectedCategory!.name

        // ナビゲーションカラーを設定
        if let colourHex = selectedCategory?.colourValue {
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist"
            )}

            // UIColor(hexString:)の返り値はOptional型なのでアンラップする
            if let navBarColour = UIColor(hexString: colourHex) {

                let contrastColor = ContrastColorOf(navBarColour, returnFlat: true)
                navBar.subviews[0].backgroundColor = navBarColour
                navBar.backgroundColor = navBarColour
                navBar.tintColor = contrastColor
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor]

                // ios13以降の検索バーの色の変更は以下の通りになったらしい
                searchBar.barTintColor = navBarColour
                searchBar.searchTextField.backgroundColor = FlatWhite()
                //searchBar.backgroundImage = UIImage()
            }
        }
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title

            // リストの背景色とテキストの色を設定
            if let colour = UIColor(hexString: selectedCategory!.colourValue)?.darken(byPercentage:
                                                CGFloat(indexPath.row) / CGFloat(items!.count)
            ) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
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

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "AddItem", style: .default) { action in

            if !textField.text!.isEmpty {

                if let currentCategory = self.selectedCategory {
                    do {
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


extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createdDate", ascending: true)

        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {


        if searchText.isEmpty {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
