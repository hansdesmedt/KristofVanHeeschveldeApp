//
//  OnboardingOneViewController.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 17/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class Onboarding1ViewController: UIViewController {
  
  @IBOutlet weak var yesButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    yesButton.roundCornersWhite()
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}
