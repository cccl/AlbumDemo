//
//  AlbumItem.swift
//  AlbumDemo
//
//  Created by fengying on 2023/3/28.
//

import UIKit
import Photos

class AlbumItem: NSObject{
    var title:String!
    var fetchResult:PHFetchResult<PHAsset>!
    init(title:String!,fetchResult:PHFetchResult<PHAsset>!) {
        self.title = title
        self.fetchResult = fetchResult
    }
    
    var count:String{
        get{
            return String(self.fetchResult.count)
        }
        set{
            self.count = newValue
        }
    }
    
    
    
    
}
