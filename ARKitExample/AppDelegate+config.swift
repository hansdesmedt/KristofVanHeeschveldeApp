//
//  AppDelegate+config.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 29/03/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import Cloudinary

extension AppDelegate {

  static var cloudanary = CLDCloudinary(configuration: CLDConfiguration(cloudName: AppDelegate.cloudName, apiKey: AppDelegate.apiKey))
  
  static var apiKey: String {
    return "584538321796768"
  }
  
  static var cloudName: String {
    return "dg0kmp3wg"
  }
  
  static var uploadPreset: String {
    return "emdvpbp3"
  }
}
