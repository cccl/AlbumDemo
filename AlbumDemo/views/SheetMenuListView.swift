//
//  SheetMenuView.swift
//  AlbumDemo
//
//  Created by fengying on 2023/4/19.
//

import UIKit

typealias DidSelectedSheetMenuBlock = (_ item:SheetMenuModel) -> ()


class SheetMenuListView: UIView,UICollectionViewDelegate,UICollectionViewDataSource{
    
    let reuseIdentifier = "SheetMenuCell"
    let numberOfColum:CGFloat = 4  //每行显示个数
    let cellSpace:CGFloat = 15.0  //每个cell边距
    
    var currentItem:Int = 1  //当前选中的菜单默认原图
    var didSelectBlock:DidSelectedSheetMenuBlock? = nil
    
    var dataSource:[SheetMenuModel] =  [
        SheetMenuModel.init(icon: "print_original.jpg", title: "去阴影", type: .removeShadows, selected: false),
        SheetMenuModel.init(icon: "print_original.jpg", title: "原图", type: .originalDrawing, selected: true),
        SheetMenuModel.init(icon: "print_magic color.jpg", title: "增强并锐化", type: .enhanceAndSharpen, selected: false),
        SheetMenuModel.init(icon: "print_lighten.jpg", title: "增亮", type: .brightening, selected: false),
        SheetMenuModel.init(icon: "print_B&W.jpg", title: "黑白", type: .blackAndWhite, selected: false),
        SheetMenuModel.init(icon: "print_grayscale.jpg", title: "灰度", type: .grayScale, selected: false),
        SheetMenuModel.init(icon: "print_B&W 2.jpg", title: "省墨", type: .tonerSave, selected: false),
    ]
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    
    //MARK: 选中的模式
    func setSelectSheetMenuBlock(_ block:DidSelectedSheetMenuBlock?) ->Void{
        
        self.didSelectBlock = block
        let model = self.dataSource[currentItem]
        
        self.didSelectBlock?(model)
       
    }
    
    func loadNib(){
        let bundle = Bundle.init(for: SheetMenuListView.self)
        let nib = UINib.init(nibName: "SheetMenuListView", bundle: bundle)
        if let instanceView = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            instanceView.frame = self.bounds
            self.addSubview(instanceView)
            
            let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            let screenWidth :CGFloat = UIScreen.main.bounds.size.width
            let itemSizeWidth:CGFloat = (screenWidth - cellSpace * 2 - cellSpace * (numberOfColum - 1)) / numberOfColum
            layout?.minimumLineSpacing = cellSpace
            layout?.minimumInteritemSpacing = cellSpace
            layout?.sectionInset = UIEdgeInsets.init(top: 0, left: cellSpace, bottom: 0, right: cellSpace)
            layout?.itemSize = CGSize.init(width: floor(itemSizeWidth), height: floor(itemSizeWidth+20))
            
            self.collectionView.allowsMultipleSelection = true
            self.collectionView.register(UINib.init(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
            self.collectionView.reloadData()
        }
    }
    
    

    
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.dataSource.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        print(indexPath.row)
        let item = indexPath.item
        
        let sheetModel = self.dataSource[item]
        sheetModel.selected = true
        var items:[IndexPath] = [indexPath]
        
        if self.currentItem >= 0{
            let preSheetModel = self.dataSource[self.currentItem]
            preSheetModel.selected = false
            let preIndexPath = IndexPath.init(item: self.currentItem, section: 0)
            
            items.append(preIndexPath)
        }
        self.currentItem = item
        self.didSelectBlock?(self.dataSource[self.currentItem])
        collectionView.reloadItems(at: items)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let item = indexPath.item
        let sheetModel = self.dataSource[item]
        sheetModel.selected = false
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: SheetMenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SheetMenuCell
        
        let item = indexPath.item
        let sheetModel = self.dataSource[item]
        cell.imageView.image = UIImage.init(named: sheetModel.icon)
        cell.titleLab.text = sheetModel.title
        
        let selected = sheetModel.selected
        cell.selectedView.isHidden = !selected
        if selected {
            cell.titleLab.textColor = UIColor.init(red: 37.0/255, green: 196.0/255, blue: 164.0/255, alpha: 1.0)
        }
        else{
            cell.titleLab.textColor = UIColor.white
        }
        return cell
    }
}
