//
//  String+Extension.swift
//  RiverPrime
//
//  Created by Ross Rostane on 12/11/2024.
//

import Foundation
import UIKit
//
//extension String {
//func attributedStringWithColor(_ colorizeWords: [String], color: UIColor, characterSpacing: UInt? = nil, boldWords: [String] = []) -> NSAttributedString {
//        // Create a mutable attributed string based on the original string.
//        let attributedString = NSMutableAttributedString(string: self)
//
//        // Apply color and bold attributes to the specified words.
//        colorizeWords.forEach { word in
//            let range = (self as NSString).range(of: word)
//
//            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
//
//            if boldWords.contains(word) {
//                // Make the specified words bold.
//                attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize), range: range)
//            }
//        }
//
//        // Apply character spacing if specified.
//        guard let characterSpacing = characterSpacing else {
//            return attributedString
//        }
//
//        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
//
//        return attributedString
//    }
//}
////
////extension String {
////    func attributedStringWithColor(
////        _ colorizeWords: [String],
////        color: UIColor,
////        characterSpacing: UInt? = nil,
////        boldWords: [String] = [],
////        clickableWords: [String: String] = [:] // Add a dictionary for clickable words with their associated actions
////    ) -> NSAttributedString {
////        // Create a mutable attributed string based on the original string.
////        let attributedString = NSMutableAttributedString(string: self)
////
////        // Apply color and bold attributes to the specified words.
////        colorizeWords.forEach { word in
////            let range = (self as NSString).range(of: word)
////            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
////
////            if boldWords.contains(word) {
////                // Make the specified words bold.
////                attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize), range: range)
////            }
////            
////            // Add clickable action to the words (using NSLinkAttributeName)
////            if let action = clickableWords[word] {
////                attributedString.addAttribute(NSAttributedString.Key.link, value: action, range: range)
////            }
////        }
////
////        // Apply character spacing if specified.
////        if let characterSpacing = characterSpacing {
////            attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
////        }
////
////        return attributedString
////    }
////}
extension String {
    func attributedStringWithColor(
        _ wordsToColor: [String],
        color: UIColor,
        clickableWords: [String] = []
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for word in wordsToColor {
            let range = (self as NSString).range(of: word)
            if range.location != NSNotFound {
                attributedString.addAttribute(.foregroundColor, value: color, range: range)
            }
        }
        return attributedString
    }
}
