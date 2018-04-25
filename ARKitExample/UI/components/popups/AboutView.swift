//
//  AboutView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 23/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class AboutView: PopupView {
  
  @IBOutlet weak var contentLabel: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    originX = -155
    originY = -285
    makeTransformations()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentLabel.attributedText = NSAttributedString.body(string: "Nulla condimentum velit arcu, sit amet elementum felis luctus a. Aliquam laoreet, elit et fringilla fermentum, urna sapien rhoncus leo, ut auctor nisi nunc at libero. Donec pharetra eros vitae aliquam tempor. Nullam viverra purus quis enim maximus, ac mollis lacus varius.")
  }
}
