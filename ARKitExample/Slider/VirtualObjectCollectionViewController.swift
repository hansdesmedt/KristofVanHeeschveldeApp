//
//  VirtualObjectCollectionViewController.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 05/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class VirtualObjectCollectionViewController: UICollectionViewController {
  
  //    override func viewDidLoad() {
  //        super.viewDidLoad()
  //        collectionView?.contentInset.left = UIScreen.main.bounds.width / 2.0
  //        collectionView?.contentInset.right = UIScreen.main.bounds.width / 2.0
  //    }
  
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
    return cell
  }
}
