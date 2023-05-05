//
//  PhotoModel.swift
//  AlbumDemo
//
//  Created by fengying on 2023/3/29.
//

import UIKit
import Photos

class PhotoModel: NSObject {
    var selected:Bool = false
    var orderTag:Int = 0 //被选中的次序 从1开始
    var asset:PHAsset!
    var index:Int = -1 //列表中的索引
    var animated:Bool = true // 切换选中状态是否需要动画
    
    
    //MARK: 获取图片
    func getImageWithAsset(size: CGSize, finishedCallack: @escaping (_ image: UIImage) -> ()) {
        AlbumsUtil.getImageWithAsset(self.asset, size: size) { image in
            finishedCallack(image)
        }
    }
        
}
