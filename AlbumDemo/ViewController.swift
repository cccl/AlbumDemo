//
//  ViewController.swift
//  AlbumDemo
//
//  Created by fengying on 2023/3/28.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func albumAction(_ sender: Any) {
        let ctr = AlbumListViewController.init(nibName: "AlbumListViewController", bundle: nil)
        ctr.completeBlock = { [weak self] selectedPhotos in
            
            print("selectedPhotos:",selectedPhotos)
            
            if selectedPhotos.count > 0 {
                let photoModel = selectedPhotos.first
                photoModel?.getImageWithAsset(size: CGSize.init(width: 400, height: 400)) { [weak self] image in
                    self?.imageView.image = image
                }
            }
        }
        
        let nav = UINavigationController.init(rootViewController: ctr)
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
}

