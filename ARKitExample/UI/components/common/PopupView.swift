//
//  PopupView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 24/04/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import PureLayout

class PopupView: UIView {
  
  @IBOutlet weak var okButton: UIButton!
  
  var tansformations = CGAffineTransform.identity
  var originX:CGFloat = 0
  var originY:CGFloat = 0
  
  func makeTransformations() {
    tansformations = CGAffineTransform.identity
    tansformations = tansformations.translatedBy(x: originX, y: originY)
    tansformations = tansformations.scaledBy(x: 0.01, y: 0.01)
  }
  
  func show(view:UIView) {
    alpha = 0
    view.addSubview(self)
    autoAlignAxis(ALAxis.horizontal, toSameAxisOf: view, withOffset: -40)
    autoAlignAxis(ALAxis.vertical, toSameAxisOf: view, withOffset: 0)
    transform = tansformations
    UIView.animate(withDuration: 0.3) {
      self.transform = CGAffineTransform.identity
      self.alpha = 1
    }
  }
  
  func hide() {
    UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
      self.alpha = 0
      self.transform = self.tansformations
    }, completion: { _ in
      self.removeFromSuperview()
    })
  }
}
