//
//  Extensions.swift
//  NotesRealm
//
//  Created by Omar Aldair Romero Pérez on 3/3/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import Foundation
import UIKit


extension UIColor{
  
    // MARK: Initicialización de conveniencia
    convenience init?(hex: String) {
        
        // Saltarse los caracteres en blanco u otros más
        var hexNormalized = hex.trimmingCharacters(in: .whitespaces)
        
        // Quitar el hasthtag del inicio porque es un hexadecimal
        hexNormalized = hexNormalized.replacingOccurrences(of: "#", with: "")
        
        
        // Variables de RGBA
        var rgb: UInt32 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0 // Transparencia
        let length = hexNormalized.count // Si son 6 caracteres construyo un rgb, si son 8 construyo un rgba
        
        // Que el string se ha parseado a una Int32 y se ha guardado en la variable "rgb"
        Scanner(string: hexNormalized).scanHexInt32(&rgb)
        if length == 6{
            r = CGFloat((rgb & 0xFF0000)>>16)/255.0 // obtener el valor de r entre 0 y 1
            g = CGFloat((rgb & 0x00FF00)>>8)/255.0
            b = CGFloat((rgb & 0x0000FF))/255.0
        }else if length == 8{
            r = CGFloat((rgb & 0xFF000000)>>24)/255.0 // obtener el valor de r entre 0 y 1
            g = CGFloat((rgb & 0x00FF0000)>>16)/255.0
            b = CGFloat((rgb & 0x0000FF00)>>8)/255.0
            a = CGFloat((rgb & 0x000000FF))/255.0
        }else{
            return nil
        }
        
        // Inicializado un color a partir de los valores
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    var toHex: String?{
        guard let components = cgColor.components, components.count >= 3 else { return nil }
        
        // Van de 0 a 1
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        // Creamos el hexString (string con color hexadecimal). formateador de string a través de una expresión regular
        let hex = String(format: "%02lX%02lX%02lX%02lX", lroundf(r*255), lroundf(g*255), lroundf(b*255), lroundf(a*255))
        
        
        return hex
        
    }
    
}
