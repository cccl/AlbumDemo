//
//  PhotoThumbnailCell.swift
//  AlbumDemo
//
//  Created by fengying on 2023/3/29.
//

import UIKit
import Photos

class PhotoThumbnailCell: UICollectionViewCell {
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var photoModel:PhotoModel!
    @IBOutlet weak var selectedLab: UILabel!
    
    @IBOutlet weak var selectedBtn: UIButton!
    
    @IBOutlet weak var iconViewWCst: NSLayoutConstraint!
    
    let iconViewW:CGFloat = 22
    
    var isChoosen:Bool = false
    
    let aniTimeInterval:TimeInterval = 0.4
    
    var animated:Bool = true
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configCell(_ photoModel:PhotoModel,
                    assetThumbnailSize:CGSize){
        self.photoModel = photoModel
        self.setSelectedState(photoModel.selected)
        photoModel.getImageWithAsset(size: assetThumbnailSize) { image in
            self.setThumbnailImage(image)
        }
    }
    
    
    func setSelectedState(_ selected:Bool){
        self.alphaView.isHidden = !selected
        
        
        if selected {
            self.selectedLab.layer.borderColorWithUIColor = UIColor.init(red: 31.0/255, green: 176.0/255, blue: 153.0/255, alpha: 1.0)
            self.selectedLab.backgroundColor = UIColor.init(red: 31.0/255, green: 176.0/255, blue: 153.0/255, alpha: 1.0)
            
            if self.photoModel.animated {
                UIView.animate(withDuration: 0.01, delay: 0, options: .curveEaseInOut) {
                    self.selectedLab.setScale(0.1, y: 0.1)
                } completion: { finished in
                    UIView.animate(withDuration: self.aniTimeInterval, delay: 0, options: .curveEaseInOut) {
                        self.selectedLab.setScale(1.2, y: 1.2)
                    } completion: { finished in
                        self.photoModel.animated = false
                    }
                }
            }
            else{
                self.selectedLab.setScale(1.2, y: 1.2)
            }
            
            self.selectedLab.text =  self.photoModel.orderTag > 0 ? String( self.photoModel.orderTag) : ""
            
        }
        else{
            UIView.animate(withDuration: self.aniTimeInterval, delay: 0, options: .curveEaseInOut) {
                self.selectedLab.setScale(1.0, y: 1.0)
            } completion: { finished in
                self.photoModel.animated = true
            }
            self.selectedLab.setScale(1.0, y: 1.0)
            self.selectedLab.layer.borderColorWithUIColor = UIColor.white
            self.selectedLab.text = ""
            self.selectedLab.backgroundColor = UIColor.clear
        }
        
        self.isChoosen = selected
    }
    
    
    
    func setThumbnailImage(_ thumbnailImage: UIImage){
        self.imageView.image = thumbnailImage
    }
    
    
}
