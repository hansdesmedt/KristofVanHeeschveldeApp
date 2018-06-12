//
//  NSAttributedStringExtensions.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 25/04/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

extension NSAttributedString {
  
  fileprivate class func paragraphStyle(alignment: NSTextAlignment) -> NSMutableParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 3
    paragraphStyle.alignment = alignment
    return paragraphStyle
  }
  
  class func attributes(color: UIColor, font: UIFont) -> [NSAttributedStringKey: Any] {
    let style = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font]
    return style
  }
  
  class func attributes(alignment: NSTextAlignment, color: UIColor, font: UIFont) -> [NSAttributedStringKey: Any] {
    let style = [NSAttributedStringKey.paragraphStyle: paragraphStyle(alignment: alignment), NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font]
    return style
  }
  
  class func attributed(forString string: String, color: UIColor = .white, font: UIFont) -> NSAttributedString! {
    let style = NSAttributedString.attributes(color: color, font: font)
    return NSAttributedString(string: string, attributes: style)
  }
  
  class func attributedParagraph(forString string: String, alignment: NSTextAlignment, color: UIColor = .black, font: UIFont) -> NSAttributedString! {
    let style = NSAttributedString.attributes(alignment: alignment, color: color, font: font)
    return NSAttributedString(string: string, attributes: style)
  }

  class func body(string: String, alignment: NSTextAlignment = .center) -> NSAttributedString {
    return NSAttributedString.attributedParagraph(forString: string, alignment: alignment, font: .body())
  }
  
  class func bodyBold(string: String, alignment: NSTextAlignment = .center) -> NSAttributedString {
    return NSAttributedString.attributedParagraph(forString: string, alignment: alignment, font: .bodyBold())
  }
  
  class func H1Bold(string: String, alignment: NSTextAlignment = .center) -> NSAttributedString {
    return NSAttributedString.attributedParagraph(forString: string, alignment: alignment, font: .H1Bold())
  }

}
