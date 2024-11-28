//
//  SplashVC.swift
//  GreenHeart
//
//  Created by Epazz on 27/10/2021.
//

import UIKit

class SplashVC: UIViewController {

    @IBOutlet weak var gifImage: UIImageView!
    @IBOutlet weak var gifLoadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.gifImage.image = UIImage.gif(name: "Logo")
        self.gifImage.image = UIImage.gif(name: "Logo")
        do {
            let imageData = try Data(contentsOf: Bundle.main.url(forResource: "Logo1", withExtension: ".gif")!)
            self.gifImage.image = UIImage.gif(data: imageData)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.decideRootViewController()
            }
        } catch {
            print(error)
        }

        // Do any additional setup after loading the view.
//
//        let jeremyGif = UIImage.gifImageWithName("greenheart_")
//            let imageView = UIImageView(image: jeremyGif)
//        imageView.frame = CGRect(x: 0, y: -40, width: self.view.frame.size.width, height: self.gifLoadingView.frame.height)
//
//        gifLoadingView.addSubview(imageView)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.decideRootViewController()
//        }
    }
}

