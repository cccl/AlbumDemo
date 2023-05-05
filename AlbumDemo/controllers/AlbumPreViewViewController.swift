//
//  AlbumPreViewViewController.swift
//  AlbumDemo
//
//  Created by fengying on 2023/3/30.
//

import UIKit
import Photos


class AlbumPreViewViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource{
    
    var completeBlock:CompleteBlock? = nil
    
    
    
    //MARK: =========CollectionView配置======
    let reuseIdentifier = "PhotoPreViewCell"
    let cellSpace:CGFloat = 0  //每个cell边距
    
    
    let smallResID = "SmallPhotoCell"
    let smallCellSize:CGSize = CGSize.init(width: 70, height: 70)
    
    
    var photoArray:[PhotoModel] = []
    var selectedPhotoArray:[PhotoModel] = []  //选中的图片
    var curIndex:Int = 0
    
    var showBar:Bool = true // 显示bar
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var smallCollectionView: UICollectionView!
    
    @IBOutlet weak var smallCollectionViewHCSt: NSLayoutConstraint!
    let smallCollectionViewH:CGFloat = 80
    
    //MARK: 顶部bar配置
    @IBOutlet weak var topBarHeight: NSLayoutConstraint!
    let topBarH:CGFloat = AdapterUtil.statusBarH + 44
    
    @IBOutlet weak var topBarMarginTopCst: NSLayoutConstraint!
    
    //MARK：底部bar
    let bottomBarH:CGFloat = AdapterUtil.isiPhoneX() ? (AdapterUtil.safeAreaBottom()+124):124
    
    @IBOutlet weak var bottomBarHCst: NSLayoutConstraint!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    @IBOutlet weak var selectedBtn: UIButton!
    
