//
//  StatsViewController.swift
//  CovidNews
//
//  Created by Trung Duc on 14/05/2021.
//

import UIKit
import Alamofire
import SwiftyJSON

class StatsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var categorySegmented: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var countriesStats: Statistics?
    var filteredData: [CountryStat]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        getAllCountriesStats()
    }
    
    func getAllCountriesStats() {
        let request = AF.request("https://corona.lmao.ninja/v2/countries?yesterday&sort", method: .get)
        
        request.responseData { (responseData) in
            let json = JSON(responseData.data!)
            
            let total = Int(json.count)
            var list = [CountryStat]()
            
            for country in json {
                
                let confirmedCase = country.1["cases"].intValue
                let todayCases = country.1["todayCases"].intValue
                let recovered = country.1["recovered"].intValue
                let todayRecovered = country.1["todayRecovered"].intValue
                let death = country.1["deaths"].intValue
                let todayDeath = country.1["todayDeaths"].intValue
                let countryName = country.1["country"].stringValue
                let flag = country.1["countryInfo"]["flag"].stringValue
                let active = country.1["active"].intValue

     
                let tempCountry =   CountryStat(confirmedCase: confirmedCase, todayCases: todayCases, recovered: recovered, todayRecovered: todayRecovered, death: death, todayDeath: todayDeath, countryName: countryName, flag: flag, active: active)
                
                list.append(tempCountry)

            }
            
            list.sort { (temp1, temp2) -> Bool in
                return temp1.confirmedCase > temp2.confirmedCase
            }
            
            self.countriesStats = Statistics(total: total, list: list)
            self.filteredData = list
            self.tableView.reloadData()
        }
        
    }
    
    
    @IBAction func didCategoryChanged(_ sender: UISegmentedControl) {
        if var stats = self.countriesStats {
            if sender.selectedSegmentIndex == 0 {
                stats.list.sort { (temp1, temp2) -> Bool in
                    return temp1.confirmedCase > temp2.confirmedCase
                }
                self.filteredData = stats.list
                self.tableView.reloadData()
            } else if sender.selectedSegmentIndex == 1 {
                stats.list.sort { (temp1, temp2) -> Bool in
                    return temp1.recovered > temp2.recovered
                }
                self.filteredData = stats.list
                self.tableView.reloadData()
            } else {
                stats.list.sort { (temp1, temp2) -> Bool in
                    return temp1.death > temp2.death
                }
                self.filteredData = stats.list
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "statsDetail" {
            let destination = segue.destination as? StatsDetailViewController
            let index = self.tableView.indexPathForSelectedRow?.row
            destination?.countryName = filteredData[index!].countryName
        }
    }
    
}

extension StatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = self.countriesStats {
            performSegue(withIdentifier: "statsDetail", sender: nil)
        }
    }
}

extension StatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = self.countriesStats {
            return self.filteredData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StatsTableViewCell
        if let _ = self.countriesStats {
            cell.countryNameLabel.text = self.filteredData[indexPath.item].countryName
            cell.countryFlagImg.load(url: URL(string: self.filteredData[indexPath.item].flag)!)
            if self.categorySegmented.selectedSegmentIndex == 0 {
                cell.totalLabel.text = String(self.filteredData[indexPath.item].confirmedCase.withCommas())
                cell.todayLabel.text = "(+\(self.filteredData[indexPath.item].todayCases.withCommas()))"
                cell.totalLabel.textColor = UIColor.black
                cell.todayLabel.textColor = UIColor.black
            } else if self.categorySegmented.selectedSegmentIndex == 1 {
                cell.totalLabel.text = String(self.filteredData[indexPath.item].recovered.withCommas())
                cell.todayLabel.text = "(+\(self.filteredData[indexPath.item].todayRecovered.withCommas()))"
                cell.totalLabel.textColor = UIColor.systemGreen
                cell.todayLabel.textColor = UIColor.systemGreen
            } else {
                cell.totalLabel.text = String(self.filteredData[indexPath.item].death.withCommas())
                cell.todayLabel.text = "(+\(self.filteredData[indexPath.item].todayDeath.withCommas()))"
                cell.totalLabel.textColor = UIColor.systemRed
                cell.todayLabel.textColor = UIColor.systemRed
            }
        }
        return cell
    }
}

extension StatsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let stats = self.countriesStats {
            if searchText.isEmpty {
                self.filteredData = stats.list
            } else {
                let tempData = stats.list.filter {
                    return $0.countryName.range(of: searchText, options: .caseInsensitive) != nil
                }
                
                self.filteredData = tempData
            }
        }
        
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
