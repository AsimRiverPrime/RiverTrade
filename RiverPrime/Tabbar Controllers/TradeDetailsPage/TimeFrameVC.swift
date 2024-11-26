//
//  TimeFrameVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 31/10/2024.
//

import UIKit

protocol TimeFrameVCDelegate: AnyObject {
    func didSelectTimeFrame(value: String)
}

class TimeFrameVC: UIViewController {
    
    @IBOutlet weak var timeTableView: UITableView!
    
    var timeFrameValues = ["1 Minute","5 Minutes","15 Minutes","30 Minutes","1 hour","4 hours","1 day","1 week","1 month"]
    
    var selectedIndex: Int?
    
    private var isInitialLoad = true
    
    weak var delegate: TimeFrameVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCell()
        
        // Check if this is the first time the view controller is loaded
//        if !UserDefaults.standard.bool(forKey: "hasLoadedTimeFrameVC") {
//            selectedIndex = IndexPath(row: 2, section: 0)
//            UserDefaults.standard.set(true, forKey: "hasLoadedTimeFrameVC")
//        }
        
    }
    
    private func registerCell() {
        
        timeTableView.registerCells([
            TimeFrameTVCell.self
        ])
        timeTableView.isScrollEnabled = false
        timeTableView.delegate = self
        timeTableView.dataSource = self
        timeTableView.reloadData()
        
    }
    
}

extension TimeFrameVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeFrameValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: TimeFrameTVCell.self, for: indexPath)
        cell.selectionStyle = .none
        let model = timeFrameValues[indexPath.row]
        cell.lbl_timeValue.text = model
        
        if indexPath.row == selectedIndex {
            cell.img_checkImage?.isHidden = false // Show image for selected cell
        } else {
            cell.img_checkImage?.isHidden = true // Hide image for other cells
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        tableView.deselectRow(at: indexPath, animated: true)
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeFrameTVCell") as? TimeFrameTVCell
        var values = ""
        selectedIndex = indexPath.row
        
        var selectedValue = timeFrameValues[indexPath.row]
        if  selectedValue.contains("Minutes") {
            values = selectedValue.replacingOccurrences(of: "Minutes", with: "Min")
        }else if selectedValue.contains("Minute") {
            values = selectedValue.replacingOccurrences(of: "Minute", with: "Min")
        } else if selectedValue.contains("hours") {
            values = selectedValue.replacingOccurrences(of: "hours", with: "Hr")
        } else if selectedValue.contains("hour") {
            values = selectedValue.replacingOccurrences(of: "hour", with: "Hr")
        } else if selectedValue.contains("day") {
            values = selectedValue.replacingOccurrences(of: "day", with: "day")
        } else if selectedValue.contains("week") {
            values = selectedValue.replacingOccurrences(of: "week", with: "W")
        }else if selectedValue.contains("month") {
            values = selectedValue.replacingOccurrences(of: "month", with: "Mon")
        }
        // Pass the selected value to the delegate
        delegate?.didSelectTimeFrame(value: values)
        
        // Close the TimeFrameVC
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
}
