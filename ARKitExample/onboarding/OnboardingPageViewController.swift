//
//  OnboardingPageViewController.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 17/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIPageViewController /*, UIPageViewControllerDelegate, UIPageViewControllerDataSource */ {
  
//  let identifiers = ["Onboarding1ViewController", "Onboarding2ViewController", "Onboarding3ViewController"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    delegate = self
//    dataSource = self
//    
    if let viewController1 = storyboard?.instantiateViewController(withIdentifier: "Onboarding1ViewController"),
      let viewController2 = storyboard?.instantiateViewController(withIdentifier: "Onboarding2ViewController"),
      let viewController3 = storyboard?.instantiateViewController(withIdentifier: "Onboarding3ViewController") {
      setViewControllers([viewController1, viewController2, viewController3],
                         direction: .forward,
                         animated: true,
                         completion: nil)
    }
  }
  
  
  
//  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//
//  }
//
//  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//
//  }
//
//  func presentationCount(for pageViewController: UIPageViewController) -> Int {
//
//  }
//
//  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//
//  }
}
