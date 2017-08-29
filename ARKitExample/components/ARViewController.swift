//
//  ARViewController.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 25/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import ARKit

class ARViewController: UIViewController {

  // var use3DOFTracking = false
  private let sessionConfig = ARWorldTrackingConfiguration()
  private var screenCenter: CGPoint?
  private var session = ARSession()
  private var focusSquare = FocusSquare()
  private var virtualObject: VirtualObject?
  private var hitTestVisualization: HitTestVisualization?
  // ARSCNViewDelegate
  private var planes = [ARPlaneAnchor: Plane]()
  
  @IBOutlet private var sceneView: ARSCNView! {
    didSet {
      sceneView.delegate = self
      sceneView.session = session
      sceneView.antialiasingMode = .multisampling4X
      sceneView.automaticallyUpdatesLighting = false
      sceneView.preferredFramesPerSecond = 60
      sceneView.contentScaleFactor = 1.3
      screenCenter = sceneView.bounds.mid
      if let camera = sceneView.pointOfView?.camera {
        camera.wantsHDR = true
        camera.wantsExposureAdaptation = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
      }
      sceneView.scene.lightingEnvironment.intensity = 25
      sceneView.scene.rootNode.addChildNode(focusSquare)
      //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }
  }
  
  private func updateFocusSquare() {
    guard let screenCenter = screenCenter else { return }
    
    if let virtualObject = virtualObject, let pointOfView = sceneView.pointOfView, sceneView.isNode(virtualObject, insideFrustumOf: pointOfView) {
      focusSquare.hide()
    } else {
      focusSquare.unhide()
    }

    let (worldPos, planeAnchor, _) = sceneView.worldPositionFromScreenPosition(screenCenter, objectPos: focusSquare.position)
    if let worldPos = worldPos {
      focusSquare.update(for: worldPos, planeAnchor: planeAnchor, camera: session.currentFrame?.camera)
    }
  }
  
  func resetVirtualObject() {
    virtualObject?.unloadModel()
    virtualObject?.removeFromParentNode()
    virtualObject = nil
  }

  func restartPlaneDetection() {
    sessionConfig.planeDetection = .horizontal
    session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    session.run(sessionConfig)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    session.pause()
  }
}
extension ARViewController {
  func session(_ session: ARSession, didFailWithError error: Error) {
    
  }
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    
  }
  
  func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
    
  }
}

extension ARViewController: ARSCNViewDelegate {
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      self.updateFocusSquare()
      self.hitTestVisualization?.render()
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    DispatchQueue.main.async {
      if let planeAnchor = anchor as? ARPlaneAnchor {
        self.addPlane(node: node, anchor: planeAnchor)
        sceneView.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor)
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    DispatchQueue.main.async {
      if let planeAnchor = anchor as? ARPlaneAnchor {
        self.removePlane(anchor: planeAnchor)
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    DispatchQueue.main.async {
      if let planeAnchor = anchor as? ARPlaneAnchor {
        self.updatePlane(anchor: planeAnchor)
        sceneView.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor)
      }
    }
  }
  
  func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
    let plane = Plane(anchor)
    planes[anchor] = plane
    node.addChildNode(plane)
  }
  
  func updatePlane(anchor: ARPlaneAnchor) {
    if let plane = planes[anchor] {
      plane.update(anchor)
    }
  }
  
  func removePlane(anchor: ARPlaneAnchor) {
    if let plane = planes.removeValue(forKey: anchor) {
      plane.removeFromParentNode()
    }
  }
}
