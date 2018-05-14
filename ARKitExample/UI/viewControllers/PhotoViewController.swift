//
//  PhotoViewController.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 14/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Photos
import Social

class PhotoViewController: UIViewController {
  
  private let disposeBag = DisposeBag()
  
  @IBOutlet var submitConfirmationView: SubmitConfirmationView!
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var facebookDiskButton: UIButton!
  @IBOutlet weak var submitButton: UIButton!
  var image: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imageView.image = image
  }
  
  @IBAction func moreActions(_ sender: UIButton) {
    guard let image = image else { return }
    let share = [image, "share this on facebook", "http://google.be"] as [Any]
    let activityViewController = UIActivityViewController(activityItems: share, applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = view
    present(activityViewController, animated: true, completion: nil)
  }
  
  @IBAction func submitImage(_ sender: UIButton) {
    if let image = image, let data = UIImageJPEGRepresentation(image, 1.0) {
      submitConfirmationView.show(view: view)
      AppDelegate.cloudanary.createUploader().upload(data: data, uploadPreset: AppDelegate.uploadPreset, progress: { [weak self] progress in
        self?.submitConfirmationView.progress(progress)
      }) { [weak self] (result, error) in
        if let _ = error {
          self?.submitConfirmationView.showError()
        } else if let url = result?.url {
          // save entry in firebase
          self?.saveUrl(url: url)
          self?.submitConfirmationView.showCompleted()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          self?.submitConfirmationView.hide()
        }
      }
    }
  }
  
  private func saveUrl(url: String) {
    FirebaseDatabase.sharedInstance
      .setPhoto(url: url)
      .subscribe()
      .disposed(by: disposeBag)
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}
