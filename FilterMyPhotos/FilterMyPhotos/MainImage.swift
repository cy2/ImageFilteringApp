//
//  ImageToFilter.swift
//  FilterMyPhotos
//
//  Created by cm2y on 1/14/15.
//  Copyright (c) 2015 cm2y. All rights reserved.
//

import Foundation

import UIKit

class MainImage {
  
  var imageWidth : Int?
  var imageHeight : Int?
  
  var originalMainImage : UIImage?
  var filteredMainImage : UIImage?
  var filteredMainImageVersions: [UIImage]
  
  var filterName : String?
  var imageQueue : NSOperationQueue
  var gpuContext : CIContext

  
  
  init(operationQueue : NSOperationQueue, context : CIContext) {
    self.imageQueue = operationQueue
    self.gpuContext = context
    filteredMainImageVersions = []
    
  }
  
  
  
  func addfilteredMainImageVersion(filteredImage: UIImage ){
    
    filteredMainImageVersions.append(filteredImage)
    println("there are \(filteredMainImageVersions.count) filtered versions of the origional image")
    
  }
  
  
  func getOrigionalMainImage() -> UIImage{
    
    return self.originalMainImage!
    
  }
  
  
  
  func setOrigionalMainImage(selectedImage: UIImage){
    
    self.originalMainImage = selectedImage
    
  }
  
  
  
  func getfilteredMainImage() -> UIImage{
    
    return self.filteredMainImage!
    
  }
  
  
  
  func setfilteredMainImage(filteredImage: UIImage){
    
    self.filteredMainImage = filteredImage
    
  }
  
  
  
  func setMainImageSize(){
    
    let tempImage = CIImage(image: self.originalMainImage)
    
    let filter = CIFilter(name: "CISepiaTone")
    filter.setDefaults()
    filter.setValue(tempImage, forKey: kCIInputImageKey)
    
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage
    let extent = result.extent()
    
    imageHeight = Int(extent.height)
    println(imageHeight)
    
    imageWidth = Int(extent.width)
    println(imageWidth)
    
    
  }
  
  
  
  
  func generateFilteredImage( filterName : String, origionalImage: UIImage) -> UIImage{
    
    self.filterName = filterName
    let startImage = CIImage(image: origionalImage)
    
    let filter = CIFilter(name: self.filterName)
    filter.setDefaults()
    filter.setValue(startImage, forKey: kCIInputImageKey)
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage
    let extent = result.extent()
    
    imageHeight = Int(extent.height)
    println(imageHeight)
    
    imageWidth = Int(extent.width)
    println(imageWidth)
    
    
    let imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
    
    
    if( originalMainImage != nil ){
        self.filteredMainImage = UIImage(CGImage: imageRef, scale: self.originalMainImage!.scale, orientation: self.originalMainImage!.imageOrientation)
    }else{
      self.filteredMainImage = UIImage(CGImage: imageRef, scale: origionalImage.scale, orientation: origionalImage.imageOrientation)
    }
  
    
      if (self.filteredMainImage != nil){
        return self.filteredMainImage!
      }
      else{
        return self.originalMainImage!
      }
    
  }
  
}

