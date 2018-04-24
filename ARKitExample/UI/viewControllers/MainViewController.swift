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
  private var activeView: UIView?
  
  @IBOutlet var aboutView: AboutView!
  @IBOutlet var appNumberView: AppNumberView!
  @IBOutlet var remainingTimeView: RemainingTimeView!
  @IBOutlet var totalSubmitsView: TotalSubmitsView!
  @IBOutlet weak var appNumberButton: UIButton!
  
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
    
//    aboutView.giveAccessButton.rx.tap
//      .debounce(0.5, scheduler: MainScheduler.instance)
//      .subscribe(){ [weak self] _ in
//        self?.ARViewController?.restartPlaneDetection()
//        if let view = self?.view {
//          self?.aboutView.toggle(superView: view, x: -155, y: -285)
//        }
//      }
//      .disposed(by: disposeBag)

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
  
  @IBAction func onboardingPressed(_ sender: UIButton) {
    aboutView.show(view: self.view)
//    aboutView.toggle(superView: view, x: -155, y: -285)
//    if appNumberView.isShown() {
//      appNumberView.toggle(superView: view, x: 0, y: -285)
//    }
  }
  
  @IBAction func numberAppPressed(_ sender: UIButton) {
//    appNumberView.toggle(superView: view, x: 0, y: -285)
//    if aboutView.isShown() {
//      aboutView.toggle(superView: view, x: -155, y: -285)
//    }
  }
  
  @IBAction func unwindFromPhoto(_ segue: UIStoryboardSegue) {
  }
  
  @IBAction func unwindFromInfo(_ segue: UIStoryboardSegue) {
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
