//
//  VirtualObjectsCollectionViewFlowLayoutHorizontalFullscreen.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 07/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class VirtualObjectCollectionViewFlowLayoutHorizontalFullscreen: CollectionViewFlowLayoutProtocol {
    
    var minimumLineSpacing: CGFloat {
        return 0
    }
    
    var numberOfItems: Int?
    var frame: CGRect?
    
    var itemSize: CGSize {
        guard let frame = frame else { return CGSize.zero }
        return frame.size
    }
    
    var startOffset: CGFloat {
        return 0
    }
    
    var itemLength: CGFloat {
        return itemSize.width + minimumLineSpacing
    }
    
    func getFrameForIndexPath(_ indexPath: IndexPath) -> CGRect {
        let ypos = itemLength * CGFloat(indexPath.item)
        return CGRect(x: ypos + startOffset, y: 0, width: itemSize.width, height: itemSize.height)
    }
    
    func getCollectionViewContentSize(_ superContentSize: CGSize) -> CGSize {
        guard let numberOfItems = numberOfItems else { return superContentSize }
        let width = itemLength * CGFloat(numberOfItems) - minimumLineSpacing + startOffset * 2.0
        let height = superContentSize.height
        return CGSize(width: width, height: height)
    }
    
    func getLayoutAttributesForItemAtIndexPath(_ index: Int, offset: CGPoint, layoutAttributes: VirtualObjectCollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes? {
        layoutAttributes.transform = CGAffineTransform.identity
        layoutAttributes.alpha = 1
        layoutAttributes.visibility = 1
        return layoutAttributes
    }
    
    func getTargetContentOffsetForCenterItem(_ centerItemIndex: Int) -> CGPoint {
        let offsetLength = CGFloat(centerItemIndex) * itemLength
        return CGPoint(x: offsetLength, y: 0)
    }
    
    func getTargetContentOffsetForVelocity(_ velocity: CGPoint, offset: CGPoint) -> CGPoint {
        let offset = offset.x
        let restOffset = offset.truncatingRemainder(dividingBy: itemLength)
        let velocity = velocity.x
        var targetOffset = offset - restOffset
        if velocity > 0 || (velocity == 0 && restOffset > itemLength / 2) {
            targetOffset += itemLength
        }
        return CGPoint(x: floor(targetOffset), y: 0)
    }
    
    func getCenterIndexForOffset(_ offset: CGPoint) -> Int {
        guard let numberOfItems = numberOfItems else { return 0 }
        let index = Int((offset.x + (itemLength / 2)) / itemLength)
        return index > numberOfItems - 1 ? numberOfItems - 1 : index
    }
}
