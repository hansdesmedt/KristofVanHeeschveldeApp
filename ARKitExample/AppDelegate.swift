/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Empty application delegate class.
 */

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var ref: DatabaseReference!
  
  // Nothing to do here. See ViewController for primary app features.
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

