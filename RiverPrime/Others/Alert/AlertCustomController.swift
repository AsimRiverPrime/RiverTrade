//
//  AlertCustomController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 27/07/2024.
//

import UIKit

class AlertCustomController: UIViewController {
    
        lazy var scrollView: UIScrollView = {
            let scroll = UIScrollView()
            scroll.translatesAutoresizingMaskIntoConstraints = false
            return scroll
        }()

        lazy var imageView: UIImageView = {
            let obj = UIImageView()
            obj.contentMode = .scaleAspectFit
            obj.image = UIImage(named: "DFLogo")
            obj.translatesAutoresizingMaskIntoConstraints = false
            return obj
        }()
        lazy var titleLabel: UILabel = {
            let obj = UILabel()
            obj.text = "Here is my title"
            obj.textColor = UIColor(red: 0.139, green: 0.567, blue: 0.13, alpha: 1)
            obj.font = UIFont(name: "Poppins-SemiBold", size: 18)
            obj.font = .systemFont(ofSize: 18, weight: .semibold)
            obj.textAlignment = .center
            obj.numberOfLines = 0
            obj.lineBreakMode = .byWordWrapping
            obj.translatesAutoresizingMaskIntoConstraints = false
            return obj
        }()
        lazy var messageLabel: UILabel = {
            let obj = UILabel()
            obj.text = "Here is my message."
            obj.textColor = UIColor.black
            obj.font = UIFont(name: "Poppins-Regular", size: 14)
            obj.textAlignment = .center
            obj.numberOfLines = 0
            obj.lineBreakMode = .byWordWrapping
            obj.translatesAutoresizingMaskIntoConstraints = false
            return obj
        }()
        
        lazy var showUrlImage: UIImageView = {
            let obj = UIImageView()
            obj.contentMode = .scaleAspectFit
            obj.translatesAutoresizingMaskIntoConstraints = false
            return obj
        }()
        
        var alertImage = UIImage()
        var titleText = String()
        var messageText = String()
        var attributedMessageText = NSMutableAttributedString()
        var isRound = Bool()
        var isImage = Bool()
        var urlImage = String()
        
        var isTitleDefaultColor: Bool? = false

        override func viewDidLoad() {
            super.viewDidLoad()
            setLayout()
            setValues()
        }
        
        private func setLayout() {
            view.backgroundColor = .clear
            scrollView = RemoveScrollView.instance.removeScrollView(scrollView: scrollView)

            view.addSubview(scrollView)

            if isImage {
                scrollView.addSubview(imageView)
            }
            
            scrollView.addSubview(titleLabel)
            scrollView.addSubview(messageLabel)
            
            if urlImage != "" {
                scrollView.addSubview(showUrlImage)
            }
            
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true

            if isImage {
                
                if isRound == true {
                    
                    imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10).isActive = true
                    imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
                    imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true
                    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true

                    imageView.layer.cornerRadius = imageView.frame.width/2
                    
                } else {
                    
                    imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30).isActive = true
                    imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
                    imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
                    imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true

                }
                
                titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
                
            } else {
                titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30).isActive = true
            }
            
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
            messageLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
            messageLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor).isActive = true
    //        messageLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            
            if urlImage != "" {
                
                if messageLabel.text == "" {
                    //            showUrlImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -100).isActive = true
                    showUrlImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
                } else {
                    //            showUrlImage.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: -100).isActive = true
                    showUrlImage.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10).isActive = true
                }
                //        showUrlImage.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: -100).isActive = true
                showUrlImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
                        showUrlImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
                //        showUrlImage.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -100).isActive = true
    //            showUrlImage.widthAnchor.constraint(equalToConstant: 300).isActive = true
                showUrlImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
                showUrlImage.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
                
            } else {
                messageLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            }

        }

        private func setValues() {
            imageView.image = alertImage
            titleLabel.text = titleText
            if attributedMessageText.string != "" {
                messageLabel.attributedText = attributedMessageText
            } else {
                messageLabel.text = messageText
            }
            
            if let isTitleDefaultColor {
                if isTitleDefaultColor {
                    titleLabel.textColor = UIColor.black
                } else {
                    titleLabel.textColor = UIColor(red: 0.139, green: 0.567, blue: 0.13, alpha: 1)
                }
            } else {
                titleLabel.textColor = UIColor(red: 0.139, green: 0.567, blue: 0.13, alpha: 1)
            }
            
            if urlImage != "" {
    //            DispatchQueue.main.async {
    //                self.showUrlImage.downloadImage(from: self.urlImage)
    //            }
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: URL(string: self.urlImage) ?? URL(fileURLWithPath: "")) //Data(contentsOf: self.urlImage) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        if let data {
                            self.showUrlImage.image = UIImage(data: data)
                        }
                    }
                }
            }
            
    //        titleLabel.attributedText = attributedString(titleText, 15, .systemOrange)
    //        messageLabel.attributedText = attributedString(messageText, 15, .systemOrange)
        }
        
        
    //    AC.setValue(attributedString(Title ?? "", 15, .systemOrange), forKey: "attributedTitle")
    //    AC.setValue(attributedString(Message ?? "", 12, .systemGreen), forKey: "attributedMessage")
        
        // added a new function for attributedString
            func attributedString(_ text: String, _ fontSize: CGFloat, _ color: UIColor) -> NSAttributedString {
                let attributedString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: fontSize), NSAttributedString.Key.foregroundColor: color])
                return attributedString
            }
        

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            if urlImage != "" {
                preferredContentSize.height = showUrlImage.frame.size.height + showUrlImage.frame.origin.y + 30
            } else {
                preferredContentSize.height = messageLabel.frame.size.height + messageLabel.frame.origin.y + 30
            }
        }

    }
