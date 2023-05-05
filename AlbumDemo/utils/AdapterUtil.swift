//
//  AdapterUtil.swift
//  AlbumDemo
//
//  Created by fengying on 2023/4/2.
//

import UIKit

class AdapterUtil: NSObject {
    
    
    //MARK: 状态栏高度
    static let statusBarH:CGFloat = UIApplication.shared.statusBarFrame.size.height
    
    //MARK: 判断是否为刘海屏
    static func isiPhoneX() ->Bool{
        return statusBarH > 20
    }
    
    
    //MARK: 底部安全区域高度
    static func safeAreaBottom()->CGFloat{
        var bottomPadding:CGFloat = 0
    
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
//            let topPadding = window?.safeAreaInsets.top
            bottomPadding = window?.safeAreaInsets.bottom ?? 0
        }
        return bottomPadding
    }
    
    static let screenWidth :CGFloat = UIScreen.main.bounds.size.width
    
    static let screenHeight :CGFloat = UIScreen.main.bounds.size.height
}
