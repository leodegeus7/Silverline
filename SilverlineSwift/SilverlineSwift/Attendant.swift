//
//  Attendant.swift
//  SilverlineSwift
//
//  Created by Leonardo Geus on 21/02/19.
//  Copyright © 2019 Leonardo Geus. All rights reserved.
//

import UIKit

class Attendant {
    var name:String?
    var areas:[Area]?
    var id:String?
    
    init(name:String,areas:[Area],id:String) {
        self.name = name
        self.areas = areas
        self.id = id
    }
}