    @IBOutlet weak var importBtn: UIButton!
    
    
    deinit{
        print("======")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
    }
    
    
    func initSubViews(){
        topBarMarginTopCst.constant = -AdapterUtil.statusBarH
        
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let screenWidth :CGFloat = UIScreen.main.bounds.size.width
        let screenHeight :CGFloat = UIScreen.main.bounds.size.height
        let itemSizeWidth:CGFloat = screenWidth
        layout?.minimumLineSpacing = cellSpace
        layout?.minimumInteritemSpacing = cellSpace
        layout?.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        layout?.itemSize = CGSize.init(width: floor(itemSizeWidth), height: floor(screenHeight))
        
        self.collectionView.register(UINib.init(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.reloadData()
        
        
        
        let smallLayout = self.smallCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let smallCellSpace:CGFloat = 0
        smallLayout?.minimumLineSpacing = smallCellSpace
        smallLayout?.minimumInteritemSpacing = smallCellSpace
        smallLayout?.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        smallLayout?.itemSize = smallCellSize
        
        self.smallCollectionView.register(UINib.init(nibName: smallResID, bundle: nil), forCellWithReuseIdentifier: smallResID)
        self.smallCollectionView.reloadData()
        
        
        self.perform(#selector(scrollToItem(_ :)), with: nil, afterDelay: 0.01)
    }
    
    
    @objc func scrollToItem(_:Any){
        //解决iOS14 分页模式下scrollToItem失效问题
        self.collectionView.isPagingEnabled = false
        self.collectionView.scrollToItem(at: IndexPath.init(row: self.curIndex, section: 0), at: .left, animated: false)
        self.collectionView.isPagingEnabled = true
        
        showBarMenu(true)
        updateSmallCollectionViewOffSet()
    }
    
    func showBarMenu(_ show:Bool){
        if show {
            topBarHeight.constant = topBarH
            updateBottomBar()
        }
        else{
            topBarHeight.constant = 0
            bottomBarHCst.constant = 0
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    //MARK: 更新底部bar
    func updateBottomBar(){
        let count = self.selectedPhotoArray.count
        if count > 0{
            smallCollectionViewHCSt.constant = smallCollectionViewH
            bottomBarHCst.constant = bottomBarH
            
            let title = "("+String(count)+") 导入"
            importBtn.setTitle(title, for: .normal)
        }
        else {
            bottomBarHCst.constant = bottomBarH - smallCollectionViewH
            smallCollectionViewHCSt.constant = 0
            importBtn.setTitle("导入", for: .normal)
        }
        
        bottomBarView.layoutIfNeeded()
    }
    
    //MARK: 更新选择按钮
    func updateSelectBtn(_ selected:Bool){
        self.selectedBtn.isSelected = selected
    }
    
    
    
    //MARK: 页面返回
    @IBAction func backAction(_ sender: Any) {
        completeBlock?(self.photoArray, self.selectedPhotoArray,false)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: 选中/未选中当前图片
    @IBAction func selectedAction(_ sender: UIButton) {
        let index = getCurrentIndexPathItem()
        if index >= 0{
            self.curIndex = index
            let photoModel = self.photoArray[self.curIndex]
            let selected = !photoModel.selected
            if selected{
                photoModel.selected = selected
                self.selectedPhotoArray.append(photoModel)
                photoModel.orderTag = self.selectedPhotoArray.count
                
                updateSelectBtn(selected)
                updateBottomBar()
                
                
                let item = self.selectedPhotoArray.count - 1
                let indexPath =  IndexPath.init(item: item, section: 0)
                self.smallCollectionView.insertItems(at: [indexPath])
            }
            else if(self.selectedPhotoArray.contains(photoModel)){
                let index = self.selectedPhotoArray.firstIndex(of: photoModel)
                photoModel.selected = selected
                self.selectedPhotoArray.remove(at: index!)
                
                AlbumsUtil.updateSelectedIndex(self.selectedPhotoArray)
                let indexPath =  IndexPath.init(item: index!, section: 0)
                self.smallCollectionView.deleteItems(at: [indexPath])
                updateSmallCollectionViewCells()
                
                updateSelectBtn(selected)
                updateBottomBar()
            }
            
            self.perform(#selector(updateSmallCollectionViewOffSet), with: nil, afterDelay: 0.03)
        }
    }
    
    
    
    //MARK: 更新按钮数据
    func updateSmallCollectionViewCells(){
        let count = self.selectedPhotoArray.count
        if count > 0{
            for item in 0...count-1{
                
                let indexPath = IndexPath.init(item: item, section: 0)
                let cell =  self.smallCollectionView.cellForItem(at: indexPath) as? SmallPhotoCell
                cell?.deleteBtn.tag = item //更新按钮tag，避免删除出错
            }
        }
    }
    
    
    
    
    //MARK: 获取当前item索引
    func getCurrentIndexPathItem()->Int{
        var item = -1
        let visibleIndexPaths:[IndexPath]  = collectionView.indexPathsForVisibleItems
        if visibleIndexPaths.count > 0 {
            let indexPath = visibleIndexPaths[0]
            item = indexPath.item
        }
        
        return item
    }
    
    //MARK: 导入
    @IBAction func importAction(_ sender: Any) {
        print("importAction: ",self.selectedPhotoArray.count)
        completeBlock?(self.photoArray, self.selectedPhotoArray,true)
    }
    //MARK: 缩略图自动滚动
    @objc  func updateSmallCollectionViewOffSet(){
        let index = getCurrentIndexPathItem()
        if index >= 0{
            self.curIndex = index
            let photoModel = self.photoArray[self.curIndex]
            
            if(self.selectedPhotoArray.contains(photoModel)){
                let item = self.selectedPhotoArray.firstIndex(of: photoModel)
                let indexPath = IndexPath.init(item: item!, section: 0)
                self.smallCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        if collectionView.tag == 1{
            let item = indexPath.item
            let photoModel = self.photoArray[item]
            updateSelectBtn(photoModel.selected)
        }
    }
    
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 1 {
            updateSmallCollectionViewOffSet()
        }
    }
    
    
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        var count = self.photoArray.count;
        if collectionView.tag == 2{
            count =  self.selectedPhotoArray.count
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        print(indexPath.row)
        
        if collectionView.tag == 1 {
            let photoModel = self.photoArray[indexPath.row]
            let isSelected = !photoModel.selected
            photoModel.selected = isSelected
            collectionView.reloadItems(at: [indexPath])
            showBar = !showBar
            showBarMenu(showBar)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        if collectionView.tag == 1 {
            let cell: PhotoPreViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoPreViewCell
            
            let photoModel = self.photoArray[indexPath.item]
            cell.configCell(photoModel,assetThumbnailSize: CGSize.zero)
            return cell
        }
        else {
            let cell: SmallPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: smallResID, for: indexPath) as! SmallPhotoCell
            
            let photoModel = self.selectedPhotoArray[indexPath.item]
            cell.configCell(photoModel,assetThumbnailSize: CGSize.init(width: smallCellSize.width*2, height: smallCellSize.height*2))
            
            cell.deleteBtn.tag = indexPath.item
            cell.deleteBtn.addTarget(self, action: #selector(deleteAction(_ :)), for: .touchUpInside)
            
            return cell
        }
    }
    
    
    @objc func deleteAction(_ sender:UIButton){
        let item:Int = sender.tag
        let photoModel = self.selectedPhotoArray[item]
        photoModel.selected =  !photoModel.selected
        
        if self.photoArray.contains(photoModel){
            let index = self.photoArray.firstIndex(of: photoModel)
            self.curIndex = getCurrentIndexPathItem()
            if index == self.curIndex {
                //删除当前图片
                updateSelectBtn(false)
            }
            self.selectedPhotoArray.remove(at: item)
            AlbumsUtil.updateSelectedIndex(self.selectedPhotoArray)
            
            let indexPath =  IndexPath.init(item: item, section: 0)
            self.smallCollectionView.deleteItems(at: [indexPath])
            updateSmallCollectionViewCells()
            
            updateBottomBar()
        }
    }
    
}

