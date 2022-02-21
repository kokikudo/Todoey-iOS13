//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by kudo koki on 2022/02/18.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework
// CategoryViewControllerとTodoListViewController両方に共通する機能を定義したクラス。このクラスを継承して二つのViewControllerを定義する
class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0 // セルの高さ
        tableView.backgroundColor = FlatWhite() // 背景色

    }
    
    // Cellを生成
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //　ストーリーボードで継承先のCellのIdentifierを"Cell"にする
        //　また、CustomClassのClassをSwipeTableViewCell,ModuleをSwipeCellKitに指定しておかないとキャストエラーになる
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self


        
        return cell
    }
    
    //SwipeTableViewCellDelegateのメソッド
    //スワイプの方向やアイコン、処理内容などを定義
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            //モデルデータの更新実行
            self.updateModel(at: indexPath)
        }
        
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    //スワイプの挙動を定義
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    // スワイプした時のモデル更新作業を子クラスで定義する
    func updateModel(at indexPath: IndexPath) {
    }
}
