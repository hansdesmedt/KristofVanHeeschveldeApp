//
//  Circle.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 04/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit

class Circle: VirtualObject {
    
    override init() {
        super.init(modelName: "circle", fileExtension: "scn", thumbImageFilename: "icon_hans", title: "Circle")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
