/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The virtual candle.
*/

import Foundation
import SceneKit

class Box: VirtualObject {
	
	override init() {
		super.init(modelName: "box", fileExtension: "scn", thumbImageFilename: "icon_hans", title: "Box")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
