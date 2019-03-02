//
//  ViewController.swift
//  NotesRealm
//
//  Created by Omar Aldair Romero Pérez on 3/1/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import UIKit
import RealmSwift

class NotesTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var notes : Results<Note>?
    
    
    var category : Category?{
        didSet{
            loadNotes()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func addNewNoteAction(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Agregar nueva nota", message: "", preferredStyle: .alert)
        
        alert.addTextField { (txtField) in
            txtField.placeholder = "Agrega tu nota"
        }
        
        alert.addAction(UIAlertAction(title: "Crear", style: .default, handler: { (action) in
            
            guard let text = alert.textFields?.first?.text else { return }
            
            let note = Note()
            note.title = text
            note.check = false
            self.persistNotes(note)
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        present(alert, animated: true)
        
    }
    
    
    func persistNotes(_ note: Note){
        
        do{
            
            try realm.write {
                self.category?.notes.append(note) // Agregar nota a la categoría
                realm.add(note) // Agregar nota a la base de datos
                tableView.reloadData()
            }
            
        }catch{
            print("No se pudo guardar la nota")
        }
    }
    
    
    func loadNotes(){
        
        
        self.notes = category?.notes.sorted(byKeyPath: "title")
    }
    
    

    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notes?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        
        if let note = notes?[indexPath.row]{
            
            cell.textLabel?.text = note.title
        }
        
        return cell
        
        
    }

}
