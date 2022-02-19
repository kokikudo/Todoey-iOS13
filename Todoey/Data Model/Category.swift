//
//  Category.swift
//  Todoey
//
//  Created by kudo koki on 2022/02/12.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colourValue: String = ""
    // Itemクラスの配列を準備
    let items = List<Item>()
}
