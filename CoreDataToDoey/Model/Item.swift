//
//  Item.swift
//  CoreDataToDoey
//
//  Created by Rakesh Kumar on 18/09/24.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    @objc dynamic var dateInput: String = ""
    var parentCategory = LinkingObjects(fromType: Category.self, property: "item")
}
