//
//  ToDo.swift
//  Todoey
//
//  Created by mike oshea on 12/29/18.
//  Copyright © 2018 Future Trends. All rights reserved.
//

import Foundation

class ToDo : Codable {
    var text = ""
    var done = false
    
    init(text: String, done: Bool) {
        self.text = text
        self.done = done
    }
}
