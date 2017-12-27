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
  private var viewController: ViewController?
  
  @IBOutlet var aboutView: AboutView!
  @IBOutlet var appNumberView: AppNumberView!
  @IBOutlet weak var appNumberButton: UIButton!
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let viewController = segue.destination as? ViewController {
      self.viewController = viewController
    } else if let viewController = segue.destination as? VirtualObjectCollectionViewController {
      viewController.takeScreenshot.subscribe(onNext: { _ in
        if let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController, let viewController = self.viewController {
          photoViewController.image = viewController.snapshot
          photoViewController.modalTransitionStyle = .crossDissolve
          self.present(photoViewController, animated: true, completion: nil)
        }
        
      }).disposed(by: disposeBag)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let database = FirebaseDatabase.sharedInstance
    database.numberInstalled
      .flatMap({ (number) -> Observable<UInt> in
        if let number = number {
          return Observable.just(number)
        }
        return database.setNumberInstalled()
      })
      .subscribe(onNext: { (number) in
        self.appNumberButton.setTitle("APP: \(number)/100", for: UIControlState.normal)
      })
      .disposed(by: disposeBag)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let defaults = UserDefaults.standard
    if (!defaults.bool(for: .firstRunCompleted)) {
      defaults.set(true, for: .firstRunCompleted)
      aboutView.toggle(superView: view, x: -155, y: -285)
      aboutView.giveAccessButton.rx.tap
        .debounce(0.5, scheduler: MainScheduler.instance)
        .subscribe(){ [weak self] _ in
          self?.viewController?.restartPlaneDetection()
          if let view = self?.view {
            self?.aboutView.toggle(superView: view, x: -155, y: -285)
          }
        }
        .disposed(by: disposeBag)
      
    } else {
      viewController?.restartPlaneDetection()
    }
  }
  
  @IBAction func onboardingPressed(_ sender: UIButton) {
    aboutView.toggle(superView: view, x: -155, y: -285)
    if appNumberView.isShown() {
      appNumberView.toggle(superView: view, x: 0, y: -285)
    }
  }
  
  @IBAction func numberAppPressed(_ sender: UIButton) {
    appNumberView.toggle(superView: view, x: 0, y: -285)
    if aboutView.isShown() {
      aboutView.toggle(superView: view, x: -155, y: -285)
    }
  }

  func takeScreenshot() {
    if let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController {
      photoViewController.image = UIImage()//self.sceneView.snapshot()
      photoViewController.modalPresentationStyle = .fullScreen
      photoViewController.modalTransitionStyle = .crossDissolve
      self.present(photoViewController, animated: true, completion: nil)
    }
  }
  
  @IBAction func unwindFromPhoto(_ segue: UIStoryboardSegue) {
  }
  
  @IBAction func unwindFromInfo(_ segue: UIStoryboardSegue) {
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
