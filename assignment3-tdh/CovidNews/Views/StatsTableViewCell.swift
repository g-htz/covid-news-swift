//
//  StatsTableViewCell.swift
//  CovidNews
//
//  Created by Trung Duc on 14/05/2021.
//

import UIKit

class StatsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryFlagImg: UIImageView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
