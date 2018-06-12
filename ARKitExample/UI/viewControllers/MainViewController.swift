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
  private var arViewController: ARViewController?
  private var collectionViewController: VirtualObjectCollectionViewController?
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
      self.arViewController = viewController
    } else if let viewController = segue.destination as? VirtualObjectCollectionViewController {
      self.collectionViewController = viewController
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bind(aboutButton, aboutView)
    bind(appNumberButton, appNumberView)
    bind(remainingTimeButton, remainingTimeView)
    bind(totalSubmitsButton, totalSubmitsView)
    
    collectionViewController?.loadVirtualObject
      .subscribe(onNext: { [weak self] (id) in
        self?.arViewController?.loadVirtualObject(at: id)
      })
      .disposed(by: disposeBag)
    
    collectionViewController?.takeScreenshot
      .subscribe(onNext: { [weak self]_ in
        if let arViewController = self?.arViewController {
          self?.loadImage(image: arViewController.snapshot)
        }
      })
      .disposed(by: disposeBag)
    
    FirebaseDatabase.sharedInstance.numberInstalled
      .map({ (number) -> NSAttributedString in return NSAttributedString(string: "APP: \(number)/100")})
      .bind(to: appNumberButton.rx.attributedTitle())
      .disposed(by: disposeBag)
    
    FirebaseDatabase.sharedInstance.getTotalSubmitted()
      .do(onNext: { [weak self] (totalSubmits) in
        self?.totalSubmitsView.totalSubmits = totalSubmits
      })
      .subscribe()
      .disposed(by: disposeBag)
    
    FirebaseDatabase.sharedInstance.getLatestSubmitted()
      .do(onNext: { [weak self] (date) in
        self?.remainingTimeView.latestSubmitted = date
      })
      .subscribe()
      .disposed(by: disposeBag)
    
    Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
      .do(onNext: { [weak self] _ in
        self?.remainingTimeView.calculateRemainingTime()
      })
      .subscribe()
      .disposed(by: disposeBag)
  }
  
  private func loadImage(image: UIImage) {
    if let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController {
      photoViewController.image = image
      photoViewController.modalTransitionStyle = .crossDissolve
      self.present(photoViewController, animated: true, completion: nil)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let defaults = UserDefaults.standard
    if (!defaults.bool(for: .firstRunCompleted)) {
      defaults.set(true, for: .firstRunCompleted)
      aboutView.toggle(superView: view, x: -155, y: -285)
    } else {
      arViewController?.restartPlaneDetection()
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
