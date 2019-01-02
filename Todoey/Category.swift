//
//  Category.swift
//  Todoey
//
//  Created by mike oshea on 12/29/18.
//  Copyright © 2018 Future Trends. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var backGroundColor = "#FFFFFF"
    let todos = List<ToDo>()
}
