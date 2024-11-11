//
//  ViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//

import UIKit
import AVFoundation
import GoogleSignIn

class ViewController: BaseViewController {
    
    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var companyTitlelbl: UILabel!
    @IBOutlet weak var registerNowBtn: UIButton!
    
    let vm = ViewControllerVM()
    let googleSignIn = GoogleSignIn()
    
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        styling()

        playBackgroundVideo()
    }
    

    // for crash laytics
//        let button = UIButton(type: .roundedRect)
//           button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
//           button.setTitle("Test Crash", for: [])
//           button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
//           view.addSubview(button)
//       }
//
//       @IBAction func crashButtonTapped(_ sender: AnyObject) {
//           let numbers = [0]
//           let _ = numbers[1]
//       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
    }
       
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func registerBtn(_ sender: Any) {
        if let signUp = instantiateViewController(fromStoryboard: "Main", withIdentifier: "SignUpViewController") //SignUpViewController PasscodeFaceIDVC
        {
            self.navigate(to: signUp)
        }
   
    }
    
    @IBAction func signInBtn(_ sender: Any) {
        if let signInVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "SignInViewController"){
            self.navigate(to: signInVC)
        }
    }
    
    @IBAction func continueGoogleBtn(_ sender: Any) {
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                return
            }
            print("google login user result : \(result)")
            guard let user1 = result?.user else { return }
            
            self?.googleSignIn.authenticateWithFirebase(user: user1)
            
        }
    }
    
    @IBAction func tryDemo_btnAction(_ sender: Any) {
        print("Try demo btn action: ")
    }
}

extension ViewController {
    
    private func styling() {
        //MARK: - Fonts
        titlelbl.font = FontController.Fonts.Inter_Regular.font
        companyTitlelbl.font = FontController.Fonts.Inter_Medium.font
        registerNowBtn.titleLabel?.font = FontController.Fonts.Inter_SemiBold.font
        
//        MARK: - Labels
        titlelbl.text = LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.WelcomeScreen.Title.localized)
        companyTitlelbl.text = LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.WelcomeScreen.CompanyNameLabel.localized)
        registerNowBtn.setTitle(LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.WelcomeScreen.RegisterNowButton.localized), for: .normal)
//        titlelbl.text = NSLocalizedString("welcome_screen_title", comment: "")
//        companyTitlelbl.text = NSLocalizedString("welcome_screen_company_name", comment: "Welcome message on the main screen")
//        registerNowBtn.setTitle(NSLocalizedString("welcome_screen_register_button", comment: "Register button title"), for: .normal)
          
    }
    
}

extension ViewController {
    
    func playBackgroundVideo() {
        guard let path = Bundle.main.path(forResource: "background_vedio", ofType: "mp4") else {
               print("Video file not found")
               return
           }
        
        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
           player = AVPlayer(playerItem: playerItem)
        player?.isMuted = true
           let playerLayer = AVPlayerLayer(player: player)
           playerLayer.frame = view.bounds
           playerLayer.videoGravity = .resizeAspectFill
        playerLayer.opacity = 0.6
           // Insert the player layer at the bottom so it acts as a background
           view.layer.insertSublayer(playerLayer, at: 0)
           
           // Start playing and set it to loop
           player?.play()
           NotificationCenter.default.addObserver(self, selector: #selector(loopVideo), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
       }

       @objc func loopVideo() {
           player?.seek(to: .zero)
           player?.play()
       }

}
