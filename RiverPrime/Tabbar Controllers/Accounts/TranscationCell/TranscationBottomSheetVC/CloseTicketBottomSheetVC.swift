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
    var ticketName = String()
    var datee = String()
    
    var totalValue: Double?
    var vm = TransactionCellVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        
        //        self.lbl_symbolName.text = closeData?.symbol
        self.lbl_positionNumber.text = "#\(closeData?.position ?? 0)"
        
        getSymbolIcon()
        
        if closeData?.action == 0 {
            ticketName = "B"
            self.lbl_ticketName.text = "Buy Ticket"
        }else if closeData?.action == 1 {
            ticketName = "S"
            self.lbl_ticketName.text = "Sell Ticket"
        }else if closeData?.action == 2 {
            ticketName = "BL" // but limit
            self.lbl_ticketName.text = "Buy Ticket"
        }else if closeData?.action == 3 {
            ticketName = "SL"  // Sell limit
            self.lbl_ticketName.text = "Sell Ticket"
        }else if closeData?.action == 4 {
            ticketName = "BS" // buy stop
            self.lbl_ticketName.text = "Buy Ticket"
        }else if closeData?.action == 5 {
            ticketName = "SS"  // Sell Stop
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
        
        if data.symbol.contains(".") {
            getSymbol = String(data.symbol.dropLast())
        } else {
            getSymbol = data.symbol
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
            
            let directionText = data?.direction == 0 ? "IN" : "OUT"
            if data?.action == 0 {
                ticketName = "B"
//                self.lbl_ticketName.text = "Buy Ticket"
            }else if data?.action == 1 {
                ticketName = "S"
//                self.lbl_ticketName.text = "Sell Ticket"
            }else if data?.action == 2 {
                ticketName = "BL" // but limit
//                self.lbl_ticketName.text = "Buy Ticket"
            }else if data?.action == 3 {
                ticketName = "SL"  // Sell limit
//                self.lbl_ticketName.text = "Sell Ticket"
            }else if data?.action == 4 {
                ticketName = "BS" // buy stop
//                self.lbl_ticketName.text = "Buy Ticket"
            }else if data?.action == 5 {
                ticketName = "SS"  // Sell Stop
//                self.lbl_ticketName.text = "Sell Ticket"
            }
            cell.lbl_type.text = "\(ticketName)/\(directionText)"
            
            let volumee = Double(data?.volume ?? 0) / Double(10000)
            cell.lbl_volume.text = "\(volumee)"
            
            let amount = String.formatStringNumber("\(data?.price ?? 0.0)")
            cell.lbl_price.text = amount
            
            let createDate = Date(timeIntervalSince1970: Double(data?.time ?? 0))
            
            let calendar = Calendar.current
            if let updatedDate = calendar.date(byAdding: .hour, value: -3, to: createDate) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy HH:mm:ss"
                dateFormatter.timeZone = .current
                
                cell.lbl_profit.text = dateFormatter.string(from: updatedDate)
            }
            
//            cell.lbl_profit.text = "\(data?.profit ?? 0.0)".trimmedTrailingZeros()
           
//            if data?.profit == 0.0 {
//                cell.lbl_profit.text = "--"
//            }else{
//                cell.lbl_profit.text = "\(data?.profit ?? 0.0)".trimmedTrailingZeros()
//            }
            //            self.totalValue = Double(closeData!.profit)
            let Tprofit = closeData?.totalProfit ?? 0
            let profit = data?.profit ?? 0
            
            if Tprofit < 0  {
                self.lbl_totalPrice.textColor = .systemRed
                let total = "\(Tprofit)".trimmedTrailingZeros()
                self.lbl_totalPrice.text = "-$\(abs(Double(total) ?? 0))"
            } else if Tprofit > 0 {
                self.lbl_totalPrice.textColor = .systemGreen
                let total = "\(Tprofit)".trimmedTrailingZeros()
                self.lbl_totalPrice.text = "$" + total
            }else {
                self.lbl_totalPrice.textColor = .white
                self.lbl_totalPrice.text = "$0"
            }
            
//            if profit < 0 {
//                cell.lbl_profit.textColor = .systemRed
//            }else if profit > 0 {
//                cell.lbl_profit.textColor = .systemGreen
//            }else{
//                cell.lbl_profit.textColor = .white
//            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 35
        }else{
            return 35
        }
    }
}

