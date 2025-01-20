//
//  UpcomingEventsTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 18/07/2024.
//

import UIKit
import SDWebImage

class UpcomingEventsTableViewCell: UITableViewCell {

    @IBOutlet weak var countryIcon: UIImageView!
    @IBOutlet weak var lbl_event: UILabel!
    @IBOutlet weak var firstIcon: UIImageView!
    @IBOutlet weak var secondIcon: UIImageView!
    @IBOutlet weak var thridIcon: UIImageView!
    @IBOutlet weak var lbl_date: UILabel!
//    @IBOutlet weak var lbl_symbol: UILabel!
    let countryToISOCode: [String: String] = [
        "Afghanistan": "AF",
        "Albania": "AL",
        "Algeria": "DZ",
        "Andorra": "AD",
        "Angola": "AO",
        "Antigua and Barbuda": "AG",
        "Argentina": "AR",
        "Armenia": "AM",
        "Australia": "AU",
        "Austria": "AT",
        "Azerbaijan": "AZ",
        "Bahamas": "BS",
        "Bahrain": "BH",
        "Bangladesh": "BD",
        "Barbados": "BB",
        "Belarus": "BY",
        "Belgium": "BE",
        "Belize": "BZ",
        "Benin": "BJ",
        "Bhutan": "BT",
        "Bolivia": "BO",
        "Bosnia and Herzegovina": "BA",
        "Botswana": "BW",
        "Brazil": "BR",
        "Brunei": "BN",
        "Bulgaria": "BG",
        "Burkina Faso": "BF",
        "Burundi": "BI",
        "Cabo Verde": "CV",
        "Cambodia": "KH",
        "Cameroon": "CM",
        "Canada": "CA",
        "Central African Republic": "CF",
        "Chad": "TD",
        "Chile": "CL",
        "China": "CN",
        "Colombia": "CO",
        "Comoros": "KM",
        "Congo (Congo-Brazzaville)": "CG",
        "Costa Rica": "CR",
        "Croatia": "HR",
        "Cuba": "CU",
        "Cyprus": "CY",
        "Czechia (Czech Republic)": "CZ",
        "Democratic Republic of the Congo": "CD",
        "Denmark": "DK",
        "Djibouti": "DJ",
        "Dominica": "DM",
        "Dominican Republic": "DO",
        "Ecuador": "EC",
        "Egypt": "EG",
        "El Salvador": "SV",
        "Equatorial Guinea": "GQ",
        "Eritrea": "ER",
        "Estonia": "EE",
        "Eswatini (fmr. 'Swaziland')": "SZ",
        "Ethiopia": "ET",
        "Fiji": "FJ",
        "Finland": "FI",
        "France": "FR",
        "Gabon": "GA",
        "Gambia": "GM",
        "Georgia": "GE",
        "Germany": "DE",
        "Ghana": "GH",
        "Greece": "GR",
        "Grenada": "GD",
        "Guatemala": "GT",
        "Guinea": "GN",
        "Guinea-Bissau": "GW",
        "Guyana": "GY",
        "Haiti": "HT",
        "Holy See": "VA",
        "Honduras": "HN",
        "Hungary": "HU",
        "Iceland": "IS",
        "India": "IN",
        "Indonesia": "ID",
        "Iran": "IR",
        "Iraq": "IQ",
        "Ireland": "IE",
        "Israel": "IL",
        "Italy": "IT",
        "Jamaica": "JM",
        "Japan": "JP",
        "Jordan": "JO",
        "Kazakhstan": "KZ",
        "Kenya": "KE",
        "Kiribati": "KI",
        "Kuwait": "KW",
        "Kyrgyzstan": "KG",
        "Laos": "LA",
        "Latvia": "LV",
        "Lebanon": "LB",
        "Lesotho": "LS",
        "Liberia": "LR",
        "Libya": "LY",
        "Liechtenstein": "LI",
        "Lithuania": "LT",
        "Luxembourg": "LU",
        "Madagascar": "MG",
        "Malawi": "MW",
        "Malaysia": "MY",
        "Maldives": "MV",
        "Mali": "ML",
        "Malta": "MT",
        "Marshall Islands": "MH",
        "Mauritania": "MR",
        "Mauritius": "MU",
        "Mexico": "MX",
        "Micronesia": "FM",
        "Moldova": "MD",
        "Monaco": "MC",
        "Mongolia": "MN",
        "Montenegro": "ME",
        "Morocco": "MA",
        "Mozambique": "MZ",
        "Myanmar (formerly Burma)": "MM",
        "Namibia": "NA",
        "Nauru": "NR",
        "Nepal": "NP",
        "Netherlands": "NL",
        "New Zealand": "NZ",
        "Nicaragua": "NI",
        "Niger": "NE",
        "Nigeria": "NG",
        "North Korea": "KP",
        "North Macedonia": "MK",
        "Norway": "NO",
        "Oman": "OM",
        "Pakistan": "PK",
        "Palau": "PW",
        "Palestine State": "PS",
        "Panama": "PA",
        "Papua New Guinea": "PG",
        "Paraguay": "PY",
        "Peru": "PE",
        "Philippines": "PH",
        "Poland": "PL",
        "Portugal": "PT",
        "Qatar": "QA",
        "Romania": "RO",
        "Russia": "RU",
        "Rwanda": "RW",
        "Saint Kitts and Nevis": "KN",
        "Saint Lucia": "LC",
        "Saint Vincent and the Grenadines": "VC",
        "Samoa": "WS",
        "San Marino": "SM",
        "Sao Tome and Principe": "ST",
        "Saudi Arabia": "SA",
        "Senegal": "SN",
        "Serbia": "RS",
        "Seychelles": "SC",
        "Sierra Leone": "SL",
        "Singapore": "SG",
        "Slovakia": "SK",
        "Slovenia": "SI",
        "Solomon Islands": "SB",
        "Somalia": "SO",
        "South Africa": "ZA",
        "South Korea": "KR",
        "South Sudan": "SS",
        "Spain": "ES",
        "Sri Lanka": "LK",
        "Sudan": "SD",
        "Suriname": "SR",
        "Sweden": "SE",
        "Switzerland": "CH",
        "Syria": "SY",
        "Tajikistan": "TJ",
        "Tanzania": "TZ",
        "Thailand": "TH",
        "Timor-Leste": "TL",
        "Togo": "TG",
        "Tonga": "TO",
        "Trinidad and Tobago": "TT",
        "Tunisia": "TN",
        "Turkey": "TR",
        "Turkmenistan": "TM",
        "Tuvalu": "TV",
        "Uganda": "UG",
        "Ukraine": "UA",
        "United Arab Emirates": "AE",
        "United Kingdom": "GB",
        "United States": "US",
        "Uruguay": "UY",
        "Uzbekistan": "UZ",
        "Vanuatu": "VU",
        "Venezuela": "VE",
        "Vietnam": "VN",
        "Yemen": "YE",
        "Zambia": "ZM",
        "Zimbabwe": "ZW"
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with event: Event) {
        lbl_event.text = event.event
        
        if let date = DateHelper.convertToDate(from: event.date) {
            self.lbl_date.text = DateHelper.timeAgo1(from: date)
        } else {
            print("Failed to convert date string to Date")
        }
        
//        lbl_date.text = DateHelper.timeAgo(from: event.date)
            
        // Convert country name to ISO code
          if let isoCode = countryToISOCode[event.country] {
              let flagEmoji = isoCode.flagEmoji() // Generate flag emoji
//              let flagEmoji = "PK".flagEmoji()
              countryIcon.image = emojiToImage(emoji: flagEmoji) // Render emoji as image
          } else {
              countryIcon.image = UIImage(named: "") // Fallback image
          }
    
        countryIcon.layer.cornerRadius = countryIcon.frame.size.height / 2
        countryIcon.clipsToBounds = true
        countryIcon.contentMode = .scaleAspectFill
        countryIcon.layer.borderWidth = 1
        countryIcon.layer.borderColor = UIColor.darkGray.cgColor
//        countryIcon.backgroundColor = .red

        
        switch event.importance {
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
        
        
      }
    
    func emojiToImage(emoji: String, size: CGSize = CGSize(width: 40, height: 40)) -> UIImage? {
        let label = UILabel()
        label.text = emoji
        label.font = UIFont.systemFont(ofSize: 40) // Adjust font size for resolution
        label.textAlignment = .center
        label.backgroundColor = .clear
       
        label.frame = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        label.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
       
        return image
    }
    
}

