//
//  ViewController.swift
//  NotesRealm
//
//  Created by Omar Aldair Romero Pérez on 3/1/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class NotesTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
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
        self.tableView.reloadData()
    }
    
    

    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notes?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        if let note = notes?[indexPath.row]{
            
            cell.textLabel?.text = note.title
            
            if note.check{
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
            
        }
        

        return cell
        
        
    }
    
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let note = notes?[indexPath.row]{
            
            do{
                try realm.write {
                    note.check = !note.check // Cambiar el estado de la nota
                }
            }catch{
                print("No se pudo guardar el estado de la nota")
            }
            
            tableView.cellForRow(at: indexPath)?.accessoryType = (note.check ? .checkmark : .none)
            
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    // MARK: SwipeTableViewCellDelegate
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Eliminar") { action, indexPath in
            
            // Eliminar de realm
            print("Queremos eliminar")
        }
        
        let editAction = SwipeAction(style: .default, title: "Editar") { (action, indexPath) in
            
            print("Queremos editar")
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        editAction.image = UIImage(named: "edit")
        editAction.backgroundColor = UIColor(red: CGFloat(253)/255, green: CGFloat(182)/255, blue: 0, alpha: 1.0)
        
        return [deleteAction, editAction]
    }

}

extension NotesTableViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Buscar al dar click
        
        guard let text = searchBar.text else { return }
        
        notes = category?.notes.filter(NSPredicate(format: "title CONTAINS[cd] %@", text)).sorted(byKeyPath: "title", ascending: true) // Hacer consulta filtrada
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadNotes() // Cargar todas, no las filtradas
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() // Ya que es un trabajo de la vista, por eso lo trabajamos en el hilo principal
            }
            
        }
    }
    
}


