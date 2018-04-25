//
//  ConfirmButton.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 25/04/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ConfirmButton: UIButton {

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    blackBorders()
    roundCorners22()
  }
}
