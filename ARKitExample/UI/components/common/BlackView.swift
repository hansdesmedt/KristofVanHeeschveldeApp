//
//  BlackView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 25/04/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import PureLayout

class BlackView: UIView {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    backgroundColor = UIColor.black
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.black
  }
  
  func show(view:UIView) {
    alpha = 0
    view.addSubview(self)
    autoCenterInSuperview()
    autoPinEdgesToSuperviewEdges()
    UIView.animate(withDuration: 0.3) {
      self.alpha = 0.65
    }
  }
  
  func hide() {
    UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
      self.alpha = 0
    }, completion: { _ in
      self.removeFromSuperview()
    })
  }
}

