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
import FirebaseAuth
import FirebaseDatabase
import PureLayout

class ViewController: UIViewController, ARSCNViewDelegate, UIPopoverPresentationControllerDelegate {
  
//  @IBOutlet weak var totalSubmitsBorderView: UIView!
//  @IBOutlet weak var timeBorderView: UIView!
  
  @IBOutlet var aboutView: UIView!
  @IBOutlet var appNumberView: UIView!
  
  @IBOutlet weak var submitProgressView: CircleProgressView!
  
  // MARK: - Main Setup & View Controller methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Setting.registerDefaults()


    
//    Auth.auth().signInAnonymously() { (user, error) in
//      //        let isAnonymous = user!.isAnonymous  // true
//      let uid = user!.uid
//      print(uid)
//
//      let ref = Database.database().reference()
//      ref.child("photos").setValue(["username": "test"])
//      ref.child("installs").setValue(["uuid": "test"])
//      //        ref.child("installs").setv
//    }
    
    //      let uid = Authe
    ////      let snapsRef = Database.database().reference().child("snaps")
    //      print(uid)
    
    // Prevent the screen from being dimmed after a while.
    UIApplication.shared.isIdleTimerDisabled = true
//    // Start the ARSession.
//    restartPlaneDetection()
    
//    totalSubmitsBorderView.layer.borderWidth = 2
//    totalSubmitsBorderView.layer.borderColor = UIColor.white.cgColor
//
//    timeBorderView.layer.borderWidth = 2
//    timeBorderView.layer.borderColor = UIColor.white.cgColor
    submitProgressView.progress = 0.3
    submitProgressView.clockwise = false
    submitProgressView.trackBackgroundColor = UIColor.clear
    submitProgressView.centerFillColor = UIColor.clear
    submitProgressView.trackFillColor = UIColor.red
    submitProgressView.trackWidth = 5
    submitProgressView.trackBorderColor = UIColor.white.withAlphaComponent(0.5)
    submitProgressView.trackBorderWidth = 5
  }
  
  @IBAction func onboardingPressed(_ sender: UIButton) {
    aboutView.toggle(superView: view, x: -155, y: -285)
  }
  
  @IBAction func numberAppPressed(_ sender: UIButton) {
    appNumberView.toggle(superView: view, x: 0, y: -285)
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let virtualObjectCollectionViewController = segue.destination as? VirtualObjectCollectionViewController {
      virtualObjectCollectionViewController.viewController = self
    }
  }
  

  // MARK: - ARKit / ARSCNView

  
  var trackingFallbackTimer: Timer?
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    textManager.showTrackingQualityInfo(for: camera.trackingState, autoHide: !self.showDebugVisuals)
    
    switch camera.trackingState {
    case .notAvailable:
      textManager.escalateFeedback(for: camera.trackingState, inSeconds: 5.0)
    case .limited:
      if use3DOFTrackingFallback {
        // After 10 seconds of limited quality, fall back to 3DOF mode.
        trackingFallbackTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { _ in
          self.use3DOFTracking = true
          self.trackingFallbackTimer?.invalidate()
          self.trackingFallbackTimer = nil
        })
      } else {
        textManager.escalateFeedback(for: camera.trackingState, inSeconds: 10.0)
      }
    case .normal:
      textManager.cancelScheduledMessage(forType: .trackingStateEscalation)
      if use3DOFTrackingFallback && trackingFallbackTimer != nil {
        trackingFallbackTimer!.invalidate()
        trackingFallbackTimer = nil
      }
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
    
    displayErrorMessage(title: "We're sorry!", message: sessionErrorMsg, allowRestart: isRecoverable)
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    textManager.blurBackground()
    textManager.showAlert(title: "Session Interrupted", message: "The session will be reset after the interruption has ended.")
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    textManager.unblurBackground()
    session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
    restartExperience(self)
    textManager.showMessage("RESETTING SESSION")
  }
  
  // MARK: - Ambient Light Estimation
  
  func toggleAmbientLightEstimation(_ enabled: Bool) {
    
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
  
  var currentGesture: Gesture?
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let object = virtualObject else {
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
    if virtualObject == nil {
      //      chooseObject(addObjectButton)
      return
    }
    
    currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchEnded)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    if virtualObject == nil {
      return
    }
    currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchCancelled)
  }
  
  // MARK: - Virtual Object Manipulation
  
  func displayVirtualObjectTransform() {
    
    guard let object = virtualObject, let cameraTransform = session.currentFrame?.camera.transform else {
      return
    }
    
    // Output the current translation, rotation & scale of the virtual object as text.
    
    let cameraPos = SCNVector3.positionFromTransform(cameraTransform)
    let vectorToCamera = cameraPos - object.position
    
    let distanceToUser = vectorToCamera.length()
    
    var angleDegrees = Int(((object.eulerAngles.y) * 180) / Float.pi) % 360
    if angleDegrees < 0 {
      angleDegrees += 360
    }
    
    let distance = String(format: "%.2f", distanceToUser)
    let scale = String(format: "%.2f", object.scale.x)
    textManager.showDebugMessage("Distance: \(distance) m\nRotation: \(angleDegrees)°\nScale: \(scale)x")
  }
  
  func moveVirtualObjectToPosition(_ pos: SCNVector3?, _ instantly: Bool, _ filterPosition: Bool) {
    
    guard let newPosition = pos else {
      textManager.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
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
  
  var dragOnInfinitePlanesEnabled = false
  

  
  // Use average of recent virtual object distances to avoid rapid changes in object scale.
  var recentVirtualObjectDistances = [CGFloat]()
  
  func setNewVirtualObjectPosition(_ pos: SCNVector3) {
    
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

  
  func updateVirtualObjectPosition(_ pos: SCNVector3, _ filterPosition: Bool) {
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
  

  
  // MARK: - Virtual Object Loading
  
  
  var isLoadingObject: Bool = false {
    didSet {
      DispatchQueue.main.async {
        //        self.settingsButton.isEnabled = !self.isLoadingObject
        //        self.addObjectButton.isEnabled = !self.isLoadingObject
        //        self.screenshotButton.isEnabled = !self.isLoadingObject
//        self.restartExperienceButton.isEnabled = !self.isLoadingObject
      }
    }
  }
  
  @IBOutlet weak var addObjectButton: UIButton!
  
  func loadVirtualObject(at index: Int) {
    resetVirtualObject()
    
    // Show progress indicator
    //    let spinner = UIActivityIndicatorView()
    //    spinner.center = addObjectButton.center
    //    spinner.bounds.size = CGSize(width: addObjectButton.bounds.width - 5, height: addObjectButton.bounds.height - 5)
    //    addObjectButton.setImage(#imageLiteral(resourceName: "buttonring"), for: [])
    //    sceneView.addSubview(spinner)
    //    spinner.startAnimating()
    
    // Load the content asynchronously.
    DispatchQueue.global().async {
      self.isLoadingObject = true
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
        
        // Remove progress indicator
        //        spinner.removeFromSuperview()
        
        // Update the icon of the add object button
        //        let buttonImage = UIImage.composeButtonImage(from: object.thumbImage)
        //        let pressedButtonImage = UIImage.composeButtonImage(from: object.thumbImage, alpha: 0.3)
        //        self.addObjectButton.setImage(buttonImage, for: [])
        //        self.addObjectButton.setImage(pressedButtonImage, for: [.highlighted])
        self.isLoadingObject = false
      }
    }
  }
  
  //  @IBAction func chooseObject(_ button: UIButton) {
  //    // Abort if we are about to load another object to avoid concurrent modifications of the scene.
  //    if isLoadingObject { return }
  //
  //    textManager.cancelScheduledMessage(forType: .contentPlacement)
  //
  //    let rowHeight = 45
  //    let popoverSize = CGSize(width: 250, height: rowHeight * VirtualObject.availableObjects.count)
  //
  //    let objectViewController = VirtualObjectSelectionViewController(size: popoverSize)
  //    objectViewController.delegate = self
  //    objectViewController.modalPresentationStyle = .popover
  //    objectViewController.popoverPresentationController?.delegate = self
  //    self.present(objectViewController, animated: true, completion: nil)
  //
  //    objectViewController.popoverPresentationController?.sourceView = button
  //    objectViewController.popoverPresentationController?.sourceRect = button.bounds
  //    }
  //
  // MARK: - VirtualObjectSelectionViewControllerDelegate
  

  // MARK: - Planes
  

  

  
  
  // MARK: - Hit Test Visualization
  
  
  
  var showHitTestAPIVisualization = UserDefaults.standard.bool(for: .showHitTestAPI) {
    didSet {
      UserDefaults.standard.set(showHitTestAPIVisualization, for: .showHitTestAPI)
      if showHitTestAPIVisualization {
        hitTestVisualization = HitTestVisualization(sceneView: sceneView)
      } else {
        hitTestVisualization = nil
      }
    }
  }
  
  // MARK: - Debug Visualizations
  
//  @IBOutlet var featurePointCountLabel: UILabel!
  
 

  
  // MARK: - UI Elements and Actions
  
//  @IBOutlet weak var messagePanel: UIView!
//  @IBOutlet weak var messageLabel: UILabel!
//  @IBOutlet weak var debugMessageLabel: UILabel!
  

  
//  @IBOutlet weak var restartExperienceButton: UIButton!
//  var restartExperienceButtonIsEnabled = true
  
  @IBAction func restartExperience(_ sender: Any) {
    
    guard /*restartExperienceButtonIsEnabled,*/ !isLoadingObject else {
      return
    }
    
    DispatchQueue.main.async {
//      self.restartExperienceButtonIsEnabled = false
      
      self.textManager.cancelAllScheduledMessages()
      self.textManager.dismissPresentedAlert()
      self.textManager.showMessage("STARTING A NEW SESSION")
      self.use3DOFTracking = false
      
      self.setupFocusSquare()
      self.resetVirtualObject()
      self.restartPlaneDetection()
      
//      self.restartExperienceButton.setImage(#imageLiteral(resourceName: "restart"), for: [])
      
      // Disable Restart button for five seconds in order to give the session enough time to restart.
//      DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
//        self.restartExperienceButtonIsEnabled = true
//      })
    }
  }
  
  @IBOutlet weak var screenshotButton: UIButton!
  
  @IBAction func takeScreenshot() {
    //    guard screenshotButton.isEnabled else {
    //      return
    //    }
    
    let takeScreenshotBlock = {
      if let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController {
        photoViewController.image = self.sceneView.snapshot()
        photoViewController.modalPresentationStyle = .fullScreen
        photoViewController.modalTransitionStyle = .crossDissolve
        self.present(photoViewController, animated: true, completion: nil)
      }
      
      //
      //      DispatchQueue.main.async {
      //        // Briefly flash the screen.
      //        let flashOverlay = UIView(frame: self.sceneView.frame)
      //        flashOverlay.backgroundColor = UIColor.white
      //        self.sceneView.addSubview(flashOverlay)
      //        UIView.animate(withDuration: 0.25, animations: {
      //          flashOverlay.alpha = 0.0
      //        }, completion: { _ in
      //          flashOverlay.removeFromSuperview()
      //        })
      //      }
    }
    
    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized:
      takeScreenshotBlock()
    case .restricted, .denied:
      let title = "Photos access denied"
      let message = "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots."
      textManager.showAlert(title: title, message: message)
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
        if authorizationStatus == .authorized {
          takeScreenshotBlock()
        }
      })
    }
  }
  
  // MARK: - Settings
  
