//
//  Category.swift
//  NotesRealm
//
//  Created by Omar Aldair Romero Pérez on 3/1/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object{
    
    @objc dynamic var title: String = ""
    @objc dynamic var color: UIColor?
    @objc dynamic var image: Data?
    
    // Relación de que la categoría tiene muchas notas
    let notes = List<Note>()
}
