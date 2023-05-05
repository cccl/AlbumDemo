//
//  AlbumListViewController.swift
//  AlbumDemo
//
//  Created by fengying on 2023/3/28.
//

import UIKit
import Photos

class AlbumListViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    //回调
    var completeBlock:DidSelectPhotosBlock? = nil
    
    //MARK: =========CollectionView配置======
    let reuseIdentifier = "PhotoThumbnailCell"
    let numberOfColum:CGFloat = 3  //每行显示个数
    let cellSpace:CGFloat = 5.0  //每个cell边距
    
    
    //MARK: 底部Bar配置
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomBarMarginBottom: NSLayoutConstraint!
    
    
    //根据状态栏高度判断是否是刘海屏
    let bottomBarH:CGFloat =  AdapterUtil.isiPhoneX() ? (48+34):48
    //MARK: =========
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var albums:[AlbumItem] = []   //相册列表
    
    var photosAsset: PHFetchResult<PHAsset>!
    var assetThumbnailSize:CGSize!
    var photoArray:[PhotoModel] = []
    var dragIndexPaths:[IndexPath] = []  //保存滑动接触到的cell索引
    var selectedPhotoArray:[PhotoModel] = []  //选中的图片,图片有先后顺序
    
    var firstDrag:Bool = true
    
    
    @IBOutlet weak var topMenuViewHCst: NSLayoutConstraint!
    @IBOutlet weak var topPopMenuView: AlbumPopMenuView!
    
    
    @IBOutlet weak var importBtn: UIButton!
    
    
    //当前相册名称
    @IBOutlet weak var curAlbumNameLab: UILabel!
    
    @IBOutlet weak var arrowImageView: UIImageView!
    
    //滤镜图片
    @IBOutlet weak var filterImageView: UIImageView!
    
    @IBOutlet weak var selectedBtn: UIButton!
    
    
    @IBOutlet weak var alpahView: UIView!
    @IBOutlet weak var sheetMenuView: SheetMenuListView!
    
    @IBOutlet weak var sheetMenuViewHCst: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var filterBtnLab: UILabel!
    
    
    deinit{
        print("AlbumListViewController deinit ======")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initSubViews()
    }
    
    
    
    
    func initData(){
        AlbumsUtil.requestAuthorization({ [weak self] status in
            if status == .authorized{
                self?.getAlbumData()
            }
            else if(status == .denied){
                //权限被拒绝，提示用户
                let alert = UIAlertController.init(title: "错误", message: "无权访问您的相片，请前往 系统设置->隐私->照片，授权访问您的相片", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { _ in
                    self?.navigationController?.popViewController(animated: true)
                }
                alert.addAction(cancelAction)
                
                let okAction = UIAlertAction.init(title: "设置", style: .default) { _ in
                    
                    let url = URL.init(string:UIApplication.openSettingsURLString) ?? nil
                    if url != nil{
                        let canOpen = UIApplication.shared.canOpenURL(url! )
                        if canOpen {
                            UIApplication.shared.open(url!, options:[:], completionHandler: { success in
                                
                            })
                        }
                    }
                }
                alert.addAction(okAction)
                
                self?.present(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    //MARK: 获取相册数据
    func getAlbumData(){
        self.albums = AlbumsUtil.getSmartAlbums()
        
        
        if self.albums.count > 0{
            let albumItem = albums[0] as AlbumItem
            let assetFecthResults = albumItem.fetchResult as  PHFetchResult<PHAsset>
            self.photosAsset = assetFecthResults
            self.photoArray = AlbumsUtil.getPHAssetsList(self.photosAsset)
            self.curAlbumNameLab.text = albumItem.title
        }
    }
    
    
    //MARK: 相册列表菜单
    @IBAction func showMenuListAction(_ sender: Any) {
        if self.topMenuViewHCst.constant > 0{
            hiddenMenuList()
        }
        else{
            showMenuList()
        }
    }
    
    @IBAction func hideTopMenuView(_ sender: Any) {
        hiddenMenuList()
    }
    
    
    func showMenuList(){
        
        self.topMenuViewHCst.constant = AdapterUtil.screenHeight - 64 - AdapterUtil.statusBarH
        
        self.topPopMenuView.updateDataSource(self.albums) { [weak self] indexPath in
            print("indexPath.row",indexPath.row)
            
            let albumItem = self?.albums[indexPath.row]
            let assetFecthResults = albumItem?.fetchResult
            
            self?.selectedPhotoArray.removeAll()
            self?.photosAsset = assetFecthResults
            self?.photoArray = AlbumsUtil.getPHAssetsList((self?.photosAsset!)!)
            self?.collectionView.reloadData()
            
            self?.curAlbumNameLab.text = albumItem!.title
            self?.updateImportBtn()
            
            
            self?.view.layoutIfNeeded()
            
            self?.perform(#selector(self?.initSubViewsDelay(_ :)), with: nil, afterDelay: 0.01)
        }
        
        self.arrowImageView.rotateImageView(true)
        
        hiddenSheetMenus()
    }
    
    func hiddenMenuList(){
        self.topMenuViewHCst.constant = 0
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        self.arrowImageView.rotateImageView(false)
    }
    
    
    //MARK: ====初始化子view===
    func initSubViews(){
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let screenWidth :CGFloat = UIScreen.main.bounds.size.width
        let itemSizeWidth:CGFloat = (screenWidth - cellSpace * 2 - cellSpace * (numberOfColum - 1)) / numberOfColum
        layout?.minimumLineSpacing = cellSpace
        layout?.minimumInteritemSpacing = cellSpace
        layout?.sectionInset = UIEdgeInsets.init(top: 0, left: cellSpace, bottom: 0, right: cellSpace)
        layout?.itemSize = CGSize.init(width: floor(itemSizeWidth), height: floor(itemSizeWidth))
        self.assetThumbnailSize = CGSize.init(width: itemSizeWidth*2, height: itemSizeWidth*2)
        
        
        self.collectionView.register(UINib.init(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.reloadData()
        
        
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognizerAction(_ :)))
        self.view.addGestureRecognizer(panGesture)
        
        bottomBarHeight.constant = bottomBarH
        bottomBarMarginBottom.constant = -bottomBarH
        
        importBtn.setTitleColor(UIColor.white, for: .normal)
        importBtn.setTitleColor(UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.7), for: .disabled)
        importBtn.setBackgroundImage(UIImage.imageWithColor(UIColor.init(red: 25/255.0, green: 188/255.0, blue: 170/255.0, alpha: 1), size: CGSize.init(width: 4, height: 2)), for: .normal)
        importBtn.setBackgroundImage(UIImage.imageWithColor(UIColor.init(red: 117/255.0, green: 214/255.0, blue: 204/255.0, alpha: 1), size: CGSize.init(width: 4, height: 2)), for: .disabled)
        
        
        
        self.sheetMenuView.setSelectSheetMenuBlock { [weak self] item in
            
            print("setSelectSheetMenuBlock: ",item.type)
            self?.filterBtnLab.text = item.title
            
        }
        
        self.perform(#selector(initSubViewsDelay(_ :)), with: nil, afterDelay: 0.01)
        
        
        
    }
    
    
    //MARK: 延迟处理子view
    @objc  func initSubViewsDelay(_ :Any){
        scrollToBottom()
        hiddenMenuList()
    }
    
    
    //MARK: 滑动到底部
    func scrollToBottom(){
        self.collectionView.scrollToItem(at: IndexPath.init(row: self.photoArray.count - 1, section: 0), at: .bottom, animated: false)
    }
    
    
    //MARK: 滑动选中图片
    @objc func panGestureRecognizerAction(_ recognizer:UISwipeGestureRecognizer){
        print("recognizer.state",recognizer.state.rawValue)
        
        if recognizer.state == .began {
            self.dragIndexPaths.removeAll()
        }
        
        if recognizer.state == .changed  {
            let point = recognizer.location(in: self.collectionView)
            let indexPath = self.collectionView.indexPathForItem(at: point)
            let row:Int = indexPath?.row ?? -1
            if row >= 0 {
                if !self.dragIndexPaths.contains(indexPath!){
                    //滑动过程中每个cell只添加一次
                    self.dragIndexPaths.append(indexPath!)
                    let photoModel = self.photoArray[row]
                    photoModel.selected = !photoModel.selected
                    
                    updateSelectedCell(photoModel, indexPath: indexPath! )
                }
                print("swipeAction cell index",String(indexPath?.row ?? -1))
            }
        }
        
        if recognizer.state == .ended{
            self.dragIndexPaths.removeAll()
        }
    }
    
    
    
    //MARK: 获取选中的indexPath
    func getSelectedIndexPath()->[IndexPath]{
        var indexPaths:[IndexPath] = []
        for photoModel in self.selectedPhotoArray{
            let indexPath = IndexPath.init(item: photoModel.index, section: 0)
            indexPaths.append(indexPath)
        }
        return indexPaths
    }
    
    
    //MARK: 更新选中cell状态
    func updateSelectedCell(_ photoModel:PhotoModel,indexPath:IndexPath){
        let selected = photoModel.selected
        if selected {
            self.selectedPhotoArray.append(photoModel)
            photoModel.orderTag = self.selectedPhotoArray.count
            self.collectionView.reloadItems(at:[indexPath])
        }
        else if self.selectedPhotoArray.contains(photoModel) {
            //取消选中
            photoModel.orderTag = 0
            let index = self.selectedPhotoArray.firstIndex(of: photoModel)
            let indexPaths = getSelectedIndexPath()
            self.selectedPhotoArray.remove(at: index!)
            //取消选中，需要更新所有选中图片的索引
            AlbumsUtil.updateSelectedIndex(self.selectedPhotoArray)
            
            //局部刷新
            self.collectionView.reloadItems(at: indexPaths)
        }
        
        
        //底部bar显示/隐藏逻辑，避免多次设置constant导致页面刷新
        if self.selectedPhotoArray.count > 1 {
            if self.bottomBarMarginBottom.constant < 0{
                self.bottomBarMarginBottom.constant = 0
            }
        }
        else if(self.bottomBarMarginBottom.constant >= 0){
            self.bottomBarMarginBottom.constant = -self.bottomBarH
        }
        
        updateImportBtn()
    }
    
    //MARK:  更新导入按钮
    func updateImportBtn(){
        let count = self.selectedPhotoArray.count
        let title:String = count > 0 ? "("+String(count)+") 导入":"导入"
        importBtn.setTitle(title, for: .normal)
        importBtn.isEnabled = count > 0
    }
    
    
    //MARK: 页面返回
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    //MARK: 导入
    @IBAction func importAction(_ sender: Any) {
        hiddenSheetMenus()
        self.completeBlock?(self.selectedPhotoArray)
        self.dismiss(animated: true)
    }
    
    
    
    //MARK: 选择自动切边
    @IBAction func autoClipBorderAction(_ sender: UIButton) {
        sender.isSelected =  !sender.isSelected
        
    }
    
    //MARK: 选择滤镜
    @IBAction func fliterAction(_ sender: UIButton) {
        let isHidden = !self.alpahView.isHidden
        if isHidden {
            hiddenSheetMenus()
        }
        else{
            showSheetMenus()
        }
    }
    
    @IBAction func hiddenSheetMenusAction(_ sender: Any?) {
        hiddenSheetMenus()
    }
    
    
    func hiddenSheetMenus(){
        let isHighlighted = false
        self.filterImageView.rotateImageView(isHighlighted)
        
        self.alpahView.isHidden = true
        self.sheetMenuViewHCst.constant = 0
        
        self.selectedBtn.isEnabled = true
    }
    
    func showSheetMenus(){
        let isHighlighted = true
        self.filterImageView.rotateImageView(isHighlighted)
        self.alpahView.isHidden = false
        self.sheetMenuViewHCst.constant = 280
        self.selectedBtn.isEnabled = false
    }
    
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.photoArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        print(indexPath.row)
        let ctr = AlbumPreViewViewController.init(nibName: "AlbumPreViewViewController", bundle: nil)
        ctr.photoArray = self.photoArray
        ctr.view.backgroundColor = UIColor.white
        ctr.selectedPhotoArray = self.selectedPhotoArray
        ctr.curIndex = indexPath.item
        ctr.completeBlock = { [weak self] (photos,selectedPhotos,dismiss) in
            if dismiss{
                self?.completeBlock?(selectedPhotos)
                self?.dismiss(animated: true)
            }
            else{
                self?.photoArray = photos
                self?.selectedPhotoArray = selectedPhotos
                self?.collectionView.reloadData()
            }
        }
        self.navigationController?.pushViewController(ctr, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: PhotoThumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoThumbnailCell
        
        let item = indexPath.item
        let photoModel = self.photoArray[item]
        photoModel.index = item
        cell.selectedBtn.tag = item
        
        cell.selectedBtn.addTarget(self, action: #selector(selectedAction(_ :)), for: .touchUpInside)
        
        cell.configCell(photoModel,assetThumbnailSize: self.assetThumbnailSize)
        return cell
    }
    
    
    
    @objc func selectedAction(_ sender:UIButton){
        let row:Int = sender.tag
        let indexPath = NSIndexPath.init(item: row, section: 0)
        let photoModel = self.photoArray[row]
        photoModel.selected =  !photoModel.selected
        updateSelectedCell(photoModel, indexPath: indexPath as IndexPath)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
