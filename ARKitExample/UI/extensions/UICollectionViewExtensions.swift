//
//  CollectionViewExtension.swift
//  collectionViewLayoutTest
//
//  Created by Hans De Smedt on 01/09/16.
//  Copyright Â© 2016 Hans De Smedt. All rights reserved.
//

import UIKit

extension UICollectionView {
  
  var totalNumberOfItems: Int {
    var nr = 0
    for i in 0..<numberOfSections {
      nr += numberOfItems(inSection: i)
    }
    return nr
  }
  
  func indexPathForItemIndex(_ item: Int) -> IndexPath? {
    var itemIndex = item
    for i in 0..<numberOfSections {
      if itemIndex > numberOfItems(inSection: i) - 1 {
        itemIndex -= numberOfItems(inSection: i)
      } else {
        return IndexPath(item: itemIndex, section: i)
      }
    }
    return nil
  }
  
  func itemIndexForIndexPath(_ indexPath: IndexPath) -> Int {
    var itemIndex = indexPath.item
    for i in 0..<indexPath.section {
      itemIndex += numberOfItems(inSection: i)
    }
    return itemIndex
  }
}
