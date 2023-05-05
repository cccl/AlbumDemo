//
//  LayerExtendtion.swift
//  AlbumDemo
//
//  Created by fengying on 2023/3/31.
//

import UIKit

@IBDesignable
extension  CALayer{
    
    @IBInspectable var borderColorWithUIColor:UIColor{
        set {
            self.borderColor = newValue.cgColor
        }
        
        get {
            return UIColor(cgColor: self.borderColor!)
        }
    }
}
