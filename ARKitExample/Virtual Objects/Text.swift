//
//  Text.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 04/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit

class Text: VirtualObject {
    
    override init() {
        super.init(modelName: "text", fileExtension: "scn", thumbImageFilename: "icon_text", title: "Text")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

