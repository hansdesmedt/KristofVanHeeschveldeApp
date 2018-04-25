//
//  MainViewController.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 30/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
  
  private let disposeBag = DisposeBag()
  private var ARViewController: ARViewController?
  private let blackView = BlackView(frame: CGRect.zero)
  
  @IBOutlet var aboutView: AboutView!
  @IBOutlet var appNumberView: AppNumberView!
  @IBOutlet var remainingTimeView: RemainingTimeView!
  @IBOutlet var totalSubmitsView: TotalSubmitsView!
  
  @IBOutlet weak var aboutButton: UIButton!
  @IBOutlet weak var appNumberButton: UIButton!
  @IBOutlet weak var remainingTimeButton: UIButton!
  @IBOutlet weak var totalSubmitsButton: UIButton!
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let viewController = segue.destination as? ARViewController {
      self.ARViewController = viewController
    } else if let collectionViewController = segue.destination as? VirtualObjectCollectionViewController {
      collectionViewController.takeScreenshot.subscribe(onNext: { _ in
        if let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController, let ARViewController = self.ARViewController {
          photoViewController.image = ARViewController.snapshot
          photoViewController.modalTransitionStyle = .crossDissolve
          self.present(photoViewController, animated: true, completion: nil)
        }
        
      }).disposed(by: disposeBag)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bind(aboutButton, aboutView)
    bind(appNumberButton, appNumberView)
    bind(remainingTimeButton, remainingTimeView)
    bind(totalSubmitsButton, totalSubmitsView)
    
    FirebaseDatabase.sharedInstance.numberInstalled
      .map({ (number) -> NSAttributedString in return NSAttributedString(string: "APP: \(number)/100")})
      .bind(to: appNumberButton.rx.attributedTitle())
      .disposed(by: disposeBag)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let defaults = UserDefaults.standard
    if (!defaults.bool(for: .firstRunCompleted)) {
      defaults.set(true, for: .firstRunCompleted)
      aboutView.toggle(superView: view, x: -155, y: -285)
    } else {
      ARViewController?.restartPlaneDetection()
    }
  }
  
  private func bind(_ button: UIButton, _ popupView: PopupView) {
    button.rx.tap.subscribe() { [weak self] _ in
      guard let view = self?.view, let blackView = self?.blackView else { return }
      blackView.show(view: view)
      popupView.show(view: view)
      }
      .disposed(by: disposeBag)
    
    popupView.okButton.rx.tap.subscribe() { [weak self] _ in
      guard let blackView = self?.blackView else { return }
      blackView.hide()
      popupView.hide()
      }
      .disposed(by: disposeBag)
  }
  
  @IBAction func unwindFromPhoto(_ segue: UIStoryboardSegue) {
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
