//
//  AboutView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 23/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class AboutView: UIView {

  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var giveAccessButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    blurView.roundCorners10()
    giveAccessButton.roundCorners23()
    giveAccessButton.whiteBorders()
    giveAccessButton.blackBackground()
  }
}
