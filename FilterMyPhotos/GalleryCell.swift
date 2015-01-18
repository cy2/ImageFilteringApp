//
//  GalleryCell.swift
//  FilterMyPhotos
//
//  Created by cm2y on 1/13/15.
//  Copyright (c) 2015 cm2y. All rights reserved.
//

import Foundation

import UIKit

class GalleryCell: UICollectionViewCell {
  
  //create the image view cell/item for the gallery
  let imageView = UIImageView()
  
  override init(frame: CGRect) {
    
    println("creating gallery cell")
  
    super.init(frame: frame)
    
    self.addSubview(self.imageView)
    
    self.backgroundColor = UIColor.whiteColor()
    
    imageView.frame = self.bounds
  
  }
  
  required init(coder aDecoder: NSCoder) {
    
    super.init(coder: aDecoder)
  
  }
  

}
