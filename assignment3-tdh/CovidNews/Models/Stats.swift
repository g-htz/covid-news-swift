//
//  Stats.swift
//  CovidNews
//
//  Created by Trung Duc on 14/05/2021.
//

import Foundation

class Statistic {
    var confirmedCase: Int = 0
    var todayCases: Int = 0
    var recovered: Int = 0
    var todayRecovered: Int = 0
    var death: Int = 0
    var todayDeath: Int = 0
    var active: Int = 0
    
    init(confirmedCase: Int, todayCases: Int, recovered: Int, todayRecovered: Int, death: Int, todayDeath: Int, active: Int) {
        self.confirmedCase = confirmedCase
        self.todayCases = todayCases
        self.recovered = recovered
        self.todayRecovered = todayRecovered
        self.death = death
        self.todayDeath = todayDeath
        self.active = active
    }
}

class CountryStat: Statistic {
    var flag: String
    var countryName: String
    
    init(confirmedCase: Int, todayCases: Int, recovered: Int, todayRecovered: Int, death: Int, todayDeath: Int, countryName: String, flag: String, active: Int) {
        self.countryName = countryName
        self.flag = flag
        super.init(confirmedCase: confirmedCase, todayCases: todayCases, recovered: recovered, todayRecovered: todayRecovered, death: death, todayDeath: todayDeath, active: active)
    }
}

struct Statistics {
    var total: Int
    var list: [CountryStat]
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}


