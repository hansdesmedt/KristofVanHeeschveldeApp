//
//  AboutView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 23/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import RxSwift

class AboutView: PopupView {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    originX = -155
    originY = -285
    makeTransformations()
  }
  
  private let disposeBag = DisposeBag()
  
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var giveAccessButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    giveAccessButton.rx.tap
      .subscribe(){ [weak self] _ in self?.hide() }
      .disposed(by: disposeBag)
    
    blurView.roundCorners5()
  }
}
