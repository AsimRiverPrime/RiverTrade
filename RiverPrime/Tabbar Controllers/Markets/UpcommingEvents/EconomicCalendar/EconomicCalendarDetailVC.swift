//
//  EconomicCalendarDetailVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 16/12/2024.
//

import UIKit

class EconomicCalendarDetailVC: UIViewController {

    @IBOutlet weak var countryFlagIcon: UIImageView!
    @IBOutlet weak var lbl_event: UILabel!
    @IBOutlet weak var lbl_symbol: UILabel!
    
    @IBOutlet weak var firstIcon: UIImageView!
    @IBOutlet weak var secondIcon: UIImageView!
    @IBOutlet weak var thridIcon: UIImageView!
    @IBOutlet weak var lbl_date: UILabel!
    
    @IBOutlet weak var lbl_actual: UILabel!
    @IBOutlet weak var lbl_previous: UILabel!
    @IBOutlet weak var lbl_forecast: UILabel!
    @IBOutlet weak var lbl_teforecast: UILabel!
    
    @IBOutlet weak var lbl_Category: UILabel!
    
    var selectedItem: Event?
    
    let cellObje = UpcomingEventsTableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        setupData()
//
//        self.setNavBar(vc: self, isBackButton: false, isBar: false)
//        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: MarketsViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .darkGray, barColor: .clear)
    }
   
   func setupData() {
       
       lbl_event.text = selectedItem?.event
       lbl_date.text = DateHelper.timeAgo(from: selectedItem?.date ?? "")
       lbl_symbol.text = selectedItem?.symbol ?? ""
       
       lbl_actual.text = selectedItem?.actual
       lbl_forecast.text = selectedItem?.forecast
       lbl_previous.text = selectedItem?.previous
       lbl_teforecast.text = selectedItem?.teForecast
       if selectedItem?.forecast == "" {
           lbl_forecast.text = "-"
       }
       lbl_Category.text = selectedItem?.category ?? ""
       
       switch selectedItem?.importance ?? 0 {
      
           case 1:
               self.firstIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
               self.secondIcon.image = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
               self.thridIcon.image = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
           case 2:
               self.firstIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
               self.secondIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
               self.thridIcon.image = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
           case 3:
               self.firstIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
               self.secondIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
               self.thridIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
           default:
               self.firstIcon.image = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
               self.secondIcon.image = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
               self.thridIcon.image = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
           }

       if let isoCode = cellObje.countryToISOCode[selectedItem?.country ?? ""] {
           let flagEmoji = isoCode.flagEmoji() // Generate flag emoji
//              let flagEmoji = "PK".flagEmoji()
           countryFlagIcon.image = cellObje.emojiToImage(emoji: flagEmoji) // Render emoji as image
       } else {
           countryFlagIcon.image = UIImage(named: "") // Fallback image
       }
       countryFlagIcon.layer.cornerRadius = countryFlagIcon.frame.size.height / 2
       countryFlagIcon.clipsToBounds = true
       countryFlagIcon.contentMode = .scaleAspectFill
       countryFlagIcon.layer.borderWidth = 1
       countryFlagIcon.layer.borderColor = UIColor.darkGray.cgColor
    }

}
