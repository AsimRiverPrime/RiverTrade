//
//  UIAlertController+Extensions.swift
//  DeskflexProject
//
//  Created by Ross Rostane on 03/07/2023.
//

import Foundation
import UIKit

extension UIAlertController {

    convenience init(style: UIAlertController.Style, title: String? = nil, message: String? = nil) {
        self.init(title: title, message: message, preferredStyle: style)
    }

    func addAlertAction(title: String, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        addAction(action)
    }

    func setLoginViewController(image: UIImage, title: String, message: String, attributedMessage: NSMutableAttributedString? = nil, isRound: Bool, isImage: Bool, isTitleDefaultColor: Bool? = false, urlImage: String? = "") {
        let vc = AlertCustomController()
        vc.alertImage = image
        vc.titleText = title
        if attributedMessage == nil {
            vc.messageText = message
        } else {
            vc.attributedMessageText = attributedMessage ?? NSMutableAttributedString.init(string: "")
        }
//        vc.messageText = message
        vc.isRound = isRound
        vc .isImage = isImage
        vc.isTitleDefaultColor = isTitleDefaultColor
        vc.urlImage = urlImage ?? ""
        setValue(vc, forKey: "contentViewController")
    }

}

extension UIAlertController {
    
    //Set background color of UIAlertController
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    
    //Set title font and title color
    func setTitlet(font: UIFont?, color: UIColor?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)//1
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : titleFont],//2
                                          range: NSMakeRange(0, title.utf8.count))
        }
        
        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor],//3
                                          range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle")//4
    }
    
    //Set message font and message color
    func setMessage(font: UIFont?, color: UIColor?) {
        guard let message = self.message else { return }
        let attributeString = NSMutableAttributedString(string: message)
        if let messageFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : messageFont],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        
        if let messageColorColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : messageColorColor],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedMessage")
    }
    
    //Set tint color of UIAlertController
    func setTint(color: UIColor) {
        self.view.tintColor = color
    }
}
