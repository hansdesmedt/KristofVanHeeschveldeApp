//
//  CustomButton.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 17/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import PureLayout

extension UIView {

  func roundCorners23() {
    layer.cornerRadius = 23
    clipsToBounds = true
  }
  
  func roundCorners10() {
    layer.cornerRadius = 10
    clipsToBounds = true
  }
  
  func whiteBorders() {
    layer.borderWidth = 1
    layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
  }
  
  func blackBackground() {
    backgroundColor = UIColor.black.withAlphaComponent(0.4)
  }
  
  func isShown() -> Bool {
    return self.superview != nil
  }
  
  func toggle(superView: UIView, x: CGFloat, y: CGFloat) {
    var t = CGAffineTransform.identity
    t = t.translatedBy(x: x, y: y)
    t = t.scaledBy(x: 0.01, y: 0.01)
    if !isShown() {
      superView.addSubview(self)
      autoCenterInSuperview()
      transform = t
      UIView.animate(withDuration: 0.3) {
        self.transform = CGAffineTransform.identity
      }
    } else {
      UIView.animate(withDuration: 0.3, animations: {
        self.transform = t
      }, completion: { _ in
        self.removeFromSuperview()
      })
    }
  }
}
