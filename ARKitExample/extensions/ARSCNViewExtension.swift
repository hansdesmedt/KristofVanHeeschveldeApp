//
//  SceneViewExtension.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 29/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import ARKit

extension ARSCNViewExtension {

  func worldPositionFromScreenPosition(_ position: CGPoint,
                                       objectPos: SCNVector3?,
                                       infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
    
    // -------------------------------------------------------------------------------
    // 1. Always do a hit test against exisiting plane anchors first.
    //    (If any such anchors exist & only within their extents.)
    
    let planeHitTestResults = hitTest(position, types: .existingPlaneUsingExtent)
    if let result = planeHitTestResults.first {
      
      let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
      let planeAnchor = result.anchor
      
      // Return immediately - this is the best possible outcome.
      return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
    }
    
    // -------------------------------------------------------------------------------
    // 2. Collect more information about the environment by hit testing against
    //    the feature point cloud, but do not return the result yet.
    
    var featureHitTestPosition: SCNVector3?
    var highQualityFeatureHitTestResult = false
    
    let highQualityfeatureHitTestResults = hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
    
    if !highQualityfeatureHitTestResults.isEmpty {
      let result = highQualityfeatureHitTestResults[0]
      featureHitTestPosition = result.position
      highQualityFeatureHitTestResult = true
    }
    
    // -------------------------------------------------------------------------------
    // 3. If desired or necessary (no good feature hit test result): Hit test
    //    against an infinite, horizontal plane (ignoring the real world).
    
    if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {
      
      let pointOnPlane = objectPos ?? SCNVector3Zero
      
      let pointOnInfinitePlane = hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
      if pointOnInfinitePlane != nil {
        return (pointOnInfinitePlane, nil, true)
      }
    }
    
    // -------------------------------------------------------------------------------
    // 4. If available, return the result of the hit test against high quality
    //    features if the hit tests against infinite planes were skipped or no
    //    infinite plane was hit.
    
    if highQualityFeatureHitTestResult {
      return (featureHitTestPosition, nil, false)
    }
    
    // -------------------------------------------------------------------------------
    // 5. As a last resort, perform a second, unfiltered hit test against features.
    //    If there are no features in the scene, the result returned here will be nil.
    
    let unfilteredFeatureHitTestResults = hitTestWithFeatures(position)
    if !unfilteredFeatureHitTestResults.isEmpty {
      let result = unfilteredFeatureHitTestResults[0]
      return (result.position, nil, false)
    }
    
    return (nil, nil, false)
  }
  
  func checkIfObjectShouldMoveOntoPlane(anchor: ARPlaneAnchor) {
    guard let object = virtualObject, let planeAnchorNode = node(for: anchor) else {
      return
    }
    
    // Get the object's position in the plane's coordinate system.
    let objectPos = planeAnchorNode.convertPosition(object.position, from: object.parent)
    
    if objectPos.y == 0 {
      return; // The object is already on the plane - nothing to do here.
    }
    
    // Add 10% tolerance to the corners of the plane.
    let tolerance: Float = 0.1
    
    let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
    let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
    let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
    let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance
    
    if objectPos.x < minX || objectPos.x > maxX || objectPos.z < minZ || objectPos.z > maxZ {
      return
    }
    
    // Drop the object onto the plane if it is near it.
    let verticalAllowance: Float = 0.03
    if objectPos.y > -verticalAllowance && objectPos.y < verticalAllowance {
      SCNTransaction.begin()
      SCNTransaction.animationDuration = 0.5
      SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      object.position.y = anchor.transform.columns.3.y
      SCNTransaction.commit()
    }
  }
}
