//
//  SplashViewController.swift
//  RiverPrime
//
//  Created by Ross on 06/10/2024.
//

import UIKit

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gifImageCalling()
        
    }
    
    private func gifImageCalling() {
        
        let jeremyGif = UIImage.gifImageWithName(name: "Logo")
        let imageView = UIImageView(image: jeremyGif)
        
        imageView.contentMode = .scaleAspectFit
        
//        self.gifImage = imageView
        imageView.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
        view.addSubview(imageView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.decideRootViewController()
            
            SCENE_DELEGATE.decideRootViewController()
        }
        
    }
    
}
