//
//  CloseTicketBottomSheetVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 04/10/2024.
//

import UIKit

class CloseTicketBottomSheetVC: UIViewController {
    
    @IBOutlet weak var lbl_ticketName: UILabel!
    @IBOutlet weak var lbl_positionNumber: UILabel!
//    @IBOutlet weak var lbl_symbolName: UILabel!
    @IBOutlet weak var lbl_totalPrice: UILabel!
    @IBOutlet weak var image_SymbolIcon: UIImageView!
    
    @IBOutlet weak var closeValue_TableView: UITableView!
    
    var closeData: NewCloseModel?
    var ticketName : String?
    
    var totalValue: Double?
    var vm = TransactionCellVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        
//        self.lbl_symbolName.text = closeData?.symbol
        self.lbl_positionNumber.text = "#\(closeData?.position ?? 0)"
        
        getSymbolIcon()
        
        if closeData?.action == 0 {
            ticketName = "BUY"
            self.lbl_ticketName.text = "Buy Ticket"
        }else if closeData?.action == 1 {
            ticketName = "SELL"
            self.lbl_ticketName.text = "Sell Ticket"
        }else if closeData?.action == 2 {
            ticketName = "BUY Limit"
            self.lbl_ticketName.text = "Buy Ticket"
        }else if closeData?.action == 3 {
            ticketName = "SELL Limit"
            self.lbl_ticketName.text = "Sell Ticket"
        }else if closeData?.action == 4 {
            ticketName = "BUY Stop"
            self.lbl_ticketName.text = "Buy Ticket"
        }else if closeData?.action == 5 {
            ticketName = "SELL Stop"
            self.lbl_ticketName.text = "Sell Ticket"
        }
        
    }
    
    private func getSymbolIcon() {
        
        guard let data = closeData else { return }
        
        // Get saved symbols as a dictionary
        guard let savedSymbolsDict = vm.getSavedSymbolsDictionary() else {
            return
        }
        
        var getSymbol = ""
        
        if data.symbol.contains("..") {
            getSymbol = String(data.symbol.dropLast())
            getSymbol = String(getSymbol.dropLast())
        } else if data.symbol.contains(".") {
            getSymbol = String(data.symbol.dropLast())
        } else {
            getSymbol = data.symbol
        }
        
        // Retrieve the symbol data using the name as the key
        if let symbolData = savedSymbolsDict[getSymbol] {
            // Return the icon_url if a match is found
            if symbolData.name == "Platinum" {
                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/silver.png")
                image_SymbolIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }else if symbolData.name == "NDX100" {
                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/ndx.png")
                image_SymbolIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }else if symbolData.name == "DJI30" {
                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/dj30.png")
                image_SymbolIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }else{
                let imageUrl = URL(string: symbolData.icon_url)
                image_SymbolIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }
        }
        
    }
    
    private func registerCell() {
        closeValue_TableView.registerCells([
            CloseTicketSectionCell.self , CloseTicketTBCell.self
        ])
        closeValue_TableView.delegate = self
        closeValue_TableView.dataSource = self
        closeValue_TableView.reloadData()
    }
    
    
}

extension CloseTicketBottomSheetVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }else{
            return closeData?.repeatedFilteredArray.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: CloseTicketSectionCell.self, for: indexPath)
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(with: CloseTicketTBCell.self, for: indexPath)
            
            let data = closeData?.repeatedFilteredArray[indexPath.row]
            
            if data?.direction == 0 {
                cell.lbl_type.text = "IN"
            }else{
                cell.lbl_type.text = "OUT"
            }
            let volumee = Double(data?.volume ?? 0) / Double(10000)
            cell.lbl_volume.text = "\(volumee)"
            cell.lbl_price.text = "\(data?.price ?? 0.0)"
            cell.lbl_profit.text = "\(data?.profit ?? 0.0)"
            
            //            self.totalValue = Double(closeData!.profit)
            let Tprofit = closeData?.totalProfit ?? 0
            let profit = data?.profit ?? 0
            
            if Tprofit < 0  {
                self.lbl_totalPrice.textColor = .systemRed
            } else if Tprofit > 0 {
                self.lbl_totalPrice.textColor = .systemGreen
                
            }else {
                self.lbl_totalPrice.textColor = .white
                
            }
            
            if profit < 0 {
                cell.lbl_profit.textColor = .systemRed
            }else if profit > 0 {
                cell.lbl_profit.textColor = .systemGreen
            }else{
                cell.lbl_profit.textColor = .white
            }
            self.lbl_totalPrice.text = "$\(Tprofit)".trimmedTrailingZeros()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 40
        }else{
            return 40
        }
    }
}

