//
//  UserDefaultsExtensions.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 27/12/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

enum Setting: String {
  // Bool settings
  case firstRunCompleted
  
  // Integer state used in virtual object picker
  case selectedObjectID
}

extension UserDefaults {
  func bool(for setting: Setting) -> Bool {
    return bool(forKey: setting.rawValue)
  }
  func set(_ bool: Bool, for setting: Setting) {
    set(bool, forKey: setting.rawValue)
  }
  func integer(for setting: Setting) -> Int {
    return integer(forKey: setting.rawValue)
  }
  func set(_ integer: Int, for setting: Setting) {
    set(integer, forKey: setting.rawValue)
  }
}
