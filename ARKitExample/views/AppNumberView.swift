//
//  AppNumberView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 23/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class AppNumberView: UIView {

  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var okButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    blurView.roundCorners10()
    okButton.roundCorners23()
    okButton.whiteBorders()
    okButton.blackBackground()
  }
  /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
