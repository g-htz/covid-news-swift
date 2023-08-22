//
//  StatsDetailViewController.swift
//  CovidNews
//
//  Created by Trung Duc on 15/05/2021.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts
import TinyConstraints

class StatsDetailViewController: UIViewController {
    
    @IBOutlet weak var confirmedCasesView: UIView!
    @IBOutlet weak var recoveredView: UIView!
    @IBOutlet weak var deathView: UIView!
    
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var totalConfirmedCasesLabel: UILabel!
    @IBOutlet weak var todayConfirmedCasesLabel: UILabel!
    @IBOutlet weak var totalRecoveredLabel: UILabel!
    @IBOutlet weak var todayRecoveredLabel: UILabel!
    @IBOutlet weak var totalDeathLabel: UILabel!
    @IBOutlet weak var todayDeathLabel: UILabel!
    
    @IBOutlet weak var pieChartView: UIView!
    @IBOutlet weak var lineChartView: UIView!
    
    @IBOutlet weak var rangeSegmented: UISegmentedControl!
    
    var countryName: String = ""
    var interval = 7
    
    var stats: Statistic!
    
    var pieChartData = [PieChartDataEntry]()
    
    var lineChartData = [ChartDataEntry]()
    
    var dates = [Double]()
    
    lazy var pieChart: PieChartView = {
        let chartView = PieChartView()
        
        chartView.backgroundColor = .systemGroupedBackground
        chartView.drawHoleEnabled = false
        chartView.drawEntryLabelsEnabled = false
        chartView.setExtraOffsets(left: 15, top: 15, right: 15, bottom: 15)
        
        return chartView
    }()
    
    lazy var lineChart: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemBackground
        chartView.rightAxis.enabled = false
        chartView.setExtraOffsets(left: 0, top: 5, right: 20, bottom: 5)

        // Show the limit lines behind each plot
        chartView.xAxis.drawLimitLinesBehindDataEnabled = true

        // Make sure that only 1 x-label per index is shown
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.granularity = 1
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.setLabelCount(7, force: false)
        
        chartView.leftAxis.axisMinimum = 0
        return chartView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        countryNameLabel.text = self.countryName
        confirmedCasesView.layer.cornerRadius = 10
        recoveredView.layer.cornerRadius = 10
        deathView.layer.cornerRadius = 10
        
        pieChartView.addSubview(pieChart)
        pieChart.centerInSuperview()
        pieChart.width(to: pieChartView)
        pieChart.heightToWidth(of: pieChartView)
        pieChart.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .easeInBack)
        
        lineChartView.addSubview(lineChart)
        lineChart.centerInSuperview()
        lineChart.width(to: lineChartView)
        lineChart.heightToWidth(of: lineChartView)
        lineChart.animate(xAxisDuration: 1.5)
    
        fetchData()
        fetchTimeSeriesData()
    }
    
    func fetchData() {
        
        let request = AF.request("https://corona.lmao.ninja/v2/countries/\(self.countryName.replacingOccurrences(of: " ", with: "%20"))?yesterday=true&strict=true&query")
        
        request.responseData { (responseData) in
            let json = JSON(responseData.data!)
            
            self.stats = Statistic(confirmedCase: json["cases"].intValue, todayCases: json["todayCases"].intValue, recovered: json["recovered"].intValue, todayRecovered: json["todayRecovered"].intValue, death: json["deaths"].intValue, todayDeath: json["todayDeaths"].intValue, active: json["active"].intValue)
            
            self.updateLabel()
            self.setPieChartData()
        }
    }
    
    func fetchTimeSeriesData() {
        let request = AF.request("https://corona.lmao.ninja/v2/historical/\(self.countryName.replacingOccurrences(of: " ", with: "%20"))?lastdays=\(self.interval)")
        
        request.responseData { (response) in
            
            if let responseData = response.data {
                
                let json = JSON(responseData)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM'/'dd'/'yy"
                
                var data = [(Double, Double)]()
                
                for item in json["timeline"]["cases"] {
                    let date = dateFormatter.date(from: item.0)
                    let unixTimestamp = date!.timeIntervalSince1970
                    let confirmedCase = item.1.doubleValue
                    data.append((unixTimestamp, confirmedCase))
                }
                
                data.sort {
                    $0.0 < $1.0
                }
                
                var index = 0
                
                for item in data {
                    self.dates.append(item.0)
                    let dataPoint = ChartDataEntry(x: Double(index), y: item.1)
                    self.lineChartData.append(dataPoint)
                    index += 1
                }
                
                self.setLineChartData()
            }

        }
    }
    
    func updateLabel() {
        totalConfirmedCasesLabel.text = String(stats.confirmedCase.withCommas())
        totalDeathLabel.text = String(stats.death.withCommas())
        totalRecoveredLabel.text = String(stats.recovered.withCommas())
        todayConfirmedCasesLabel.text = "(+\(stats.todayCases.withCommas()))"
        todayDeathLabel.text = "(+\(stats.todayDeath.withCommas()))"
        todayRecoveredLabel.text = "(+\(stats.todayRecovered.withCommas()))"
    }
    
    func setPieChartData() {
        
        let recoveredData = PieChartDataEntry(value: Double(self.stats.recovered), label: "Recovered")
        let activeData = PieChartDataEntry(value: Double(self.stats.active), label: "Active")
        let deathData = PieChartDataEntry(value: Double(self.stats.death), label: "Death")

        self.pieChartData.append(contentsOf: [recoveredData, activeData, deathData])

        let dataset = PieChartDataSet(entries: self.pieChartData, label: "")
        dataset.colors = ChartColorTemplates.material()
        dataset.drawValuesEnabled = true
        dataset.xValuePosition = .insideSlice
        dataset.yValuePosition = .outsideSlice
        dataset.sliceSpace = 3
        dataset.valueTextColor = .black
        dataset.valueLinePart1OffsetPercentage = 0.8 //The offset of the first starting position of the polyline relative to the block. The larger the value, the farther the polyline is from the block.
        dataset.valueLinePart1Length = 0.8 //The ratio of the first length in the polyline
        dataset.valueLinePart2Length = 0.4 //The maximum length of the second segment in the polyline
        dataset.valueLineWidth = 1 //The thickness of the polyline
        dataset.valueLineColor = UIColor.brown //line color
        
        let data = PieChartData(dataSet: dataset)
        data.setValueFont(UIFont.systemFont(ofSize: 10.0))
        data.setValueTextColor(UIColor.black)
        pieChart.data = data
        
    }
    
    func setLineChartData() {
        self.lineChart.xAxis.valueFormatter = DateAxisValueFormatter(dates: self.dates)
        let dataset = LineChartDataSet(entries: self.lineChartData, label: "Confirmed cases")
        dataset.drawCirclesEnabled = false
        dataset.lineWidth = 3
        let data = LineChartData(dataSet: dataset)
        data.setDrawValues(false)
        lineChart.data = data
    }
    
    
    
    @IBAction func didIntervalChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            self.interval = 7
        } else {
            self.interval = 30
        }
        
        self.lineChartData = [ChartDataEntry]()
        self.dates = [Double]()
        
        fetchTimeSeriesData()
    }
    
}

class DateAxisValueFormatter : NSObject, IAxisValueFormatter
{
    private var dates = [Double]()
    
    lazy private var dateFormatter: DateFormatter = {
           // set up date formatter using locale
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMM"
        return dateFormatter
    }()
    
    init(dates: [Double]) {
        self.dates = dates
        super.init()
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        
        let date = Date(timeIntervalSince1970: dates[index])
        
        return dateFormatter.string(from: date)
        
    }
}
