//
//  ToDo.swift
//  Todoey
//
//  Created by mike oshea on 12/29/18.
//  Copyright © 2018 Future Trends. All rights reserved.
//

import Foundation
import RealmSwift

class ToDo: Object {
    @objc dynamic var text : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var created : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "todos")
}
