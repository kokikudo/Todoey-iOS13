//
//  Item.swift
//  Todoey
//
//  Created by kudo koki on 2022/02/12.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var createdDate: Date?
    // 紐付け元のクラスとリンクさせる
    /*
     LinkingObjects(
        fromType: 紐付け元のクラスのデータタイプ。selfをつける
        property: 紐付け元のクラスで定義したプロパティ名
     )
     */
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
