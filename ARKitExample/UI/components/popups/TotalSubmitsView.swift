//
//  TotalSubmitsView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 24/04/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class TotalSubmitsView: PopupView {
  
  var totalSubmits:UInt = 0 {
    didSet {
      contentLabel.attributedText = NSAttributedString.H1Bold(string: String(totalSubmits))
    }
  }
  
  @IBOutlet weak var contentLabel: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    originX = -155
    originY = 285
    makeTransformations()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentLabel.attributedText = NSAttributedString.body(string: "Proin dignissim quis orci at cursus. Etiam sodales ligula nec velit rutrum lobortis tristique eu quam. Curabitur ullamcorper leo sed tellus dapibus vestibulum. Sed viverra lobortis nulla, eu facilisis elit cursus vitae. Praesent placerat ullamcorper leo. Nulla mollis convallis blandit.")
  }
}
