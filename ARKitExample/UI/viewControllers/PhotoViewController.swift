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
 
  var remainingTime: String? = nil
  
  private let disposeBag = DisposeBag()
  private let blackView = BlackView(frame: CGRect.zero)
  
  @IBOutlet var submitConfirmationView: SubmitConfirmationView!
  @IBOutlet var cannotSubmitView: CannotSubmitView!
  
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
    // TODO: has internet?
    // TODO: double check if last submitted
    // TODO: check total submits
    if let time = remainingTime {
      cannotSubmitView.show(view: view)
      cannotSubmitView.showMessage(time: time)
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        self.cannotSubmitView.hide()
      }
      return
    }
    if let image = image, let data = UIImageJPEGRepresentation(image, 1.0) {
      blackView.show(view: view)
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
          self?.blackView.hide()
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
