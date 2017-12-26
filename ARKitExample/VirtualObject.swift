/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Wrapper SceneKit node for virtual objects placed into the AR scene.
*/

import SceneKit
import ARKit

protocol ReactsToScale {
  func reactToScale()
}

class VirtualObject: SCNNode {
	
	var modelName: String = ""
	var fileExtension: String = ""
	var thumbImage: UIImage!
	var title: String = ""
	var modelLoaded: Bool = false
	
	override init() {
		super.init()
		self.name = "Virtual object root node"
	}
	
	init(modelName: String, fileExtension: String, thumbImageFilename: String, title: String) {
		super.init()
		self.name = "Virtual object root node"
		self.modelName = modelName
		self.fileExtension = fileExtension
		self.thumbImage = UIImage(named: thumbImageFilename)
		self.title = title
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func loadModel() {
		guard let virtualObjectScene = SCNScene(named: "\(modelName).\(fileExtension)", inDirectory: "Models.scnassets/\(modelName)") else {
			return
		}
		
		let wrapperNode = SCNNode()
		
		for child in virtualObjectScene.rootNode.childNodes {
			child.geometry?.firstMaterial?.lightingModel = .physicallyBased
			child.movabilityHint = .movable
			wrapperNode.addChildNode(child)
		}
		self.addChildNode(wrapperNode)
		
		modelLoaded = true
	}
	
	func unloadModel() {
		for child in self.childNodes {
			child.removeFromParentNode()
		}
		
		modelLoaded = false
	}
}
