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
    
    @IBOutlet weak var checkImage_candel: UIImageView!
    @IBOutlet weak var checkImage_Area: UIImageView!
    @IBOutlet weak var checkImage_bar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        switch GlobalVariable.instance.chartType {
        case .candlestick:
            checkImage_candel.isHidden = false
            checkImage_bar.isHidden = true
            checkImage_Area.isHidden = true
        case .area:
            checkImage_candel.isHidden = true
            checkImage_bar.isHidden = true
            checkImage_Area.isHidden = false
        case .bar:
            checkImage_candel.isHidden = true
            checkImage_bar.isHidden = false
            checkImage_Area.isHidden = true
        }
    }
    
    @IBAction func lineChart_action(_ sender: Any) {
        print("Area Chart btn clicked")
        checkImage_candel.isHidden = true
        checkImage_bar.isHidden = true
        checkImage_Area.isHidden = false
        GlobalVariable.instance.chartType = .area
        
        delegate?.didSelectChartType(.area)
               dismiss(animated: true, completion: nil)
    }
    
    @IBAction func barChart_action(_ sender: Any) {
        print("bar Chart btn clicked")
        checkImage_candel.isHidden = true
        checkImage_bar.isHidden = false
        checkImage_Area.isHidden = true
        GlobalVariable.instance.chartType = .bar
        delegate?.didSelectChartType(.bar)
               dismiss(animated: true, completion: nil)
    }
    
    @IBAction func candelChart_action(_ sender: Any) {
        checkImage_candel.isHidden = false
        checkImage_bar.isHidden = true
        checkImage_Area.isHidden = true
        GlobalVariable.instance.chartType = .candlestick
        print("candle Chart btn clicked")
        delegate?.didSelectChartType(.candlestick)
               dismiss(animated: true, completion: nil)
    }
    
    
}
