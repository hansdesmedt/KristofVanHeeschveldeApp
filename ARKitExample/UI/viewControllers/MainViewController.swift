//
//  MainViewController.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 30/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

  @IBOutlet var aboutView: UIView!
  @IBOutlet var appNumberView: UIView!
  
  @IBAction func onboardingPressed(_ sender: UIButton) {
    aboutView.toggle(superView: view, x: -155, y: -285)
  }
  
  @IBAction func numberAppPressed(_ sender: UIButton) {
    appNumberView.toggle(superView: view, x: 0, y: -285)
  }

  func takeScreenshot() {
    if let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController {
      photoViewController.image = UIImage()//self.sceneView.snapshot()
      photoViewController.modalPresentationStyle = .fullScreen
      photoViewController.modalTransitionStyle = .crossDissolve
      self.present(photoViewController, animated: true, completion: nil)
    }
  }
  
  @IBAction func unwindFromPhoto(_ segue: UIStoryboardSegue) {
  }
  
  @IBAction func unwindFromInfo(_ segue: UIStoryboardSegue) {
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
