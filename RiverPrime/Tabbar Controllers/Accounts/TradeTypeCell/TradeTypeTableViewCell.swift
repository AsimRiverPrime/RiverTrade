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
    case close([CloseModel])
}


//enum OPCType {
//    case open
//    case pending
//    case close
//}

protocol OPCDelegate: AnyObject {
//    func getOPCData(opcType: OPCType, openModel: [OpenModel])
//    func getOPCData(opcType: OPCType, closeModel: [CloseModel])
    func getOPCData(opcType: OPCType)
}

class TradeTypeTableViewCell: BaseTableViewCell {

    @IBOutlet weak var tradeTypeCollectionView: UICollectionView!
    var model: [String] = ["OPEN","PENDING","CLOSED","image"/*,"test","test1","test2","test3"*/]
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
 
        fetchPositions(index: 0)
        
//        vm.OPCApi(opcType: .open) { [weak self] positions, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    print("Error fetching positions: \(error)")
//                    // Handle the error (show an alert, etc.)
//                } else if let positions = positions {
//                    // Use the positions (reload a table view, etc.)
//                    for position in positions {
//                        print("Position: \(position.position), Symbol: \(position.symbol), Profit: \(position.profit)")
//                    }
//                }
//            }
//        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension TradeTypeTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      //  return 10 // Number of items in the collection view
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TradeTypeCollectionViewCell", for: indexPath) as! TradeTypeCollectionViewCell
       
        cell.onRefreshImageButtonClick = {
            [self] sender in
            print("onRefreshImageButtonClick")
            self.dynamicDropDownButton(sender, list: refreshList) { index, item in
                print("drop down index = \(index)")
                print("drop down item = \(item)")
            }
        }
       
        cell.lbl_tradetype.text = model[indexPath.row]
            if indexPath.row == selectedIndex {
            cell.selectedColorView.isHidden = false
        }else{
            cell.selectedColorView.isHidden = true
        }
        if indexPath.row == model.count-1 {
            cell.sepratorView.isHidden = true
            cell.refreshImage.isHidden = false
            cell.refreshImageButton.isHidden = false
            cell.lbl_tradetype.isHidden = true
            
            /* if selectedIndex == model.count - 1 {
               cell.onRefreshImageButtonClick = {
                    [self] sender in
                    print("onRefreshImageButtonClick")
                    self.dynamicDropDownButton(sender, list: refreshList) { index, item in
                        print("drop down index = \(index)")
                        print("drop down item = \(item)")
                    }
                }
            }*/
//            let image = UIImageView()
//            image.image = UIImage(named: "currencyIcon")
//            image.frame = CGRect(x: cell.sepratorView.frame.origin.x, y: 0, width: 40, height: 40)
            
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
//            if indexPath.row != model.count-1 {
//                collectionView.reloadData()
//            }
            
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
        //        // get the Collection View width and height
        
//        if indexPath.row == model.count-1 {
//            return CGSize(width: 200, height: 40)
//        }
        
        let data = model[indexPath.row]
        return CGSize(width: data.count + 80, height: 40)
        
    }
}

extension TradeTypeTableViewCell {
    
    func fetchPositions(index: Int) {
        if index == 0 {
            
//////            ActivityIndicator.shared.showCell(in: self)
////            activityIndicator.show(in: self.contentView)
//            SVProgressHUD.show()
            
            // Execute the fetch on a background thread
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.vm.OPCApi(index: index) { openData, pendingData, closeData, error in
//////                    ActivityIndicator.shared.hideCell(from: self!)
////                    self?.activityIndicator.hide()
//                    SVProgressHUD.dismiss()
                    // Switch back to the main thread to update the UI
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error fetching positions: \(error)")
                            // Handle the error (e.g., show an alert)
                        } else if let positions = openData {
//                            // Use the positions (e.g., reload a table view)
//                            for position in positions {
//                                print("Position: \(position.position), Symbol: \(position.symbol), Profit: \(position.profit)")
//                            }
//                            // If you have a UITableView, call reloadData() here
                            
//                            self?.delegateOpen?.getOPCData(opcType: .open, openModel: positions)
                            self?.delegate?.getOPCData(opcType: .open(positions))
                            
                        }
                    }
                }
            }
            
        } else if index == 1 {
            
//////            ActivityIndicator.shared.showCell(in: self)
////            activityIndicator.show(in: self.contentView)
//            SVProgressHUD.show()
            
            // Execute the fetch on a background thread
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.vm.OPCApi(index: index) { openData, pendingData, closeData, error in
//////                    ActivityIndicator.shared.hideCell(from: self!)
////                    self?.activityIndicator.hide()
//                    SVProgressHUD.dismiss()
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
            
//////            ActivityIndicator.shared.showCell(in: self)
////            activityIndicator.show(in: self.contentView)
//            SVProgressHUD.show()
            
            // Execute the fetch on a background thread
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.vm.OPCApi(index: index) { openData, pendingData, closeData, error in
//////                    ActivityIndicator.shared.hideCell(from: self!)
////                    self?.activityIndicator.hide()
//                    SVProgressHUD.dismiss()
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

/*
extension TradeTypeTableViewCell {
    
    private func dynamicDropDownButton(_ sender: UIButton, list: [String]) {
        
        CustomDropDown.instance.dropDownButton(list: list, sender: sender) { [weak self] (index: Int, item: String) in
            print("this is the selected index value:\(index)")
            print("this is the selected item name :\(item)")
//            guard let self = self else { return }
            sender.setTitle(item, for: .normal)
        }
        
    }
    
}
*/

