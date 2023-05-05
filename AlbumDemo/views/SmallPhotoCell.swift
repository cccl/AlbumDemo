//
//  SmallPhotoCell.swift
//  AlbumDemo
//
//  Created by fengying on 2023/4/2.
//

import UIKit
import Photos

class SmallPhotoCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    var photoModel:PhotoModel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configCell(_ photoModel:PhotoModel,assetThumbnailSize:CGSize){
        self.photoModel = photoModel
        photoModel.getImageWithAsset(size: assetThumbnailSize) { image in
            self.imageView.image = image
        }
        
    }

}
