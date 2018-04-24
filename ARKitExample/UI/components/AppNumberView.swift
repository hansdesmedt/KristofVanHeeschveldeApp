//
//  AppNumberView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 23/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class AppNumberView: PopupView {

  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var okButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    blurView.roundCorners5()
  }

}
