//
//  Note.swift
//  NotesRealm
//
//  Created by Omar Aldair Romero Pérez on 3/1/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import Foundation
import RealmSwift


class Note : Object{
    
    @objc dynamic var title: String = ""
    @objc dynamic var check : Bool = false
    @objc dynamic var notificationID : String = ""
    
    // Indicar la relación de que las notas pertenecen a una sóla categoría
    var parentCategory = LinkingObjects(fromType: Category.self, property: "notes")
}
