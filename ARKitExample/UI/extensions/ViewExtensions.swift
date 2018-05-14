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

  func roundCorners33() {
    layer.cornerRadius = 33
    clipsToBounds = true
  }
  
  func roundCorners22() {
    layer.cornerRadius = 22
    clipsToBounds = true
  }
  
  func roundCorners20() {
    layer.cornerRadius = 20
    clipsToBounds = true
  }
  
  func roundCorners10() {
    layer.cornerRadius = 10
    clipsToBounds = true
  }
  
  func roundCorners5() {
    layer.cornerRadius = 5
    clipsToBounds = true
  }
  
  func roundCorners2() {
    layer.cornerRadius = 2
    clipsToBounds = true
  }
  
  func whiteBorders() {
    layer.borderWidth = 1
    layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
  }
  
  func blackBorders() {
    layer.borderWidth = 1
    layer.borderColor = UIColor.black.cgColor
  }
  
  func blackBackground() {
    backgroundColor = UIColor.black.withAlphaComponent(0.4)
  }
  
  func isShown() -> Bool {
    return self.superview != nil
  }
  
  func toggle(superView: UIView, x: CGFloat, y: CGFloat, delay: TimeInterval = 0) {
    var t = CGAffineTransform.identity
    t = t.translatedBy(x: x, y: y)
    t = t.scaledBy(x: 0.01, y: 0.01)
    if !isShown() {

    } else {

    }
  }
  
  var snapshot: UIImage? {
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
    defer { UIGraphicsEndImageContext() }
    drawHierarchy(in: bounds, afterScreenUpdates: true)
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
