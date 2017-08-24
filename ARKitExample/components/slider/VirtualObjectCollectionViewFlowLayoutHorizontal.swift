//
//  VirtualObjectCollectionViewFlowLayoutHorizontal.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 07/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class VirtualObjectCollectionViewFlowLayoutHorizontal: VirtualObjectCollectionViewFlowLayoutHorizontalFullscreen {
    
    let itemAspectRatio: CGFloat = 1
    
    override var minimumLineSpacing: CGFloat {
        return 5
    }
    
    override var itemSize: CGSize {
        guard let frame = frame else { return CGSize.zero }
        let height = frame.height * 0.9
        return CGSize(width: height * itemAspectRatio, height: height)
    }
    
    override var startOffset: CGFloat {
        guard let frame = frame else { return 0 }
        return (frame.width - itemSize.width) / 2.0
    }
    
    override var itemLength: CGFloat {
        return itemSize.width + minimumLineSpacing
    }
    
    override func getFrameForIndexPath(_ indexPath: IndexPath) -> CGRect {
        guard let frame = frame else { return CGRect.zero }
        var superFrame = super.getFrameForIndexPath(indexPath)
        superFrame.origin.y = (frame.height - itemSize.height) / 2.0
        return superFrame
    }
    
    override func getLayoutAttributesForItemAtIndexPath(_ index: Int, offset: CGPoint, layoutAttributes: VirtualObjectCollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes? {
        let cellOffset = offset.x - (CGFloat(index) * itemLength)
        let offsetPercentage = min(abs(cellOffset) / itemLength, 0.5)
        let scaleOffset = offsetPercentage / 2
        let scale = 1 - scaleOffset
        layoutAttributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        return layoutAttributes
    }
}
