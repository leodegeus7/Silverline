//
//  Area.swift
//  SilverlineSwift
//
//  Created by Leonardo Geus on 21/02/19.
//  Copyright © 2019 Leonardo Geus. All rights reserved.
//

import UIKit

class Area {
    var name:String?
    var color:UIColor?
    var isActive:Bool?
    
    init(name:String,color:UIColor) {
        self.name = name
        self.color = color
        self.isActive = true
    }
}


