# AlbumDemo
相册、仿扫描全能王相册效果
更换UI可直接使用、也可二次开发

1、添加权限
         <key>NSPhotoLibraryUsageDescription</key>
	       <string>我们将使用相册功能</string>

2、使用
        
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
        
        
        
 selectedPhotos为选中的图片数组
 
 
 3、开源不易，多多支持
 ![图片](https://user-images.githubusercontent.com/4113652/236538034-8cb55cef-9b6a-4ff6-b9d0-68c1b67c7007.png)

 
 
 




