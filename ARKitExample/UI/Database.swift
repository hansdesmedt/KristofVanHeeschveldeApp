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
    case parsingFailed
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
        throw FirebaseDatabaseError.uuidFailed
      }
      return self.getSnapshotPath(path: "installs").map({ (snapshot) -> UInt in
        let install = snapshot.childrenCount + 1
        self.ref.child("installs/\(uuid)").setValue(install)
        return install
      })
    })
  }
  
  func getTotalSubmitted() -> Observable<UInt> {
    return login().flatMap({ _ -> Observable<UInt> in
      return self.getObservableValue(path: "totalSubmitted")
        .map({ (snapshot) -> UInt in
          guard let totalSubmitted = snapshot.value as? UInt else {
            throw FirebaseDatabaseError.parsingFailed
          }
          return totalSubmitted
        })
    })
  }
  
  func getLatestSubmitted() -> Observable<Date> {
    return login().flatMap({ _ -> Observable<Date> in
      guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
        throw FirebaseDatabaseError.uuidFailed
      }
      return self.getObservableValue(path: "users/\(uuid)/lastSubmitted")
        .map({ (snapshot) -> Date in
          let dateFormatterGet = DateFormatter()
          dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm:ss"
          guard let latest = snapshot.value as? String, let date = dateFormatterGet.date(from: latest) else {
            throw FirebaseDatabaseError.parsingFailed
          }
          return date
        })
    })
  }
  
  func setPhoto(url: String) -> Observable<Void> {
    return login().flatMap({ _ -> Observable<Void>in
      guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
        throw FirebaseDatabaseError.uuidFailed
      }
      
      let dateFormatterGet = DateFormatter()
      dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm:ss"
      let date = dateFormatterGet.string(from: Date())
      
      let photoUuid = NSUUID().uuidString
      self.ref.child("photos/\(photoUuid)/created").setValue(date)
      self.ref.child("photos/\(photoUuid)/url").setValue(url)
      self.ref.child("photos/\(photoUuid)/userUUID").setValue(uuid)
      
      self.ref.child("users/\(uuid)/lastSubmitted").setValue(date)
      
      return self.getSnapshotPath(path: "users/\(uuid)/totalSubmitted")
        .map({ (snapshot) -> Void in
          if let totalSubmitted = snapshot.value as? UInt {
            self.ref.child("users/\(uuid)/totalSubmitted").setValue(totalSubmitted + 1)
          } else {
            self.ref.child("users/\(uuid)/totalSubmitted").setValue(1)
          }
        })
        .flatMap({ () -> Observable<DataSnapshot> in
          return self.getSnapshotPath(path: "totalSubmitted")
        })
        .map({ (snapshot) -> Void in
          if let totalSubmitted = snapshot.value as? UInt {
            self.ref.child("totalSubmitted").setValue(totalSubmitted + 1)
          } else {
            self.ref.child("totalSubmitted").setValue(1)
          }
        })
    })
  }
  
//  func getLatestPhoto() -> Observable<Void> {
//    return login().map({ _ in
//      guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
//        throw FirebaseDatabaseError.uuidFailed
//      }
//
//      self.ref.child("photos").queryOrdered(byChild: "userUUID").qu
//    })
//  }
  
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
  
  private func getObservableValue(path: String) -> Observable<DataSnapshot> {
    return Observable.create { observer in
      self.ref.child(path).observe(DataEventType.value, with: { (snapshot) in
        observer.on(.next(snapshot))
      })
      return Disposables.create()
    }
  }
}
