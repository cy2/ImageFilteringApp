//
//  PhotoViewController.swift
//  FilterMyPhotos
//
//  Created by cm2y on 1/14/15.
//  Copyright (c) 2015 cm2y. All rights reserved.
//

import UIKit
import Photos

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var assetsFetchResults : PHFetchResult!
  
  var assetCollection : PHAssetCollection!
  
  var imageManager = PHCachingImageManager() //manage performance
  
  var collectionView : UICollectionView!
  
  var destinationImageSize : CGSize!
  
  var delegate : ImageSelectedProtocol?
  
  
  override func loadView() {
  
      //set up a root view
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    
      //set up the collection view
    self.collectionView = UICollectionView(frame: rootView.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "FilterMyPhotos_blankBackground.JPG")!)
    
      //set up the flow layout
    let flowLayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
    flowLayout.itemSize = CGSize(width: 100, height: 100)
    
    //add the collection view to the root view
    rootView.addSubview(collectionView)
    
    //set the resizing mask
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    self.view = rootView
  
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    //set up image manager
    self.imageManager = PHCachingImageManager()
    
    //give me access to photos in the library
    self.assetsFetchResults = PHAsset.fetchAssetsWithOptions(nil)
    
    //become the deligate and datasource
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    //use cells of type GalleryCell
    self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "PHOTO_CELL")
    
    // Do any additional setup after loading the view.
  }
  
  
  
  
  //get a  count on the resultset array
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.assetsFetchResults.count
  }
  
  
  //draw cell
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    //draw the cell
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_CELL", forIndexPath: indexPath) as GalleryCell
    
    //make the request
    let asset = self.assetsFetchResults[indexPath.row] as PHAsset
    
    //grab the image
    self.imageManager.requestImageForAsset(asset, targetSize: CGSize(width: 100, height: 100), contentMode: PHImageContentMode.AspectFill, options: nil) { (requestedImage, info) -> Void in
      //update the cell value
      cell.imageView.image = requestedImage
    
    }
    
    return cell
  }
  
  
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    //request image for correct size
    
    let selectedAsset = self.assetsFetchResults[indexPath.row] as PHAsset
    //make the call for an image
    self.imageManager.requestImageForAsset(selectedAsset, targetSize: self.destinationImageSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (requestedImage, info) -> Void in
      println() // this is purely for the xcode one line closure bug
    
      //pass the image to the previous screen
      self.delegate?.controllerDidSelectImage(requestedImage,true)

      //go back to main screen
      self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
  }
  
  
  
}
