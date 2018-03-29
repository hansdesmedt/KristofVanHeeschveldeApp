/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Main view controller for the AR experience.
 */

import ARKit
import Foundation
import SceneKit
import UIKit
import Photos

// bij tap
// loadVirtualObject(at: index)?

// Start the ARSession.
//restartPlaneDetection()

class ViewController: UIViewController, ARSCNViewDelegate, UIPopoverPresentationControllerDelegate {
  
  // MARK: - Main Setup & View Controller methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupScene()
    setupFocusSquare()
    resetVirtualObject()
  }
  
  var snapshot: UIImage {
    return sceneView.snapshot()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // Prevent the screen from being dimmed after a while.
    UIApplication.shared.isIdleTimerDisabled = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    session.pause()
  }
  
  // MARK: - ARKit / ARSCNView
  private let session = ARSession()
  private var sessionConfig: ARConfiguration = ARWorldTrackingConfiguration()
  private var use3DOFTracking = false {
    didSet {
      if use3DOFTracking {
        sessionConfig = ARWorldTrackingConfiguration()
      }
      sessionConfig.isLightEstimationEnabled = true
      session.run(sessionConfig)
    }
  }
  private var use3DOFTrackingFallback = false
  @IBOutlet private var sceneView: ARSCNView!
  private var screenCenter: CGPoint?
  
  private func setupScene() {
    // set up sceneView
    sceneView.delegate = self
    sceneView.session = session
    sceneView.antialiasingMode = .multisampling4X
    sceneView.automaticallyUpdatesLighting = false
    
    sceneView.preferredFramesPerSecond = 60
    sceneView.contentScaleFactor = 1.3
    //sceneView.showsStatistics = true
    
    enableEnvironmentMapWithIntensity(25.0)
    
    DispatchQueue.main.async {
      self.screenCenter = self.sceneView.bounds.mid
    }
    
    if let camera = sceneView.pointOfView?.camera {
      camera.wantsExposureAdaptation = true
      camera.exposureOffset = -1
      camera.minimumExposure = -1
    }
  }
  
  private func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
    if sceneView.scene.lightingEnvironment.contents == nil {
      if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
        sceneView.scene.lightingEnvironment.contents = environmentMap
      }
    }
    sceneView.scene.lightingEnvironment.intensity = intensity
  }
  
  // MARK: - ARSCNViewDelegate
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      self.updateFocusSquare()
      
      // If light estimation is enabled, update the intensity of the model's lights and the environment map
      if let lightEstimate = self.session.currentFrame?.lightEstimate {
        self.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40)
      } else {
        self.enableEnvironmentMapWithIntensity(25)
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    DispatchQueue.main.async {
      if let planeAnchor = anchor as? ARPlaneAnchor {
        self.addPlane(node: node, anchor: planeAnchor)
        self.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor)
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    DispatchQueue.main.async {
      if let planeAnchor = anchor as? ARPlaneAnchor {
        self.updatePlane(anchor: planeAnchor)
        self.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor)
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
  
  private var trackingFallbackTimer: Timer?
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .limited:
      if use3DOFTrackingFallback {
        // After 10 seconds of limited quality, fall back to 3DOF mode.
        trackingFallbackTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { _ in
          self.use3DOFTracking = true
          self.trackingFallbackTimer?.invalidate()
          self.trackingFallbackTimer = nil
        })
      }
    case .normal:
      if use3DOFTrackingFallback && trackingFallbackTimer != nil {
        trackingFallbackTimer!.invalidate()
        trackingFallbackTimer = nil
      }
    case .notAvailable:
      return
    }
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    
    guard let arError = error as? ARError else { return }
    
    let nsError = error as NSError
    var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
    if let recoveryOptions = nsError.localizedRecoveryOptions {
      for option in recoveryOptions {
        sessionErrorMsg.append("\(option).")
      }
    }
    
    let isRecoverable = (arError.code == .worldTrackingFailed)
    if isRecoverable {
      sessionErrorMsg += "\nYou can try resetting the session or quit the application."
    } else {
      sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
    }
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
    restartExperience()
  }
  
  // MARK: - Ambient Light Estimation
  
  private func toggleAmbientLightEstimation(_ enabled: Bool) {
    
    if enabled {
      if !sessionConfig.isLightEstimationEnabled {
        // turn on light estimation
        sessionConfig.isLightEstimationEnabled = true
        session.run(sessionConfig)
      }
    } else {
      if sessionConfig.isLightEstimationEnabled {
        // turn off light estimation
        sessionConfig.isLightEstimationEnabled = false
        session.run(sessionConfig)
      }
    }
  }
  
  // MARK: - Gesture Recognizers
  
  private var currentGesture: Gesture?
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let object = virtualObject else {
      loadVirtualObject(at: 0)
      return
    }
    
    if currentGesture == nil {
      currentGesture = Gesture.startGestureFromTouches(touches, self.sceneView, object)
    } else {
      currentGesture = currentGesture!.updateGestureFromTouches(touches, .touchBegan)
    }
    
    displayVirtualObjectTransform()
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if virtualObject == nil {
      return
    }
    currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchMoved)
    displayVirtualObjectTransform()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchEnded)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    if virtualObject == nil {
      return
    }
    currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchCancelled)
  }
  
  // MARK: - Virtual Object Manipulation
  
  private func displayVirtualObjectTransform() {
    guard let object = virtualObject else {
      return
    }
    var angleDegrees = Int(((object.eulerAngles.y) * 180) / Float.pi) % 360
    if angleDegrees < 0 {
      angleDegrees += 360
    }
  }
  
  func moveVirtualObjectToPosition(_ pos: SCNVector3?, _ instantly: Bool, _ filterPosition: Bool) {
    
    guard let newPosition = pos else {
      // Reset the content selection in the menu only if the content has not yet been initially placed.
      if virtualObject == nil {
        resetVirtualObject()
      }
      return
    }
    
    if instantly {
      setNewVirtualObjectPosition(newPosition)
    } else {
      updateVirtualObjectPosition(newPosition, filterPosition)
    }
  }
  
  private var dragOnInfinitePlanesEnabled = false
  
  func worldPositionFromScreenPosition(_ position: CGPoint,
                                       objectPos: SCNVector3?,
                                       infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
    
    // -------------------------------------------------------------------------------
    // 1. Always do a hit test against exisiting plane anchors first.
    //    (If any such anchors exist & only within their extents.)
    
    let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
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
    
    let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
    
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
      
      let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
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
    
    let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
    if !unfilteredFeatureHitTestResults.isEmpty {
      let result = unfilteredFeatureHitTestResults[0]
      return (result.position, nil, false)
    }
    
    return (nil, nil, false)
  }
  
  // Use average of recent virtual object distances to avoid rapid changes in object scale.
  private var recentVirtualObjectDistances = [CGFloat]()
  
  private func setNewVirtualObjectPosition(_ pos: SCNVector3) {
    
    guard let object = virtualObject, let cameraTransform = session.currentFrame?.camera.transform else {
      return
    }
    
    recentVirtualObjectDistances.removeAll()
    
    let cameraWorldPos = SCNVector3.positionFromTransform(cameraTransform)
    var cameraToPosition = pos - cameraWorldPos
    
    // Limit the distance of the object from the camera to a maximum of 10 meters.
    cameraToPosition.setMaximumLength(10)
    
    object.position = cameraWorldPos + cameraToPosition
    
    if object.parent == nil {
      sceneView.scene.rootNode.addChildNode(object)
    }
  }
  
  private func resetVirtualObject() {
    virtualObject?.unloadModel()
    virtualObject?.removeFromParentNode()
    virtualObject = nil
  }
  
  private func updateVirtualObjectPosition(_ pos: SCNVector3, _ filterPosition: Bool) {
    guard let object = virtualObject else {
      return
    }
    
    guard let cameraTransform = session.currentFrame?.camera.transform else {
      return
    }
    
    let cameraWorldPos = SCNVector3.positionFromTransform(cameraTransform)
    var cameraToPosition = pos - cameraWorldPos
    
    // Limit the distance of the object from the camera to a maximum of 10 meters.
    cameraToPosition.setMaximumLength(10)
    
    // Compute the average distance of the object from the camera over the last ten
    // updates. If filterPosition is true, compute a new position for the object
    // with this average. Notice that the distance is applied to the vector from
    // the camera to the content, so it only affects the percieved distance of the
    // object - the averaging does _not_ make the content "lag".
    let hitTestResultDistance = CGFloat(cameraToPosition.length())
    
    recentVirtualObjectDistances.append(hitTestResultDistance)
    recentVirtualObjectDistances.keepLast(10)
    
    if filterPosition {
      let averageDistance = recentVirtualObjectDistances.average!
      
      cameraToPosition.setLength(Float(averageDistance))
      let averagedDistancePos = cameraWorldPos + cameraToPosition
      
      object.position = averagedDistancePos
    } else {
      object.position = cameraWorldPos + cameraToPosition
    }
  }
  
  private func checkIfObjectShouldMoveOntoPlane(anchor: ARPlaneAnchor) {
    guard let object = virtualObject, let planeAnchorNode = sceneView.node(for: anchor) else {
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
  
  // MARK: - Virtual Object Loading
  
  private var virtualObject: VirtualObject?
  
  func loadVirtualObject(at index: Int) {
    resetVirtualObject()

    // Load the content asynchronously.
    DispatchQueue.global().async {
      let object = VirtualObject.availableObjects[index]
      object.viewController = self
      self.virtualObject = object
      
      object.loadModel()
      
      DispatchQueue.main.async {
        // Immediately place the object in 3D space.
        if let lastFocusSquarePos = self.focusSquare?.lastPosition {
          self.setNewVirtualObjectPosition(lastFocusSquarePos)
        } else {
          self.setNewVirtualObjectPosition(SCNVector3Zero)
        }
      }
    }
  }
  
  // MARK: - Planes
  
  private var planes = [ARPlaneAnchor: Plane]()
  
  private func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
    let plane = Plane(anchor, false)
    
    planes[anchor] = plane
    node.addChildNode(plane)
  }
  
  private func updatePlane(anchor: ARPlaneAnchor) {
    if let plane = planes[anchor] {
      plane.update(anchor)
    }
  }
  
  private func removePlane(anchor: ARPlaneAnchor) {
    if let plane = planes.removeValue(forKey: anchor) {
      plane.removeFromParentNode()
    }
  }
  
  func restartPlaneDetection() {
    
    // configure session
    if let worldSessionConfig = sessionConfig as? ARWorldTrackingConfiguration {
      worldSessionConfig.planeDetection = .horizontal
      session.run(worldSessionConfig, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // reset timer
    if trackingFallbackTimer != nil {
      trackingFallbackTimer!.invalidate()
      trackingFallbackTimer = nil
    }
  }
  
  // MARK: - Focus Square
  private var focusSquare: FocusSquare?
  
  private func setupFocusSquare() {
    focusSquare?.isHidden = true
    focusSquare?.removeFromParentNode()
    focusSquare = FocusSquare()
    sceneView.scene.rootNode.addChildNode(focusSquare!)
  }
  
  private func updateFocusSquare() {
    guard let screenCenter = screenCenter else { return }
    
    if virtualObject != nil && sceneView.isNode(virtualObject!, insideFrustumOf: sceneView.pointOfView!) {
      focusSquare?.hide()
    } else {
      focusSquare?.unhide()
    }
    let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(screenCenter, objectPos: focusSquare?.position)
    if let worldPos = worldPos {
      focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
    }
  }

  private func restartExperience() {
    DispatchQueue.main.async {
      self.use3DOFTracking = false
      self.setupFocusSquare()
      self.resetVirtualObject()
      self.restartPlaneDetection()
    }
  }
}
