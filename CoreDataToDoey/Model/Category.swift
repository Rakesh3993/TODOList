//
//  Category.swift
//  CoreDataToDoey
//
//  Created by Rakesh Kumar on 19/09/24.
//

import Foundation
import RealmSwift


class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var dateInput: String = ""
    @objc dynamic var colour: String = ""
    let item = List<Item>()
}
