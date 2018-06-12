//
//  UIFontExtensions.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 25/04/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

extension UIFont {
  
  class func body() -> UIFont {
    return soleil(.regular, size: 16)
  }
  
  class func bodyBold() -> UIFont {
    return soleil(.bold, size: 16)
  }
  
  class func H1Bold() -> UIFont {
    return soleil(.bold, size: 35)
  }
}

extension UIFont {
  enum ArielType: String {
    case regular = "Arial"
    case bold = "Arial-BoldMT"
  }
  
  class func soleil(_ type: ArielType, size: CGFloat) -> UIFont! {
    return UIFont(name: type.rawValue, size: size)
  }
}
