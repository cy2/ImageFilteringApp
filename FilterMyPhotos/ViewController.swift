//
//  ViewController.swift
//  FilterMyPhotos
//
//  Created by cm2y on 1/12/15.
//  Copyright (c) 2015 cm2y. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, ImageSelectedProtocol, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate {
  
  //global variables (properties)
  
   //LOCALIZED STRING: Alert Controller
  //let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: UIAlertControllerStyle.ActionSheet)
  let alertController = UIAlertController(title: NSLocalizedString("Filter Your Photos", comment: "This is the title for our alert controller"), message: NSLocalizedString("What would you like to do with your image", comment: "This is the message for our alert controller"), preferredStyle: UIAlertControllerStyle.ActionSheet)
  
  //create the main image view
  let mainImageView = UIImageView()
  
  //create a main image object
  var myMainImage : MainImage!
  
  var myMainImageHeight : Int!
  
  var myMainImageWidth : Int!
  
  
  //create the thumbnail support structures
  var collectionView : UICollectionView!
 
  //constraint that shows where filters collection displays on screen
  var collectionViewYConstraint : NSLayoutConstraint!
  
  var mainImageTopX: NSLayoutConstraint!
  var mainImageTopY : NSLayoutConstraint!
  var mainImageBottomX: NSLayoutConstraint!
  var mainImageBottomY : NSLayoutConstraint!
  
  //constraint for mainImage's width and height
  var mainImageViewSizeConstraint : NSLayoutConstraint!
  
  var originalThumbnail : UIImage!
  
  //create an array of strings for the filter names
  var filterNames = [String]()
  
  //lazy loading background queue for images
  let imageQueue = NSOperationQueue()
  
  //the context that will be creating the images
  var gpuContext : CIContext!
  
  //create an array to hold the thumbnail images
  var thumbnails = [Thumbnail]()
  
  //nav bar buttons
  var doneButton : UIBarButtonItem!
  var shareButton : UIBarButtonItem!

  
  //lay out screen
  override func loadView() {
     println("loadView() fired")
    

    //create the GPU context
    let options = [kCIContextWorkingColorSpace : NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    
    
    //>MODEL
    
    //create a main image object
    myMainImage = MainImage(operationQueue: self.imageQueue, context: self.gpuContext)
    
    
    //create the thumbnails with Filters using the GPU
    self.createThumbnailsWithFilters()
    
    
    
    
    //>VIEWS
    
          //create the root view container
        let rootView = UIView(frame: UIScreen.mainScreen().bounds)
          //set the bg image
        rootView.backgroundColor = UIColor(patternImage: UIImage(named: "FilterMyPhotos_background.jpg")!)
    
    
        //add the main image subview to the root container
      rootView.addSubview(self.mainImageView)
    
        self.mainImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
          //test where main image displays
         //self.mainImageView.backgroundColor = UIColor.whiteColor()
    
    
    //create the thumbnail collection view
    let collectionviewFlowLayout = UICollectionViewFlowLayout()
    
    
        //draw a collection view rectangle
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionviewFlowLayout)
        //set the item size to 100 x 100
        collectionviewFlowLayout.itemSize = CGSize(width: 100, height: 100)
    
        collectionviewFlowLayout.scrollDirection = .Horizontal
    
     rootView.addSubview(collectionView)
    
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
        //collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "FilterMyPhotos_blankBackground.JPG")!)
    
        collectionView.dataSource = self
    
        collectionView.delegate = self
    
      //create the collection view for image filter
        collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "FILTER_CELL")
    

    
    //Create the first view's button
    let photoButton = UIButton()
    
    //turn off resizing mask
    photoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    //add button to the view
    rootView.addSubview(photoButton)
    
    //color the button
    photoButton.setTitleColor(UIColor.redColor(), forState: .Normal)
    
    
    //LOCALIZED STRING: Photos Button
    //photoButton.setTitle("Photos", forState: .Normal)
    photoButton.setTitle(NSLocalizedString("Filter My Photos", comment: "Translate: Filter My Photos directive"), forState: .Normal)
    
    
    //add the button click action
    photoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    
    
    
    //create an array to hold all of the subview objects
    let views = ["photoButton" : photoButton,"mainImageView" : mainImageView, "collectionView":collectionView]
    
    
    self.setupConstraintsOnRootView(rootView, forViews: views)
    
    //create the main view
    self.view = rootView
    
  }
  
  
  
  override func viewDidLoad() {
    println("viewDidLoad() fired")
    
    super.viewDidLoad()

    
    //NAV BAR
    
    
    self.doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "donePressed")//goto 
    
    self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "sharePressed")//goto
    
    //start out with share button showing
    self.navigationItem.rightBarButtonItem = self.shareButton
    
    
    /*ACTION: Camera view controler with AVFoundation
    if UIImagePickerController.isSourceTypeAvailable(AVFoundation ) {
    
    //create the camera alert
    let cameraOption = UIAlertAction(title: "AVFoundation", style: .Default, handler: { (action) -> Void in
    
    println("AVFoundation ACTION fired")
    
    
    })
    //add the action
    self.alertController.addAction(cameraOption)
    
    }
    */
    
    
    
    
    //ACTION: View Gallery
    
    let galleryOption = UIAlertAction(title: NSLocalizedString("Select an Image from your Gallery", comment: "Translate Select an Image from your Gallery"), style: UIAlertActionStyle.Default) { (action) -> Void in
      println("gallery pressed")
      
      let galleryVC = GalleryViewController()
      galleryVC.delegate = self
      self.navigationController?.pushViewController(galleryVC, animated: true)
    }
    self.alertController.addAction(galleryOption)
    
    
    
    //ACTION: Image picker
    
    let photoOption = UIAlertAction(title: NSLocalizedString("Select an Image from your Photos", comment: "Translate Select an Image from your Photos"), style: .Default) { (action) -> Void in
      
      println("PHOTO ACTION fired")
      
      //create a view controller
      let photosVC = PhotosViewController()
      
      //add it
      photosVC.destinationImageSize = self.mainImageView.frame.size
      
      //set the cell as delegate
      photosVC.delegate = self
      
      self.navigationController?.pushViewController(photosVC, animated: true)
      
    }
    
    self.alertController.addAction(photoOption)
    
    
    
    //ACTION: To bring up the camera
    
    //if the camera is availabe
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      
      //create the camera alert
      let cameraOption = UIAlertAction(title: NSLocalizedString("Take a Photo", comment: "Translate: take a Photo"), style: .Default, handler: { (action) -> Void in
        
        println("CAMERA ACTION fired")
        
        //create the picker
        let imagePickerController = UIImagePickerController()
        
        //give it a source type <enum> camera or photo library
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        
        //allow editing
        imagePickerController.allowsEditing = true
        
        //needs to be deligate
        imagePickerController.delegate = self
        
        //add the view controller
        self.presentViewController(imagePickerController, animated: true, completion: nil)
        
      })
      //add the action
      self.alertController.addAction(cameraOption)
      
    }
    
    
    // Now automatically shows after user selects a photo
    //ACTION: filter alert
    let filterOption = UIAlertAction(title: NSLocalizedString("Apply Filter to your selected Image", comment: "Translate: Apply Filter to your selected Image"), style: UIAlertActionStyle.Default) { (action) -> Void in
    println("FILTER ACTION fired")
    self.showFilter()
    }
    self.alertController.addAction(filterOption)
    
    
    // double tap handler
    let doubleTapOnMainImageGestureRecognizer = UITapGestureRecognizer(target: self, action: "doubleTapOnMainImgToRequestFilters:")
    doubleTapOnMainImageGestureRecognizer.numberOfTapsRequired = 2
    
    self.mainImageView.addGestureRecognizer(doubleTapOnMainImageGestureRecognizer)
    
  }
  
  
  func showFilter(){
    println("Showing filter window")
    
    //if someone is filtering image, swtch the button to a done button
    self.doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "donePressed")
    self.navigationItem.rightBarButtonItem = self.doneButton
    
    //bring the thumbnail collection back on screen by updating the Y value from -120 to 20
    self.collectionViewYConstraint.constant = 20
    
    //resize the main image
    self.mainImageTopX.constant = 82
    self.mainImageTopY.constant = 20
    self.mainImageBottomX.constant = 90
    self.mainImageBottomY.constant = 30
    
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      //force refresh the screen
      
      self.view.setNeedsLayout()
      
    })
    
    
  }
  
  
  
  
   //return the number of thumbnail images in collection
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    println("collectionView( numberOfItemsInSection ) fired")
    
    return self.thumbnails.count
  }
  
  
  //draw the collection of filter images
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
     println("collectionView( cellForItemAtIndexPath ) fired")
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as GalleryCell
    
    let thumbnail = self.thumbnails[indexPath.row]
    
    //loop through the thumbnail array and draw the cells
    if thumbnail.originalImage != nil {
      
      if thumbnail.filteredImage == nil {
      
        thumbnail.generateFilteredImage()
        
        cell.imageView.image = thumbnail.filteredImage!
        
        cell.imageView.layer.cornerRadius=20
        cell.imageView.layer.masksToBounds=true
        cell.backgroundColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "FilterMyPhotos_blankBackground.JPG")!)
      }else{
        cell.imageView.image = thumbnail.filteredImage!
      }
    
    }
    
    //cell.imageView.image = self.originalThumbnail
    
    return cell
  }
  
  
  
  
  
  
  
  
  
  
  //image picker required methods
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    println("imagePickerController( UIImagePickerController ) fired")
    
    
    let image = info[UIImagePickerControllerEditedImage] as? UIImage
    
    self.controllerDidSelectImage(image!,false)
    
    picker.dismissViewControllerAnimated(true, completion: nil)
  
  }
  
  
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    println("imagePickerControllerDidCancel( UIImagePickerController ) fired")
  
    //dismiss the view controller
    picker.dismissViewControllerAnimated(true, completion: nil)
  
  }
  

  
  
  // on click : swtitch out the main image for the filterd imae
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    println("collectionView( didSelectItemAtIndexPath ) fired")
    
    //figure out which filter was selected
    println("Applying filter name: \(filterNames[indexPath.row])")
   
    var filteredVersion = applyFilterToMainImage(filterNames[indexPath.row],origionalImage: self.mainImageView.image!)
    
      self.mainImageView.image = filteredVersion
    
      myMainImage.addfilteredMainImageVersion(filteredVersion)
    
  }
  
  
  
  //create the thumbnails
  func createThumbnailsWithFilters() {
    println("createThumbnailsWithFilters() fired")
    
    //fill the array of filter names
    self.filterNames = ["CISepiaTone","CIPhotoEffectChrome", "CIPhotoEffectNoir", "CIPixellate", "CIColorMonochrome", "CIFalseColor", "CIHatchedScreen", "CIColorPosterize", "CICircularScreen"]//others:"CIDotScreen",
    
    
    
    for name in self.filterNames {
      //create the thumbnail image object
      let thumbnail = Thumbnail(filterName: name, operationQueue: self.imageQueue, context: self.gpuContext)
      //add thumbnail to array of thumbnails
      self.thumbnails.append(thumbnail)
      
    }
  }
  
  func applyFilterToMainImage(selectedFiltersName: String, origionalImage: UIImage) -> UIImage{
    println("applying Filter to main image")
    
    let img = MainImage(operationQueue: self.imageQueue, context: self.gpuContext)
    var tintedImage : UIImage
    
    //always apply filter to the saved version of the origional image
    if(myMainImage.originalMainImage != nil){
      
        //always filter the origional image so you don't overlap filters
        tintedImage = img.generateFilteredImage(selectedFiltersName,origionalImage: myMainImage.originalMainImage!)
    
    }
    //unless it's the first time the filter's been called so use the passed in image
    else{
    
        tintedImage = img.generateFilteredImage(selectedFiltersName,origionalImage: origionalImage)
    
    }
    
    return tintedImage
  }
  
  //MARK:
  
  func controllerDidSelectImage(image: UIImage, _ filterRequired: Bool) {
    println("controllerDidSelectImage() fired \(image)")
    
    
    //update the origional image state
    myMainImage.setOrigionalMainImage(image)
    
    //update it's size
    myMainImage.setMainImageSize()
    
    //update local variables
    myMainImageHeight = myMainImage.imageHeight
    myMainImageWidth = myMainImage.imageWidth
    
    println("image dimentions = width:\(myMainImageWidth) height: \(myMainImageHeight)")
    println("call the function to preserve the aspect ration of main Image ")
    
    
    
    // VIEW
    
    //make the main page display an image
    self.mainImageView.image = image
    
    let temp : UIImage = image
    
    
    
    //create a thumbnail image of it
    self.generateThumbnail(image)
    
    //?
    for thumbnail in self.thumbnails {
      thumbnail.originalImage = self.originalThumbnail
    }
    
    
    if(filterRequired == true){
      
      showFilter()
      
    }
    

    //reload the data
    self.collectionView.reloadData()
  
  }

  
  //MARK: Handlers for Button Clicks
  
  
  //on click action for "Filter My Photos"
  func photoButtonPressed(sender : UIButton) {
    println("photoButtonPressed() fired")
    
    self.presentViewController(self.alertController, animated: true, completion: nil)
    
  }
  
  //on click action for "Done" button in nav bar
  func donePressed() {
    println("donePressed()")
    
    //rehide the filter thumnails
    self.collectionViewYConstraint.constant = -120
    
    
    //resize the main image
    self.mainImageTopX.constant = 72
    self.mainImageTopY.constant = 10
    self.mainImageBottomX.constant = 30
    self.mainImageBottomY.constant = 10
    
    //reset the main image
    self.controllerDidSelectImage(self.mainImageView.image!,false)
    
    
    //empty out the thumbnails array
    thumbnails.removeAll(keepCapacity: true)
    
    
    //update the thumbnail images with filter
    self.createThumbnailsWithFilters()
    
    //animate it
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      
      //reload page
      self.view.layoutIfNeeded()
      
    })
    
    //set the button on the nav bar to share
    self.navigationItem.rightBarButtonItem = self.shareButton
  }
  
  
  func sharePressed() {
    
    println("sharePressed() fired")
    //if the twitter service is available
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
      
      //create the view controller
      let compViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      //add the image
      compViewController.addImage(self.mainImageView.image)
      //present the view controller
      self.presentViewController(compViewController, animated: true, completion: nil)
      
    }
      
    else {
      //tell user to sign into to twitter to use this feature
    }
    
    
  }
  

  
  
    //create a thumbnail image by resizing a larger image
  func generateThumbnail(originalImage: UIImage) {
    println("generateThumbnail() fired")
    
    //create the size of the image
    let size = CGSize(width: 100, height: 100)
    
    //set up a context scratch pad to draw the image in memory
    UIGraphicsBeginImageContext(size)
    
    //go to origional image and draw it on the context scratch pad
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    
    //generate the thumbnail and grab image from the context
    self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
  
    //release context
    UIGraphicsEndImageContext()
  }
  
  
  
  
  //MARK: Manual Layout Constraints
  
  func setupConstraintsOnRootView(rootView : UIView, forViews views : [String : AnyObject]) {
    println("setupConstraintsOnRootView() fired")
  
  //Tell main Image how to display
  let mainImageViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[mainImageView]-10-|", options: nil, metrics: nil, views: views)
  rootView.addConstraints(mainImageViewConstraintsHorizontal)
  
  let mainImageViewConstraintsVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[mainImageView]-30-[photoButton]", options: nil, metrics: nil, views: views)
  rootView.addConstraints(mainImageViewConstraintsVertical)
  
  //grab a handle on the location of the main view to shrink it when somebody clicks on the filter button
  self.mainImageTopX = mainImageViewConstraintsVertical.first  as NSLayoutConstraint
  self.mainImageTopY = mainImageViewConstraintsHorizontal.first  as NSLayoutConstraint
  self.mainImageBottomX = mainImageViewConstraintsVertical.last as NSLayoutConstraint
  self.mainImageBottomY = mainImageViewConstraintsHorizontal.last as NSLayoutConstraint
    
  
  
  //Tell button how to display
  let photoButtonConstraintVertial = NSLayoutConstraint.constraintsWithVisualFormat("V:[photoButton]-20-|", options: nil, metrics: nil, views: views)
  
  rootView.addConstraints(photoButtonConstraintVertial)
  
  //create the view to hold the photobutton
  let photoButton = views["photoButton"] as UIView!
  
  //create the constraint
  let photoButtonConstraintHorizontal = NSLayoutConstraint(item: photoButton, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
  
  //add the button constraint to the container
  rootView.addConstraint(photoButtonConstraintHorizontal)
  
  
  
  //Tell the collection of Thumbnails how to display
  
  //pin the height of the collection view
  let collectionViewConstraintHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(100)]", options: nil, metrics: nil, views: views)
  
  
  
  //add the constrainst to the independant collection view
  self.collectionView.addConstraints(collectionViewConstraintHeight)
  
  //set the width
  let collectionViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: views)
  
  rootView.addConstraints(collectionViewConstraintsHorizontal)
  
  
  //set height - make it start offscreen
  let collectionViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(-120)-|", options: nil, metrics: nil, views: views)
  rootView.addConstraints(collectionViewConstraintVertical)
  
  
  //set the height value in global variable so you can chage it on click
  self.collectionViewYConstraint = collectionViewConstraintVertical.first as NSLayoutConstraint
  
  
  }
  
  
  //MARK: Handlers for Touch Gesture Recognizers
 
    //double tap action on the main image -> brings up the list of filters
  func doubleTapOnMainImgToRequestFilters(sender : UITapGestureRecognizer){

    if sender.state == .Ended {
      self.showFilter()
      println("default double tap case executed")
      
    }
    
    
  }
  
  
  
  override func didReceiveMemoryWarning() {
   println("didReceiveMemoryWarning() fired")
    
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}
