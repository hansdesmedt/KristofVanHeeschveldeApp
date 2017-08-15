//
//  PhotoViewController.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 14/08/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  var image: UIImage?
  
    override func viewDidLoad() {
        super.viewDidLoad()

      imageView.image = image
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func saveToPhotos(_ sender: UIButton) {
    if let image = image {
      UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
      dismiss(animated: true, completion: nil)
    }
  }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
