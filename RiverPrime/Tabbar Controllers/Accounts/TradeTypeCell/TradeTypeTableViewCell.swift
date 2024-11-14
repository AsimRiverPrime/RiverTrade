//
//  TradeTypeTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 15/07/2024.
//

import UIKit
import SVProgressHUD

//struct OPCModel {
//    var symbol = String()
//}

enum OPCType {
    case open([OpenModel])
    case pending([PendingModel])
    case close([NewCloseModel])
}

protocol OPCDelegate: AnyObject {
    func getOPCData(opcType: OPCType)
}

class TradeTypeTableViewCell: BaseTableViewCell {

    @IBOutlet weak var tradeTypeCollectionView: UICollectionView!
    var model: [String] = ["Open","Pending","Closed","image"/*,"test","test1","test2","test3"*/]
    var refreshList = ["by instrument", "by volume", "by open time"]
    var selectedIndex = 0
    
    var vm = TradeTypeCellVM()
    
    let activityIndicator = NewActivityIndicator()
    
    weak var delegate: OPCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tradeTypeCollectionView.delegate = self
        tradeTypeCollectionView.dataSource = self
        tradeTypeCollectionView.register(UINib(nibName: "TradeTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TradeTypeCollectionViewCell")
        tradeTypeCollectionView.isScrollEnabled = false

        fetchPositions(index: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.OPCListDissmisal(_:)), name: .OPCListDismissall, object: nil)
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func OPCListDissmisal(_ notification: Notification) {
        if let userInfo = notification.userInfo,
               let receivedString = userInfo["OPCType"] as? String {
                print("Received string: \(receivedString)")
            if receivedString == "Open" {
                DispatchQueue.global(qos: .background).async { [weak self] in
                    self?.vm.OPCApi(index: 0) { openData, pendingData, closeData, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error fetching positions: \(error)")
                                // Handle the error (e.g., show an alert)
                            } else if let positions = openData {
                              
                                self?.delegate?.getOPCData(opcType: .open(positions))

                            }
                        }
                    }
                }
            }else if receivedString == "Pending" {
                DispatchQueue.global(qos: .background).async { [weak self] in
                    self?.vm.OPCApi(index: 1) { openData, pendingData, closeData, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error fetching positions: \(error)")
                               
                            } else if let orders = pendingData {
                                self?.delegate?.getOPCData(opcType: .pending(orders))
                            }
                        }
                    }
                }
            }
            }
        // Execute the fetch on a background thread
        
        
    }
    
}

extension TradeTypeTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      //  return 10 // Number of items in the collection view
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TradeTypeCollectionViewCell", for: indexPath) as! TradeTypeCollectionViewCell
       
//        cell.onRefreshImageButtonClick = {
//            [self] sender in
//            print("onRefreshImageButtonClick")
//            self.dynamicDropDownButton(sender, list: refreshList) { index, item in
//                print("drop down index = \(index)")
//                print("drop down item = \(item)")
//            }
//        }
       
        cell.lbl_tradetype.text = model[indexPath.row]
            if indexPath.row == selectedIndex {
//            cell.selectedColorView.isHidden = false
                cell.backgroundColor = .systemYellow
        }else{
//            cell.selectedColorView.isHidden = true
            cell.backgroundColor = .clear
        }
        if indexPath.row == model.count-1 {
            cell.sepratorView.isHidden = true
            cell.refreshImage.isHidden = false
            cell.refreshImageButton.isHidden = false
            cell.lbl_tradetype.isHidden = true
       
        } else {
            cell.sepratorView.isHidden = false
            cell.refreshImage.isHidden = true
            cell.refreshImageButton.isHidden = true
            cell.lbl_tradetype.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath){
            selectedIndex = indexPath.row

            if indexPath.row != model.count-1 {
                fetchPositions(index: indexPath.row)
            }
            
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath){
            cell.backgroundColor = .clear
//            self.delegate?.getOPCData(opcType: .open, opcModel: .init(symbol: "Gold"))
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        let data = model[indexPath.row]
        return CGSize(width: data.count + 80, height: 40)
        
    }
}

extension TradeTypeTableViewCell {
    
    func fetchPositions(index: Int) {
        if index == 0 {
      
            // Execute the fetch on a background thread
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.vm.OPCApi(index: index) { openData, pendingData, closeData, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error fetching positions: \(error)")
                            // Handle the error (e.g., show an alert)
                        } else if let positions = openData {
//
                            self?.delegate?.getOPCData(opcType: .open(positions))
                            
                        }
                    }
                }
            }
            
        } else if index == 1 {
    
            // Execute the fetch on a background thread
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.vm.OPCApi(index: index) { openData, pendingData, closeData, error in

                    // Switch back to the main thread to update the UI
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error fetching positions: \(error)")
                            // Handle the error (e.g., show an alert)
                        } else if let orders = pendingData {
                            self?.delegate?.getOPCData(opcType: .pending(orders))
                        }
                    }
                }
            }
            
        } else if index == 2 {
   
            
            // Execute the fetch on a background thread
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.vm.OPCApi(index: index) { openData, pendingData, closeData, error in

                    // Switch back to the main thread to update the UI
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error fetching positions: \(error)")
                            // Handle the error (e.g., show an alert)
                        } else if let orders = closeData {
                          
                            self?.delegate?.getOPCData(opcType: .close(orders))
                        }
                    }
                }
            }
            
        }
    }
    
   
}
