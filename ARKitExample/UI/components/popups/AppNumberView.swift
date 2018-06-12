//
//  AppNumberView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 23/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class AppNumberView: PopupView {
 
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    originX = 0
    originY = -285
    makeTransformations()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentLabel.attributedText = NSAttributedString.body(string: "Pellentesque quis neque ultricies, iaculis arcu et, varius nisi. Sed pharetra tincidunt tellus, et lobortis ex. In turpis dolor, tempor nec congue sed, rhoncus vitae mauris. Quisque rutrum pellentesque leo vel rutrum. ")
  }

}
