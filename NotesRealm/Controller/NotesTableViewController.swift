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
    
    
    var datePicker:UIDatePicker = UIDatePicker()
    let toolBar = UIToolbar()
    
   

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func doDatePicker(){
        // DatePicker
        // datePicker = UIDatePicker()
        
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: self.view.frame.size.height - 220, width:self.view.frame.size.width, height: 216)) // Acomodar el datePicker hasta abajo
        self.datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .dateAndTime
        
        /* ToolBar
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        self.toolBar.isHidden = false*/
        
    }
    
    
    /*@objc func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        
        datePicker.isHidden = true
        self.toolBar.isHidden = true
    }
    
    @objc func cancelClick() {
        datePicker.isHidden = true
        self.toolBar.isHidden = true
    }*/
    
    
    @IBAction func addNewNoteAction(_ sender: UIBarButtonItem) {
        
        
        
        let alert = UIAlertController(title: "Agregar nueva nota", message: "", preferredStyle: .alert)
        
        alert.addTextField { (txtField) in
            txtField.placeholder = "Agrega tu nota"
            self.doDatePicker() // Inicializar el datePicker cuando vayamos a escribir la nota
            txtField.inputView = self.datePicker // Mostrar el datePicker
            //txtField.inputAccessoryView = self.toolBar
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
            content.title = "Recordatorio"
            content.body = note.title
            content.sound = UNNotificationSound.default
            content.threadIdentifier = "local-notifications temp"
            
            
            // Notificación: parámetros de la fecha y hora -> fecha
            /*let dateComponents = DateComponents(year: 2019, month: 03, day: 04, hour: 13, minute: 20)
            let date = Calendar.current.date(from: dateComponents)
            let comp2 = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute],from: date!)*/
            
            
            let date = self.datePicker.date // Obtener fecha del DatePicker
            
            let components = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: date) // Crear componentes
            
            
            // Lanzador de la notificación
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            
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


