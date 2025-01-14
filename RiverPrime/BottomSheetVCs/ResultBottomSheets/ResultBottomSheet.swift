//
//  ResultBottomSheet.swift
//  RiverPrime
//
//  Created by Ross Rostane on 25/11/2024.
//

import UIKit

class ResultBottomSheet: BottomSheetController {
    
    var setTitle = String()
    var btnList = [UIButton]()
    
    var resultType: iResultType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        styling()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
    }
    
    private func styling() {
        
    }
    
    private func setup() {
        
        lazy var myTitleLbl: UILabel = {
            let lbl = UILabel()
            lbl.text = setTitle
            lbl.textColor = .white
            lbl.translatesAutoresizingMaskIntoConstraints = false
            return lbl
        }()
        
        view.addSubview(myTitleLbl)
        
        myTitleLbl.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        myTitleLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        
        var list = [String]()
        
        switch resultType {
        case .Summary:
            list = ["Summary", "Benefits"]
            break
        case .RealAccount:
            list = ["Real accounts", "Demo", "Archived"]
            break
        case .Last7days:
            list = ["7 Days", "30 Days", "90 Days", "Year"]
            break
        default:
            break
        }
        
        btnList.removeAll()
        
        for i in 0...list.count-1 {
            
            lazy var titleBtn: UIButton = {
                let btn = UIButton()
//                btn.setTitle("", for: .normal)
                btn.titleLabel?.text = list[i]
                btn.setImage(UIImage(named: "unselectRadio"), for: .normal)
                btn.translatesAutoresizingMaskIntoConstraints = false
                return btn
            }()
            
            lazy var titleLbl: UILabel = {
                let lbl = UILabel()
                lbl.text = list[i]
                lbl.textColor = .white
                lbl.translatesAutoresizingMaskIntoConstraints = false
                return lbl
            }()
            
            view.addSubview(titleBtn)
            view.addSubview(titleLbl)
            
            btnList.append(titleBtn)
            
            if i == 0 {
                titleBtn.topAnchor.constraint(equalTo: myTitleLbl.bottomAnchor, constant: 20).isActive = true
            } else {
                titleBtn.topAnchor.constraint(equalTo: btnList[i-1].bottomAnchor, constant: 20).isActive = true
            }
            titleBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
            titleBtn.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
            titleBtn.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
            
            titleLbl.leadingAnchor.constraint(equalTo: titleBtn.trailingAnchor, constant: 10).isActive = true
            titleLbl.centerYAnchor.constraint(equalTo: titleBtn.centerYAnchor).isActive = true
            
        }
        
    }
    
}
