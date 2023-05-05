//
//  SheetMenuCell.swift
//  AlbumDemo
//
//  Created by fengying on 2023/4/19.
//

import UIKit

@IBDesignable
class SheetMenuCell: UICollectionViewCell {
    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var selectedView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
