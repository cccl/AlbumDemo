//
//  ViewExtendtion.swift
//  AlbumDemo
//
//  Created by fengying on 2023/4/6.
//

import UIKit
import Foundation

extension UIImageView{
    
    //MARK: image和highlightImage之间动画切换
    func rotateImageView(_ isHighlighted:Bool) {
        let isHighlighted = isHighlighted
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            let radians = CGFloat(Double.pi)
            self.transform = CGAffineTransform(rotationAngle: radians)
        } completion: { finished in
            self.isHighlighted =  isHighlighted
            self.transform = .identity
        }
    }
}


extension UIImage{
    
    static func imageWithColor(_ color:UIColor,size:CGSize) -> UIImage? {
        var resultImage: UIImage? = nil
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
}


extension UIView{
    func setScale(_ x:CGFloat,y:CGFloat){
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -1000.0
        transform = CATransform3DScale(transform, x, y, 1)
        self.layer.transform = transform
        
    }
}
