//
//  AddNewCategoryViewController.swift
//  NotesRealm
//
//  Created by Omar Aldair Romero Pérez on 3/1/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import UIKit
import RealmSwift

class AddNewCategoryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageCategory: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var sliders: [UISlider]!
    
    var color: String = ""
    
    let imagePicker = UIImagePickerController()
    
    let realm = try! Realm()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        repaintBackground()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showImagePicker))
        self.imageCategory.addGestureRecognizer(tapGesture)
        
        
        self.imagePicker.delegate = self
    }
    
    
    @objc func showImagePicker(){
        self.imagePicker.allowsEditing = false
        
        let alert = UIAlertController(title: "Selecciona una opción", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cámara", style: .default, handler: { (action) in
            
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Librería de fotos", style: .default, handler: { (action) in
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.present(self.imagePicker, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Álbumes", style: .default, handler: { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    
    // MARK: Actions
    @IBAction func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
   
    
    @IBAction func saveCategoryAction(_ sender: UIButton) {
        
        guard let text = self.textField.text else { return }
        
        let category = Category()
        category.title = text
        category.color = UIColor(hex: color)?.toHex
        category.image = self.imageCategory.image?.pngData()
        
        
        do{
            try self.realm.write {
                realm.add(category)
                
                
            }
        }catch{
            print("No se pudo guardar en la base de datos \(error.localizedDescription)")
        }
        
        dismiss(animated: true, completion: nil)
        
    
    }
    
    
    @IBAction func sliderValueAction(_ sender: UISlider) {
        
         self.labels[sender.tag].text = "\(lroundf(sender.value*255))"
        repaintBackground()
        
    }
    
    
    func repaintBackground(){
        
        let colorBack = UIColor(red: CGFloat(sliders[0].value), green: CGFloat(sliders[1].value), blue: CGFloat(sliders[2].value), alpha: CGFloat(sliders[3].value))
        
        self.view.backgroundColor = colorBack
        self.color = colorBack.toHex!
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imagePicker = info[.originalImage] as? UIImage{
            
            self.imageCategory.contentMode = .scaleAspectFit
            self.imageCategory.image = imagePicker
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
   
    



}

