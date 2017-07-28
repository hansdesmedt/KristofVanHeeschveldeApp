/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The virtual candle.
*/

import Foundation
import SceneKit

class Kristof: VirtualObject {
	
	override init() {
		super.init(modelName: "kristof", fileExtension: "scn", thumbImageFilename: "candle", title: "Candle")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
