//
//  PhotoViewController.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 14/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var saveToDiskButton: UIButton!
  @IBOutlet weak var facebookDiskButton: UIButton!
  @IBOutlet weak var submitButton: UIButton!
  var image: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imageView.image = image
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func saveToPhotos(_ sender: UIButton) {
    if let image = image {
      UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
      dismiss(animated: true, completion: nil)
    }
  }
  
  @IBAction func submit(_ sender: UIButton) {
    if let image = image, let data = UIImageJPEGRepresentation(image, 1.0) {
      AppDelegate.cloudanary.createUploader().upload(data: data, uploadPreset: AppDelegate.uploadPreset, progress: nil) { (result, error) in
        if let error = error {
          print("Error uploading image %@", error)
        }
      }
    }
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  //  switch PHPhotoLibrary.authorizationStatus() {
  //  case .authorized:
  //  takeScreenshotBlock()
  //  case .restricted, .denied:
  //  let title = "Photos access denied"
  //  let message = "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots."
  //  textManager.showAlert(title: title, message: message)
  //  case .notDetermined:
  //  PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
  //  if authorizationStatus == .authorized {
  //  takeScreenshotBlock()
  //  }
  //  })
  //  }
  
}
