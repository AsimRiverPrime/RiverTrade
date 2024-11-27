//
//  ResultsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit

enum iResultVCType {
    case SummaryAllRealAccountFilter
    case DaysFilter
    case BenifitAllRealAccountFilter
    case ExnessStartTrading
    case ExnessTrading
}

protocol iResultVCDelegate: AnyObject {
    func resultClicks(resultVCType: iResultVCType)
}

protocol iResultDelegate: AnyObject {
    func resultClicks(resultType: iResultType)
}

enum iResultType {
    case Summary
    case RealAccount
    case Last7days
}

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
//    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var SummaryBtn: UIButton!
    @IBOutlet weak var RealAccountBtn: UIButton!
    @IBOutlet weak var LastDaysBtn: UIButton!
    @IBOutlet weak var labelAmmount: UILabel!
    
    weak var delegate: iResultVCDelegate?
    weak var delegateResult: iResultDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        // Set the background color to black
//        segmentController.backgroundColor = .black
//        
//        // Set the selected segment text color to yellow
//        segmentController.setTitleTextAttributes([.foregroundColor: UIColor.systemYellow], for: .normal)
//        
//        // Set the border color to yellow
//        segmentController.layer.borderWidth = 2
//        segmentController.layer.borderColor = UIColor.systemYellow.cgColor
//        
//        // Customize the selected segment appearance
//        segmentController.selectedSegmentIndex = 0 // Set default selected index
//        
//        // Set the tint color (selected segment highlight color) to yellow
//        segmentController.tintColor = .systemYellow
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
        
        SummaryBtn.layer.borderWidth = 1
        SummaryBtn.layer.borderColor = UIColor.systemYellow.cgColor
        SummaryBtn.layer.cornerRadius = 5
        
        RealAccountBtn.layer.borderWidth = 1
        RealAccountBtn.layer.borderColor = UIColor.systemYellow.cgColor
        RealAccountBtn.layer.cornerRadius = 5
        
        LastDaysBtn.layer.borderWidth = 1
        LastDaysBtn.layer.borderColor = UIColor.systemYellow.cgColor
        LastDaysBtn.layer.cornerRadius = 5
        
//        tblView.registerCells([
//            ResultTopViewCell.self,ResultsFilterViewCell.self, SummaryTradingActivityCell.self
//        ])
        
        tblView.registerCells([
            AccountDetailTVC.self
        ])
        
        self.delegate = self
        self.delegateResult = self
        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
        
    }
    
    @IBAction func SummaryBtn(_ sender: UIButton) {
        let vc = Utilities.shared.getViewController(identifier: .resultBottomSheet, storyboardType: .bottomSheetPopups) as! ResultBottomSheet
        vc.resultType = .Summary
        vc.setTitle = "Results"
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .small, VC: vc)
    }
    
    @IBAction func RealAccountBtn(_ sender: UIButton) {
        let vc = Utilities.shared.getViewController(identifier: .resultBottomSheet, storyboardType: .bottomSheetPopups) as! ResultBottomSheet
        vc.resultType = .RealAccount
        vc.setTitle = "Show"
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .small, VC: vc)
    }
    
    @IBAction func LastDaysBtn(_ sender: UIButton) {
        let vc = Utilities.shared.getViewController(identifier: .resultBottomSheet, storyboardType: .bottomSheetPopups) as! ResultBottomSheet
        vc.resultType = .Last7days
        vc.setTitle = "Period"
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customSmall, VC: vc)
    }
    
}

extension ResultsViewController {
    
    @objc func notificationPopup(_ notification: NSNotification) {
        
        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
            print("Received ammount: \(ammount)")
            self.labelAmmount.text = "$\(ammount)"
        }
        
    }
    
}

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
//        if section == 0 {
//            return 1
//        } else if section == 1 {
//            return 1
//        } else if section == 2 {
//            return 1
//        } else{
//            return 1
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(with: AccountDetailTVC.self, for: indexPath)
        cell.backgroundColor = .clear
        return cell
        
