//
//  HomeViewController.swift
//  CovidNews
//
//  Created by Trung Duc on 13/05/2021.
//

import UIKit
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController {

    @IBOutlet weak var LocationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var AffectedView: UIView!
    @IBOutlet weak var RecoveredView: UIView!
    @IBOutlet weak var DeathView: UIView!
    @IBOutlet weak var PreventionCollectionView: UICollectionView!
    @IBOutlet weak var SymptomCollectionView: UICollectionView!
    @IBOutlet weak var healthDeclarationButton: UIButton!
    
    
    @IBOutlet weak var totalCasesLabel: UILabel!
    @IBOutlet weak var todayCasesLabel: UILabel!
    @IBOutlet weak var totalRecoveredLabel: UILabel!
    @IBOutlet weak var todayRecoveredLabel: UILabel!
    @IBOutlet weak var totalDeathLabel: UILabel!
    @IBOutlet weak var todayDeathLabel: UILabel!
    
    var stats: Statistic?
    
    var preventionImagesArr = [
        "prevention1",
        "prevention2",
        "prevention3",
        "prevention4",
        "prevention5",
        "prevention6",
    ]
    
    var symptomImagesArr = [
        "symptom1",
        "symptom2",
        "symptom3",
        "symptom4",
        "symptom5",
        "symptom6",
        "symptom7",
        "symptom8",
        "symptom9",
        "symptom10",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AffectedView.layer.cornerRadius = 10
        RecoveredView.layer.cornerRadius = 10
        DeathView.layer.cornerRadius = 10
        healthDeclarationButton.layer.cornerRadius = 10
//        SymptomCollectionView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        
        getGlobalStats()
    }
    
    func getGlobalStats() {
        let request = AF.request("https://corona.lmao.ninja/v2/all?yesterday")
        
        request.responseData { (responseData) in
            let json = JSON(responseData.data!)
            
            self.updateStatsData(json: json)
        }
    }
    
    func getCountryStats() {
        let countryCode = Locale.current.regionCode!
        
        let request = AF.request("https://corona.lmao.ninja/v2/countries/\(countryCode)?yesterday=true&strict=true&query")
        
        request.responseData { (responseData) in
            let json = JSON(responseData.data!)
            
            self.updateStatsData(json: json)
        }
    }
    
    func updateStatsData(json: JSON) {
        self.stats = Statistic(confirmedCase: json["cases"].intValue, todayCases: json["todayCases"].intValue, recovered: json["recovered"].intValue, todayRecovered: json["todayRecovered"].intValue, death: json["deaths"].intValue, todayDeath: json["todayDeaths"].intValue, active: json["active"].intValue)
        
        self.updateLabel()
    }
    
    func updateLabel() {
        if let stats = self.stats {
            totalCasesLabel.text = String(stats.confirmedCase.withCommas())
            totalDeathLabel.text = String(stats.death.withCommas())
            totalRecoveredLabel.text = String(stats.recovered.withCommas())
            todayCasesLabel.text = "(+\(stats.todayCases.withCommas()))"
            todayDeathLabel.text = "(+\(stats.todayDeath.withCommas()))"
            todayRecoveredLabel.text = "(+\(stats.todayRecovered.withCommas()))"
        }
    }
    
    @IBAction func didChangeLocation(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            getGlobalStats()
        } else {
            getCountryStats()
        }
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == PreventionCollectionView {
            return preventionImagesArr.count
        } else {
            return symptomImagesArr.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == SymptomCollectionView {
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as? SymptomCollectionViewCell
            cell2?.symptomImage.image = UIImage(named: symptomImagesArr[indexPath.row])
            return cell2!
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PreventionImageCollectionViewCell
            cell?.preventImage.image = UIImage(named: preventionImagesArr[indexPath.row])
            return cell!
        }
    }
}

