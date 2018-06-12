//
//  VirtualObjectCollectionViewController.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 05/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import RxSwift

private let reuseIdentifier = "Cell"

class VirtualObjectCollectionViewController: UICollectionViewController {
  
  var objectLoaded = false
  let takeScreenshot = PublishSubject<Void>()
  let loadVirtualObject = PublishSubject<Int>()
  
  var layout: VirtualObjectCollectionViewFlowLayout? {
    return (collectionView?.collectionViewLayout as? VirtualObjectCollectionViewFlowLayout)
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return VirtualObject.availableObjects.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let reuse = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                   for: indexPath)
    guard let cell = reuse as? VirtualObjectCollectionViewCell else { return reuse }
    let object = VirtualObject.availableObjects[indexPath.row]
    if let  thumbnailImage = object.thumbImage {
      cell.imageView.image = thumbnailImage
    }
    
    // Configure the cell
    return reuse
  }
  
  //loadVirtualObject(at: index)
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.item == layout?.centerItemIndex {
      if !objectLoaded {
        loadVirtualObject.onNext(indexPath.item)
        objectLoaded = true
      } else {
        takeScreenshot.onNext(())
      }
      
    } else {
      scrollToIndexPath(indexPath)
    }
  }
  
  func scrollToIndexPath(_ indexPath: IndexPath, animated: Bool = true) {
    collectionView?.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: animated)
    layout?.centerItemIndex = indexPath.item
  }
}

extension VirtualObjectCollectionViewController {
  
  override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    if let centerIndex = layout?.centerItemIndex {
      loadVirtualObject.onNext(centerIndex)
    }
  }
  
  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if let centerIndex = layout?.centerItemIndex {
      loadVirtualObject.onNext(centerIndex)
    }
  }
}
