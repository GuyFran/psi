//
//  psiReading.swift
//  PSI
//
//  Created by Guynemer on 5/2/18.
//  Copyright © 2018 SP Test. All rights reserved.
//

import Foundation

struct psiReading:Codable {
    var timestamp:Date?
    var psiValueNational:Int = 0
    var psiValueEast:Int = 0
    var psiValueWest:Int = 0
    var psiValueNorth:Int = 0
    var psiValueSouth:Int = 0
    var psiValueCentral:Int = 0
}
