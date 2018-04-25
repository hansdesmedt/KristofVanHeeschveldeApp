//
//  CustomButton.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 25/04/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    backgroundColor = UIColor.white.withAlphaComponent(0.3)
    roundCorners3()
  }
}
