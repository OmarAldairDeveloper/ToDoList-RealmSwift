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
import UserNotifications

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
            
            
            // Notificación: Contenido
            let center = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            content.title = "Test"
            content.body = "This is a test of local notifications"
            content.sound = UNNotificationSound.default
            content.threadIdentifier = "local-notifications temp"
            
            
            // Notificación: parámetros de la fecha y hora -> fecha
            let dateComponents = DateComponents(year: 2019, month: 03, day: 04, hour: 13, minute: 20)
            let date = Calendar.current.date(from: dateComponents)
            let comp2 = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute],from: date!)
            // Lanzador de la notificación
            let trigger = UNCalendarNotificationTrigger(dateMatching: comp2, repeats: false)
            
            // Ejecución de la notificación
            let request = UNNotificationRequest(identifier: "content", content: content, trigger: trigger)
            
            // Agregar al centro de notificaciones
            center.add(request, withCompletionHandler: { (error) in
                
                if error != nil{
                    print(error!)
                }
            })
            
            
            
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
            
            if let note = self.notes?[indexPath.row]{
                
                do{
                   
                    try self.realm.write {
                        self.realm.delete(note)
                        self.tableView.reloadData()
                    }
                }catch{
                    print("No se pudo eliminar la nota")
                }
                
            }
        }
        
        let editAction = SwipeAction(style: .default, title: "Editar") { (action, indexPath) in
            
            // Editar en Realm
            guard let note = self.notes?[indexPath.row] else { return }
            let alert = UIAlertController(title: "Editar la nota", message: "", preferredStyle: .alert)
            
            alert.addTextField{ (txtField) in
                txtField.text = note.title
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
                guard let newText = alert.textFields?.first?.text else { return }
                
                do{
                    
                    try self.realm.write {
                        
                        note.title = newText // Editar nota
                        self.tableView.reloadData()
                    }
                    
                }catch{
                    print("No se pudo editar la nota")
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
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


