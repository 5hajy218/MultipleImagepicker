//
//  ImagePreviewCollectionViewController.swift
//  ImagePicker
//
//  Created by Admin on 8/19/18.
//  Copyright © 2018 Marmeto. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ImagePreviewCollectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    struct userSelection {
        var Imagedata: String?
        var user_Caption: String?
        var optional: String?
    }
    var Imagearray = [userSelection]()
    var exportManually = false
    
    @IBOutlet weak var ImagePreviewCollection: UICollectionView!
    @IBOutlet weak var CaptionTextView: UITextField!
    @IBOutlet weak var SaveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        ImagePreviewCollection.dataSource = self
        ImagePreviewCollection.delegate = self
        self.ImagePreviewCollection!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return (UsersManager.sharedInstance.SelectedImagesAsset?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = UsersManager.sharedInstance.SelectedImagesAsset![indexPath.row]
        var cell: UICollectionViewCell?
        var imageView: UIImageView?
        var maskView: UIView?
        
        if asset.type == .photo {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellImage", for: indexPath)
            imageView = cell?.contentView.viewWithTag(1) as? UIImageView
            maskView = cell?.contentView.viewWithTag(2)
            
        }
        
        if let cell = cell, let imageView = imageView {
            let CollectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            CollectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            CollectionViewLayout.itemSize = CGSize(width: self.view.frame.width - 20  , height: self.view.frame.height - 30)
            CollectionViewLayout.scrollDirection = .horizontal
            collectionView.setCollectionViewLayout(CollectionViewLayout, animated: true)
            
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            let tag = indexPath.row + 1
            cell.tag = tag
            asset.fetchImage(with: layout.itemSize.toPixel(), completeBlock: { image, info in
                if cell.tag == tag {
                    imageView.image = image
                    let myThumb2 = self.compressImage(image: image!)
                    
                    let imageData:NSData = myThumb2! as NSData
                    let ImageBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                    let imagedata = userSelection.init(Imagedata: ImageBase64, user_Caption: "", optional: "")
                    if self.Imagearray.count < (UsersManager.sharedInstance.SelectedImagesAsset?.count)!{
                        self.Imagearray.append(imagedata)
                    }
                    
                }
            })
        }
        
        maskView?.isHidden = !self.exportManually
        
        return cell!
    }
    
    
    func compressImage(image:UIImage) -> Data?  {
        // Reducing file size to a 10th
        
        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        let maxHeight : CGFloat = 1136.0
        let maxWidth : CGFloat = 640.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        let maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = 0.5
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else{
                actualHeight = maxHeight
                actualWidth = maxWidth
                compressionQuality = 1
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        guard let imageData = UIImageJPEGRepresentation(img, compressionQuality)else{
            return nil
        }
        return imageData
    }
    @IBAction func SaveIspressed(_ sender: UIButton) {
        
        for i in 0..<Imagearray.count{
            let image_data = ImageCollection(context: PersistanceServices.context)
            image_data.image = Imagearray[i].Imagedata
            image_data.caption = CaptionTextView.text
            PersistanceServices.saveContext()
        }
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}
