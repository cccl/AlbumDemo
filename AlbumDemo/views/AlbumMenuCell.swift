//
//  AlbumMenuCell.swift
//  AlbumDemo
//
//  Created by fengying on 2023/4/4.
//

import UIKit

class AlbumMenuCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var countLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
