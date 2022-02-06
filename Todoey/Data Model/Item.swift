//
//  Item.swift
//  Todoey
//
//  Created by kudo koki on 2022/02/06.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation

class Item {
    let title: String
    var done: Bool

    init(title: String, done: Bool = false) {
        self.title = title
        self.done = done
    }
}
