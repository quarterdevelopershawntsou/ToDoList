//
//  Category.swift
//  ToDoList
//
//  Created by Shawn on 21/08/2018.
//  Copyright © 2018 Shawn. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    
    @objc dynamic var cellColor: String = ""
    
    let items = List<Item>()
    
}