//        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell(with: ResultTopViewCell.self, for: indexPath)
//            cell.setHeaderUI()
//            cell.delegate = self
//            return cell
//            
//        } else if indexPath.section == 1 {
//            let cell = tableView.dequeueReusableCell(with: ResultsFilterViewCell.self, for: indexPath)
//            cell.backgroundColor = .clear
//                        
//            cell.onAllRealAccountsFilterButtonClick = {
//                [self] in
//                print("Click on onAllRealAccountsFilterButtonClick")
//                self.delegate?.resultClicks(resultVCType: .SummaryAllRealAccountFilter)
//            }
//            
//            cell.onDaysFilterButton = {
//                [self] in
//                print("Click on onDaysFilterButton")
//                self.delegate?.resultClicks(resultVCType: .DaysFilter)
//            }
//            
//            cell.onBenefitsAllRealAccountsFilterButtonClick = {
//                [self] in
//                print("Click on onBenefitsAllRealAccountsFilterButtonClick")
//                self.delegate?.resultClicks(resultVCType: .BenifitAllRealAccountFilter)
//            }
//            
////            self.setNeedsLayout()
//            return cell
//            
//        } else if indexPath.section == 2 {
//            
//            if GlobalVariable.instance.resultTopButtonType == "exnessBenefits" {
//                let cell = tableView.dequeueReusableCell(with: BenefitsTradingActivityCell.self, for: indexPath)
//                
//                cell.onStartTradingButtonClick = {
//                    [self] in
//                    print("onStartTradingButtonClick")
//                    self.delegate?.resultClicks(resultVCType: .ExnessStartTrading)
//                }
//                
//                return cell
//            } else {
//                let cell = tableView.dequeueReusableCell(with: SummaryTradingActivityCell.self, for: indexPath)
//                
//                cell.onTradeButtonClick = {
//                    [self] in
//                    print("onTradeButtonClick")
//                    self.delegate?.resultClicks(resultVCType: .ExnessTrading)
//                }
//                
//                return cell
//            }
//            
//        }else{
//            let cell = tableView.dequeueReusableCell(with: TopNewsTableViewCell.self, for: indexPath)
//            cell.backgroundColor = .clear
//            return cell
//        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

extension ResultsViewController: ResultTopDelegate {
    
    func resultTopTap(_ resultTopButtonType: ResultTopButtonType, index: Int) {
        print("resultTopButtonType delegate method = \(resultTopButtonType)")
        if index == 100 {
            GlobalVariable.instance.resultTopButtonType = "summary"
            
            tblView.registerCells([
                ResultTopViewCell.self,ResultsFilterViewCell.self, SummaryTradingActivityCell.self//, TradingSignalTableViewCell.self, UpcomingEventsTableViewCell.self, TopNewsTableViewCell.self
            ])
            
        } else {
            GlobalVariable.instance.resultTopButtonType = "exnessBenefits"
            
            tblView.registerCells([
                ResultTopViewCell.self,ResultsFilterViewCell.self, BenefitsTradingActivityCell.self//, TradingSignalTableViewCell.self, UpcomingEventsTableViewCell.self, TopNewsTableViewCell.self
            ])
            
        }
        tblView.reloadSections([1,2], with: .none)
    }
    
}

extension ResultsViewController: iResultDelegate {
    
    func resultClicks(resultType: iResultType) {
        switch resultType {
        case .Summary:
            break
        case .RealAccount:
            break
        case .Last7days:
            break
        }
    }
    
}

extension ResultsViewController: iResultVCDelegate {
    
    func resultClicks(resultVCType: iResultVCType) {
        switch resultVCType {
        case .SummaryAllRealAccountFilter:
            let vc = Utilities.shared.getViewController(identifier: .allRealAccountsVC, storyboardType: .bottomSheetPopups) as! AllRealAccountsVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            break
        case .DaysFilter:
            break
        case .BenifitAllRealAccountFilter:
            break
        case .ExnessStartTrading:
            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .bottomSheetPopups) as! SelectAccountTypeVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            break
        case .ExnessTrading:
            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .bottomSheetPopups) as! SelectAccountTypeVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            break
        }
    }
    
}
