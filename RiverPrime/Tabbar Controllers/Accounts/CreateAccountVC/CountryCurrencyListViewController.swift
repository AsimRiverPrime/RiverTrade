//
//  CountryCurrencyListViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 09/08/2024.
//

import UIKit


struct CountryCurrency {
    let countryName: String
    let currencyCode: String
}
protocol CountryCurrencySelectionDelegate: AnyObject {
    func didSelectCountryCurrency(countryName: String, currencyCode: String)
}

class CountryCurrencyListViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    let tableView = UITableView()
    var countryCurrencyList = [CountryCurrency]()
    var filteredCountryCurrencyList = [CountryCurrency]()
    let searchController = UISearchController(searchResultsController: nil)
    
    weak var delegate: CountryCurrencySelectionDelegate?  // Delegate property
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch the country-currency data
        countryCurrencyList = getCountryCurrencyList()
        filteredCountryCurrencyList = countryCurrencyList
        
        // Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Countries"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the table view
        tableView.frame = self.view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CountryCurrencyCell")
        self.view.addSubview(tableView)
    }
    
    func getCountryCurrencyList() -> [CountryCurrency] {
        var countryCurrencyList = [CountryCurrency]()
        
        for localeId in Locale.availableIdentifiers {
            let locale = Locale(identifier: localeId)
            
            if let countryName = locale.localizedString(forRegionCode: locale.regionCode ?? ""),
               let currencyCode = locale.currencyCode {
                let countryCurrency = CountryCurrency(countryName: countryName, currencyCode: currencyCode)
                
                if !countryCurrencyList.contains(where: { $0.countryName == countryName }) {
                    countryCurrencyList.append(countryCurrency)
                }
            }
        }
        
        // Sort by country name
        countryCurrencyList.sort { $0.countryName < $1.countryName }
        
        return countryCurrencyList
    }
    // UITableView DataSource and Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountryCurrencyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCurrencyCell", for: indexPath)
        let countryCurrency = filteredCountryCurrencyList[indexPath.row]
        cell.textLabel?.text = "\(countryCurrency.countryName) - \(countryCurrency.currencyCode)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCountryCurrency = filteredCountryCurrencyList[indexPath.row]
        delegate?.didSelectCountryCurrency(countryName: selectedCountryCurrency.countryName, currencyCode: selectedCountryCurrency.currencyCode)
        dismiss(animated: true, completion: nil)  // Dismiss the list view after selection
    }
    
    // UISearchResultsUpdating method
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filterContentForSearchText(searchText)
    }
    
    // Helper method to filter the data based on the search text
    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredCountryCurrencyList = countryCurrencyList
        } else {
            filteredCountryCurrencyList = countryCurrencyList.filter { (countryCurrency: CountryCurrency) -> Bool in
                return countryCurrency.countryName.lowercased().contains(searchText.lowercased()) || countryCurrency.currencyCode.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}

