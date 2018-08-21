//
//  ViewController.swift
//  ImagePicker
//
//  Created by Admin on 8/18/18.
//  Copyright © 2018 Marmeto. All rights reserved.
//

import UIKit
import Photos
import AVKit
import DKImagePickerController
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, DKImageAssetExporterObserver {
    @IBOutlet weak var moreTableview: UITableView!
    @IBOutlet weak var CamBtnProp: UIButton!
    var pickerController: DKImagePickerController!
    var exportManually = false


    var OptionsArray = [ImageCollection]()
    
    
    deinit {
        DKImagePickerControllerResource.customLocalizationBlock = nil
        DKImagePickerControllerResource.customImageBlock = nil
        
        DKImageExtensionController.unregisterExtension(for: .camera)
        DKImageExtensionController.unregisterExtension(for: .inlineCamera)
        
        DKImageAssetExporter.sharedInstance.remove(observer: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.moreTableview.delegate = self
        self.moreTableview.dataSource = self
        self.moreTableview.separatorStyle = .none
        self.moreTableview.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

       
    }
    override func viewWillAppear(_ animated: Bool) {
        let fetchrequest : NSFetchRequest<ImageCollection> = ImageCollection.fetchRequest()
        do{
            let imageData = try PersistanceServices.context.fetch(fetchrequest)
            self.OptionsArray = imageData
            self.moreTableview.reloadData()
        }catch{}
    }
    
    @IBAction func CameraIsClicked(_ sender: UIButton) {
        let pickerController1 = DKImagePickerController()
        pickerController1.assetType = .allPhotos
        
        pickerController = pickerController1

        showImagePicker()

    }
    func showImagePicker() {
        
        if self.exportManually {
            DKImageAssetExporter.sharedInstance.add(observer: self)
        }
        
        if let assets = UsersManager.sharedInstance.SelectedImagesAsset {
            pickerController.select(assets: assets)
        }
        
        pickerController.exportStatusChanged = { status in
            switch status {
            case .exporting:
                print("exporting")
            case .none:
                print("none")
            }
        }
        
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            self.updateAssets(assets: assets)
        }
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            pickerController.modalPresentationStyle = .formSheet
        }
        
        if pickerController.inline {
            self.showInlinePicker()
        } else {
            self.present(pickerController, animated: true) {}
        }
    }
    // MARK: - Inline Mode
    
    func showInlinePicker() {
        let pickerView = self.pickerController.view!
        pickerView.frame = CGRect(x: 0, y: 170, width: self.view.bounds.width, height: 200)
        self.view.addSubview(pickerView)
        
        let doneButton = UIButton(type: .custom)
        doneButton.setTitleColor(UIColor.blue, for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        doneButton.frame = CGRect(x: 0, y: pickerView.frame.maxY, width: pickerView.bounds.width / 2, height: 50)
        self.view.addSubview(doneButton)
        self.pickerController.selectedChanged = { [unowned self] in
            self.updateDoneButtonTitle(doneButton)
        }
        self.updateDoneButtonTitle(doneButton)
        
        let albumButton = UIButton(type: .custom)
        albumButton.setTitleColor(UIColor.blue, for: .normal)
        albumButton.setTitle("Album", for: .normal)
        albumButton.addTarget(self, action: #selector(showAlbum), for: .touchUpInside)
        albumButton.frame = CGRect(x: doneButton.frame.maxX, y: doneButton.frame.minY, width: doneButton.bounds.width, height: doneButton.bounds.height)
        self.view.addSubview(albumButton)
    }
    @objc func showAlbum() {
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = self.pickerController.maxSelectableCount
        pickerController.select(assets: self.pickerController.selectedAssets)
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            self.updateAssets(assets: assets)
            self.pickerController.setSelectedAssets(assets: assets)
        }
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func updateDoneButtonTitle(_ doneButton: UIButton) {
        doneButton.setTitle("Done(\(self.pickerController.selectedAssets.count))", for: .normal)
    }
    @objc func done() {
        self.updateAssets(assets: self.pickerController.selectedAssets)
    }
    
    func updateAssets(assets: [DKAsset]) {
        print("didSelectAssets")
        
        UsersManager.sharedInstance.SelectedImagesAsset = assets
        
        if assets.count > 0 {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ImagePreviewCollectionViewController") as! ImagePreviewCollectionViewController
        self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        if pickerController.exportsWhenCompleted {
            for asset in assets {
                if let error = asset.error {
                    print("exporterDidEndExporting with error:\(error.localizedDescription)")
                } else {
                    print("exporterDidEndExporting:\(asset.localTemporaryPath!)")
                }
            }
        }
        
        if self.exportManually {
            DKImageAssetExporter.sharedInstance.exportAssetsAsynchronously(assets: assets, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OptionsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as UITableViewCell!
        cell.textLabel?.text = OptionsArray[indexPath.row].caption
      
        let temp = OptionsArray[indexPath.row].image?.components(separatedBy: ",")
        let dataDecoded : Data = Data(base64Encoded: temp![0], options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        cell.imageView?.image = decodedimage
        if (indexPath.row%2) == 1 {
            cell.backgroundColor = UIColor.init(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
            
        }else{
            cell.contentView.backgroundColor = .white
            
        }
        return cell
        
    }
    
}

