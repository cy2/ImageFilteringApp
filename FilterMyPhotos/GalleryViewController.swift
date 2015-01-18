//
//  GalleryViewController.swift
//  FilterMyPhotos
//
//  Created by cm2y on 1/13/15.
//  Copyright (c) 2015 cm2y. All rights reserved.
//

import UIKit


protocol ImageSelectedProtocol {
  func controllerDidSelectImage(UIImage,Bool) -> Void
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

  //global properties
  var collectionView : UICollectionView!
  //images for gallery
  var galleryImageArray = [UIImage]()
  //create a delegate to deal with the image click
  var collectionViewFlowLayout : UICollectionViewFlowLayout!
  
  var delegate : ImageSelectedProtocol?
  //var delegate : AnyObject <ImageSelectedProtocol>
  
  
    override func loadView(){
      
      println("load view called")
      
      //create the container view
      let rootView = UIView(frame: UIScreen.mainScreen().bounds)
      
      
            //create the view for the gallery of images
          let collectionViewFlowLayout = UICollectionViewFlowLayout()
          collectionViewFlowLayout.itemSize = CGSize(width: 200, height: 200)
      
          //create the collection view
        self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
        collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "FilterMyPhotos_blankBackground.JPG")!)
      
      
        //add the gallery display view to root view
      rootView.addSubview(self.collectionView)
      
      //set the datasource
      self.collectionView.dataSource = self
      self.collectionView.delegate = self
      
        //set the root view
      self.view = rootView
      
    }
  
  
  
  
    override func viewDidLoad() {

      
      super.viewDidLoad()
      
      
      //create the GalleryCell object that the collection will use
      self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERY_CELL")
      
      //create a handle for the images
      let image1 = UIImage(named: "galleryImg1.jpeg")
      let image2 = UIImage(named: "galleryImg2.jpeg")
      let image3 = UIImage(named: "galleryImg3.jpeg")
      let image4 = UIImage(named: "galleryImg4.jpeg")
      let image5 = UIImage(named: "galleryImg5.jpeg")
      let image6 = UIImage(named: "galleryImg6.jpeg")
      let image7 = UIImage(named: "galleryImg7.jpg")
      
      
      println("return array length \(galleryImageArray.count)")
      
      //add them to the image array
      self.galleryImageArray.append(image1!)
      self.galleryImageArray.append(image2!)
      self.galleryImageArray.append(image3!)
      self.galleryImageArray.append(image4!)
      self.galleryImageArray.append(image5!)
      self.galleryImageArray.append(image6!)
      self.galleryImageArray.append(image7!)
      
      //add zoom functionality to collection view
      let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "collectionViewPinched:")
      self.collectionView.addGestureRecognizer(pinchRecognizer)
      
      
    }

  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    //MARK: Handlers UICollectionViewDataSource / managing the CELL
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  
    return self.galleryImageArray.count
  
  }
  
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
  
    //draw the cell as a GalleryCell using the "GALLERY_CELL" as identifier
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
    
    //cell.backgroundColor = UIColor.whiteColor()
    
    //pull the image from the gallery array
    let image = self.galleryImageArray[indexPath.row]
    

    //add the image to the cell
    cell.imageView.image = image
    
    return cell
  
  }
  
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
         println("passing image \(self.galleryImageArray[indexPath.row])")
    
    self.delegate?.controllerDidSelectImage(self.galleryImageArray[indexPath.row],true)
    
    //self.navigationController?.popViewControllerAnimated(true)
    self.navigationController?.popToRootViewControllerAnimated(true)
    
    
  }
  
    //MARK: Handlers for Touch Gesture Recognizers
  
  func collectionViewPinched(sender : UIPinchGestureRecognizer){
      
      switch sender.state {
      
      case .Began:
        
        println("began")
      
        
      case .Changed:
        
        println("changed with velocity \(sender.velocity)")
      

        self.collectionView.performBatchUpdates({ () -> Void in
          
          if sender.velocity > 0 {
            //increase item size
            
            let newSize = CGSize(width: self.collectionViewFlowLayout.itemSize.width*2, height: self.collectionViewFlowLayout.itemSize.height*2)
            self.collectionViewFlowLayout.itemSize = newSize
          }
            
          else if sender.velocity < 0 {
            let newSize = CGSize(width: self.collectionViewFlowLayout.itemSize.width/2, height: self.collectionViewFlowLayout.itemSize.height/2)
            self.collectionViewFlowLayout.itemSize = newSize
            //decrease item size
          }
          
          
          }, completion: {(finished) -> Void in
            
        })
        
        
      case .Ended:
      
        println("ended")
        

        
      default:
        println("default")
      }
      println("Photo Gallery collection view being resized")
      
    }
  
  
}


