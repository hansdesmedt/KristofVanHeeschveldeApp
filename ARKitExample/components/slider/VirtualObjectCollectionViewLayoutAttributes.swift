//
//  VirtualObjectsCollectionViewLayoutAttributes.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 07/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class VirtualObjectCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var visibility: CGFloat = 1
    
    override func copy(with zone: NSZone?) -> Any {
        let newAttributes = super.copy(with: zone)
        (newAttributes as? VirtualObjectCollectionViewLayoutAttributes)?.visibility = visibility
        return newAttributes
    }
}
