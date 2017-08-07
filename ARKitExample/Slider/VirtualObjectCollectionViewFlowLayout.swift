//
//  VirtualObjectCollectionViewFlowLayout.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 07/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

protocol CollectionViewFlowLayoutProtocol: class {
    var minimumLineSpacing: CGFloat { get }
    var frame: CGRect? { get set }
    var numberOfItems: Int? { get set }
    var itemSize: CGSize { get }
    var itemLength: CGFloat { get }
    func getFrameForIndexPath(_ indexPath: IndexPath) -> CGRect
    func getCollectionViewContentSize(_ superContentSize: CGSize) -> CGSize
    func getLayoutAttributesForItemAtIndexPath(_ index: Int, offset: CGPoint, layoutAttributes: VirtualObjectCollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes?
    func getTargetContentOffsetForCenterItem(_ centerItemIndex: Int) -> CGPoint
    func getTargetContentOffsetForVelocity(_ velocity: CGPoint, offset: CGPoint) -> CGPoint
    func getCenterIndexForOffset(_ offset: CGPoint) -> Int
}

enum LayoutState: Int {
    case horizontal
}

class VirtualObjectCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var layoutState: LayoutState = LayoutState.horizontal {
        didSet {
            scrollDirection = .horizontal
            invalidateLayout()
        }
    }
    
    var centerItemIndex: Int = 0
    var layoutInfo: [IndexPath:UICollectionViewLayoutAttributes] = [IndexPath:UICollectionViewLayoutAttributes]()
    
    var layoutHorizontal: CollectionViewFlowLayoutProtocol?
    var layout: CollectionViewFlowLayoutProtocol? {
        get {
            switch layoutState {
            case .horizontal:
                return layoutHorizontal
            }
        }
    }
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        layoutHorizontal = VirtualObjectCollectionViewFlowLayoutHorizontal()
        
        guard let layout = layout else { return }
        minimumInteritemSpacing = 0
        minimumLineSpacing = layout.minimumLineSpacing
    }
    
    override func prepare() {
        guard let layout = layout, let collectionView = collectionView else {
            super.prepare()
            return
        }
        
        layout.numberOfItems = collectionView.numberOfItems(inSection: 0)
        layout.frame = collectionView.frame
        
        minimumLineSpacing = layout.minimumLineSpacing
        itemSize = layout.itemSize
        
        super.prepare()
        
        layoutInfo = getLayoutInfo()
    }
    
    override var collectionViewContentSize : CGSize {
        let contentSize = super.collectionViewContentSize
        guard let layout = layout else { return CGSize.zero }
        return layout.getCollectionViewContentSize(contentSize)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        for (indexPath, attributes) in layoutInfo {
            if rect.intersects(attributes.frame) {
                if let attributes = layoutAttributesForItem(at: indexPath) {
                    allAttributes.append(attributes)
                }
            }
        }
        return allAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = layoutInfo[indexPath], let layout = layout, let collectionView = collectionView else { return nil }
        let homeLayoutAttributes = VirtualObjectCollectionViewLayoutAttributes(forCellWith: indexPath)
        homeLayoutAttributes.frame = layoutAttributes.frame
        let index = collectionView.itemIndexForIndexPath(indexPath)
        let offset = collectionView.contentOffset
        return layout.getLayoutAttributesForItemAtIndexPath(index, offset: offset, layoutAttributes: homeLayoutAttributes)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let layout = layout else { return proposedContentOffset }
        return layout.getTargetContentOffsetForCenterItem(centerItemIndex)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let layout = layout, let collectionView = collectionView else { return proposedContentOffset }
        let contentOffset = collectionView.contentOffset
        let offset = layout.getTargetContentOffsetForVelocity(velocity, offset: contentOffset)
        centerItemIndex = layout.getCenterIndexForOffset(offset)
        return offset
        
    }
    
    fileprivate func getLayoutInfo() -> [IndexPath:UICollectionViewLayoutAttributes] {
        var layoutInfo = [IndexPath:UICollectionViewLayoutAttributes]()
        guard let collectionView = collectionView, let layout = layout, collectionView.numberOfItems(inSection: 0) - 1 >= 0 else { return layoutInfo }
        for i in 0...collectionView.numberOfItems(inSection: 0) - 1 {
            let indexPath = IndexPath(row: i, section: 0)
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            itemAttributes.frame = layout.getFrameForIndexPath(indexPath)
            layoutInfo[indexPath] = itemAttributes
        }
        return layoutInfo
    }
    
    func setLayoutToVertical(_ frame: CGRect, animated: Bool) {
        guard let layoutVertical = layoutHorizontal else { return }
        setLayoutTo(layoutVertical, frame: frame, animated: animated)
    }
    
    fileprivate func setLayoutTo(_ layout: CollectionViewFlowLayoutProtocol, frame: CGRect, animated: Bool) {
        guard let collectionView = collectionView else { return }
        layout.frame = frame
        collectionView.contentSize = layout.getCollectionViewContentSize(frame.size)
        let offset = layout.getTargetContentOffsetForCenterItem(centerItemIndex)
        collectionView.setContentOffset(offset, animated: animated)
    }
}
