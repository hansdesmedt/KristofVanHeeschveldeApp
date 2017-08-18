//
//  CustomButton.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 17/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

extension UIButton {
  
  func roundCornersWhite() {
    layer.cornerRadius = 23
    layer.borderWidth = 1
    layer.borderColor = UIColor.white.cgColor
  }
}
