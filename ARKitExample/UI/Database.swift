//
//  database.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 27/12/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

final class FirebaseDatabase {
  
  enum FirebaseDatabaseError: Error {
    case uuidFailed
  }
  
  private let ref = Database.database().reference()
  
  static let sharedInstance = FirebaseDatabase()
  
  func login() -> Observable<User> {
    return Observable.create { observer in
      Auth.auth().signInAnonymously() { (user, error) in
        guard let user = user else {
          if let error = error {
            observer.onError(error)
          }
          return
        }
        observer.onNext(user)
        observer.on(.completed)
      }
      return Disposables.create()
    }
  }
  
  func setNumberInstalled() -> Observable<UInt> {
    return login().flatMap({ _ -> Observable<UInt> in
      guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
        return Observable.error(FirebaseDatabaseError.uuidFailed)
      }
      return self.getSnapshotPath(path: "installs").map({ (snapshot) -> UInt in
        let install = snapshot.childrenCount + 1
        self.ref.child("installs/\(uuid)").setValue(install)
        return install
      })
    })
  }
  
  var numberInstalled: Observable<UInt> {
    return login().flatMap({ _ -> Observable<UInt> in
      guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
        return Observable.error(FirebaseDatabaseError.uuidFailed)
      }
      return self.getSnapshotPath(path: "installs/\(uuid)").flatMap({ (snapshot) -> Observable<UInt> in
        if let value = snapshot.value as? UInt {
          return Observable.of(value)
        }
        return self.setNumberInstalled()
      })
    })
  }
  
  private func getSnapshotPath(path: String) -> Observable<DataSnapshot> {
    return Observable.create { observer in
      self.ref.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
        observer.on(.next(snapshot))
        observer.on(.completed)
      })
      return Disposables.create()
    }
  }
}
