//
//  SheetMenuModel.swift
//  AlbumDemo
//
//  Created by fengying on 2023/4/19.
//

import Foundation



public enum SheetMenuType : Int {
    case originalDrawing = 0  //原图(默认)
    case removeShadows = 1  //去阴影
    case enhanceAndSharpen = 2 //增强并锐化
    case brightening = 3 //增亮
    case blackAndWhite  = 4 //黑白
    case grayScale = 5 //灰度
    case tonerSave  = 6 //省墨
}

class SheetMenuModel:NSObject{
    
   
    
    var icon:String = ""
    var title:String = ""
    var type:SheetMenuType = .removeShadows
    var selected:Bool = false
     
    init(icon:String,title:String,type:SheetMenuType,selected:Bool) {
        self.icon = icon
        self.title = title
        self.type = type
        self.selected = selected
    }
}
