//
//  VirtualObjectCollectionViewCell.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 05/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class VirtualObjectCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  
  fileprivate var lastSize = CGSize.zero
  
  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    
    guard layoutAttributes is VirtualObjectCollectionViewLayoutAttributes else {
      return super.apply(layoutAttributes)
    }
    
    if !lastSize.equalTo(layoutAttributes.size) {
      lastSize = layoutAttributes.size
      
      //hack for setCollectionViewLayout to set layout correct
      UIView.animate(withDuration: 0, animations: {
        self.layoutIfNeeded()
      })
    }
  }
}
