/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The virtual candle.
*/

import Foundation
import SceneKit

class Text3: VirtualObject {
	
	override init() {
		super.init(modelName: "text3", fileExtension: "scn", thumbImageFilename: "text3", title: "Text3")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
