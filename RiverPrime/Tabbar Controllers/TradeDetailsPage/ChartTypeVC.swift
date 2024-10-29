//
//  ChartTypeVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 29/10/2024.
//

import UIKit

protocol ChartOptionsDelegate: AnyObject {
    func didSelectChartType(_ chartType: ChartType)
}

enum ChartType {
    case candlestick
    case area
    case bar
}

class ChartTypeVC: UIViewController {

    weak var delegate: ChartOptionsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func lineChart_action(_ sender: Any) {
        print("Area Chart btn clicked")
        delegate?.didSelectChartType(.area)
               dismiss(animated: true, completion: nil)
    }
    
    @IBAction func barChart_action(_ sender: Any) {
        print("bar Chart btn clicked")
        delegate?.didSelectChartType(.bar)
               dismiss(animated: true, completion: nil)
    }
    
    @IBAction func candelChart_action(_ sender: Any) {
        print("candle Chart btn clicked")
        delegate?.didSelectChartType(.candlestick)
               dismiss(animated: true, completion: nil)
    }
    
    
}
