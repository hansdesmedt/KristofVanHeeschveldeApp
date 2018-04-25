//
//  RemainingTimeView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 24/04/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class RemainingTimeView: PopupView {
  
  @IBOutlet weak var contentLabel: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    originX = 155
    originY = 285
    makeTransformations()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentLabel.attributedText = NSAttributedString.body(string: "Aenean cursus blandit erat eu porttitor. Mauris eu sapien sagittis, pretium massa id, dignissim risus. Sed vel fermentum sem.")
  }
}
