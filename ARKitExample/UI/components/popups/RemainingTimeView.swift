//
//  RemainingTimeView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 24/04/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class RemainingTimeView: PopupView {
  
  var latestSubmitted:Date? {
    didSet {
      refresh()
    }
  }
  
  func refresh() {
    if let remainingTime = calculateRemainingTime() {
      contentLabel.attributedText = NSAttributedString.H1Bold(string: remainingTime)
    } else {
      contentLabel.attributedText = NSAttributedString.body(string: "You can submit a photo, no time limit for you!")
    }
  }
  
  @IBOutlet weak var contentLabel: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    originX = 155
    originY = 285
    makeTransformations()
  }
  
  func calculateRemainingTime() -> String? {
    guard let latestSubmitted = latestSubmitted else {
      return nil
    }
    
    let now = Date()
    let interval = now.timeIntervalSince(latestSubmitted)
    let day: TimeInterval = 24 * 60 * 60
    let remaining = interval.distance(to: day)
    
    let ti = Int(remaining)
    
    guard ti > 0 else {
      return nil
    }
    
    let seconds = ti % 60
    let minutes = (ti / 60) % 60
    let hours = (ti / 3600)
    
    return String(format: "%0.2dh %0.2dm %0.2ds",hours,minutes,seconds)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentLabel.attributedText = NSAttributedString.body(string: "Aenean cursus blandit erat eu porttitor. Mauris eu sapien sagittis, pretium massa id, dignissim risus. Sed vel fermentum sem.")
  }
}
