//
//  AlbumPopMenuView.swift
//  AlbumDemo
//
//  Created by fengying on 2023/4/4.
//

import UIKit
import Photos


class AlbumPopMenuView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    let reuseIdentifier = "AlbumMenuCell"
    
    var dataSource:[AlbumItem] = []
    var didSelectIndexPathBlock:DidSelectIndexPathBlock? = nil
    
    @IBOutlet weak var tableView: UITableView!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    
    func loadNib(){
        let bundle = Bundle.init(for: AlbumPopMenuView.self)
        let nib = UINib.init(nibName: "AlbumPopMenuView", bundle: bundle)
        if let instanceView = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            instanceView.frame = self.bounds
            self.addSubview(instanceView)
            
            self.tableView.register(UINib.init(nibName: reuseIdentifier, bundle: bundle), forCellReuseIdentifier: reuseIdentifier)
        }
    }
    
    
    
    //MARK: 展示菜单
    func updateDataSource(_ dataSource:[AlbumItem],didSelectIndexPath:DidSelectIndexPathBlock?){
        self.dataSource = dataSource
        self.didSelectIndexPathBlock = didSelectIndexPath
        self.tableView.reloadData()
    }
    
    
    //MARK: UITableViewDelegate,UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AlbumMenuCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! AlbumMenuCell
        
        
        let albumItem:AlbumItem = self.dataSource[indexPath.row]
        
        if albumItem.fetchResult.count > 0{
            let asset: PHAsset = albumItem.fetchResult.lastObject!
            AlbumsUtil.getImageWithAsset(asset, size: CGSize.init(width: 120, height: 120)) { image in
                cell.iconImageView.image = image
            }
        }
        else{
            cell.iconImageView.image = UIImage.init(named: "default_photo")
        }
        
        
        cell.nameLab.text = albumItem.title
        cell.countLab.text = albumItem.count
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectIndexPathBlock?(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    //    let cell: PhotoThumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoThumbnailCell
    //
    //    let photoModel = self.photoArray[indexPath.item]
    //    cell.selectedBtn.tag = indexPath.item
    //
    //    cell.selectedBtn.addTarget(self, action: #selector(selectedAction(_ :)), for: .touchUpInside)
    //
    //    cell.configCell(photoModel,assetThumbnailSize: self.assetThumbnailSize)
    //    return cell
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