//  @IBOutlet weak var settingsButton: UIButton!
  
  //  @IBAction func showSettings(_ button: UIButton) {
  //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
  //    guard let settingsViewController = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as? SettingsViewController else {
  //      return
  //    }
  //
  //    let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSettings))
  //    settingsViewController.navigationItem.rightBarButtonItem = barButtonItem
  //    settingsViewController.title = "Options"
  //
  //    let navigationController = UINavigationController(rootViewController: settingsViewController)
  //    navigationController.modalPresentationStyle = .popover
  //    navigationController.popoverPresentationController?.delegate = self
  //    navigationController.preferredContentSize = CGSize(width: sceneView.bounds.size.width - 20, height: sceneView.bounds.size.height - 50)
  //    self.present(navigationController, animated: true, completion: nil)
  //
  //    navigationController.popoverPresentationController?.sourceView = settingsButton
  //    navigationController.popoverPresentationController?.sourceRect = settingsButton.bounds
  //  }
  
  //    @objc
  //    func dismissSettings() {
  //    self.dismiss(animated: true, completion: nil)
  //    updateSettings()
  //  }
  

  
  // MARK: - Error handling
  
  func displayErrorMessage(title: String, message: String, allowRestart: Bool = false) {
    // Blur the background.
    textManager.blurBackground()
    
    if allowRestart {
      // Present an alert informing about the error that has occurred.
      let restartAction = UIAlertAction(title: "Reset", style: .default) { _ in
        self.textManager.unblurBackground()
        self.restartExperience(self)
      }
      textManager.showAlert(title: title, message: message, actions: [restartAction])
    } else {
      textManager.showAlert(title: title, message: message, actions: [])
    }
  }
  
  // MARK: - UIPopoverPresentationControllerDelegate
//  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//    return .none
//  }
//
//  func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
//    updateSettings()
//  }
  
  @IBAction func unwindFromPhoto(_ segue: UIStoryboardSegue) {

  }
  
  @IBAction func unwindFromInfo(_ segue: UIStoryboardSegue) {
    
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
