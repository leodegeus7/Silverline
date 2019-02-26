//
//  CustomerCellTableViewCell.swift
//  SilverlineSwift
//
//  Created by Leonardo Geus on 21/02/19.
//  Copyright © 2019 Leonardo Geus. All rights reserved.
//

import UIKit

class CustomerCellTableViewCell: UITableViewCell {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
