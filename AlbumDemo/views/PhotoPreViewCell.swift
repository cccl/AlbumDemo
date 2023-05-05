//
//  PhotoPreViewCell.swift
//  AlbumDemo
//
//  Created by fengying on 2023/3/30.
//

import UIKit
import Photos

class PhotoPreViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var photoModel:PhotoModel!
    
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
