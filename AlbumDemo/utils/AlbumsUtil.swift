//
//  AlbumAuthUtil.swift
//  AlbumDemo
//
//  Created by fengying on 2023/3/28.
//

import UIKit
import Photos



typealias DidSelectPhotosBlock = (_ selectedPhotos:[PhotoModel]) -> ()

typealias CompleteBlock = (_ photos:[PhotoModel],_ selectedPhotos:[PhotoModel],_ dismiss:Bool) -> ()

typealias DidSelectIndexPathBlock = (_ indexPath:IndexPath) -> ()



class AlbumsUtil: NSObject {
    
    //MARK: 相册授权
    static func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void)->Void{
        let status:PHAuthorizationStatus  = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            //未确定,发起申请
            PHPhotoLibrary.requestAuthorization({ (status) in
                handler(status)
            })
            break
        case .restricted:
            //限制授权
            handler(status)
            break
        case .denied:
            //已拒绝
            handler(status)
            break
        case .authorized:
            //已授权
            handler(status)
            break
        case .limited:
            //受限制相册授权
            handler(status)
            break
        default:
            break
            
        }
        print("PHAuthorizationStatus:",status.rawValue)
    }
    
    
    //MARK: 获取图片
    static func getImageWithAsset(_ asset: PHAsset, size targetSize: CGSize, finishedCallack: @escaping (_ image: UIImage) -> ()) {
        let options = PHImageRequestOptions()
        options.resizeMode = .exact // 返回图像与目标size保持一致
        options.deliveryMode = .highQualityFormat   // 只返回高像素的图像
        var size = targetSize
        
        // 如果没有目标大小，则返回原图
        if targetSize == .zero {
            size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        }
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .default, options: options) { (image, info) in
            // 如果是image是nil 则直接返回
            guard let image = image else {
                return
            }
            
            // 拿到图片，则返回
            finishedCallack(image)
        }
    }
    
    
    static func getSmartAlbums() -> [AlbumItem] {
        //获取所有的智能相册
        let options = PHFetchOptions()
//        let sort =  NSSortDescriptor.init(key: "createDate", ascending: false)
//        options.sortDescriptors = [sort]
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: options)
        print("智能相册有\(smartAlbums.count)个")
        
        //只显示图片资源
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let albumsArray = getAssetResultInCollection(smartAlbums, fetchOptions: options)
        
        return albumsArray
    }
    
    static func getAssetResultInCollection(_ collection: PHFetchResult<PHAssetCollection>, fetchOptions options: PHFetchOptions) ->[AlbumItem] {
        var albumsArray = [AlbumItem]()
        
        for index in 0..<collection.count {
            //获取一个相册
            let assetCollection = collection[index];
            
            //然后从每一个智能相册中获取资源，获取到的是一个list
            let assetFecthResults = PHAsset.fetchAssets(in: assetCollection, options: options);
            print("\(assetCollection.localizedTitle ?? "")相册，共有照片数:\(assetFecthResults.count)")
            
            
            if assetCollection.assetCollectionSubtype != .smartAlbumVideos && assetCollection.assetCollectionSubtype != .smartAlbumSlomoVideos && assetCollection.assetCollectionSubtype != .smartAlbumAllHidden  {
                let album = AlbumItem.init(title: assetCollection.localizedTitle, fetchResult: assetFecthResults)
                albumsArray.append(album)
            }
        }
        
        return albumsArray
    }
    
    
    
    //MARK: 获取相册所有图片
    static func getPHAssetsList(_ assetFecthResults: PHFetchResult<PHAsset>) -> [PhotoModel]{
        var photos = [PhotoModel]()
        
        assetFecthResults.enumerateObjects { (asset,curIndex,nil) in
            let photoModel = PhotoModel.init()
            photoModel.asset = asset
            photos.append(photoModel)
        }
        
        
        return photos
    }
    
    
    //MARK:  更新选中的索引
     static func updateSelectedIndex(_ selectedPhotos:[PhotoModel]!) ->Void{
        for photo in selectedPhotos {
            let orderTag = selectedPhotos.firstIndex(of: photo)! + 1
            photo.orderTag = orderTag
        }
    }
    
    
    
}

