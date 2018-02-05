//
//  DateExtension.swift
//  PSI
//
//  Created by Guynemer on 5/2/18.
//  Copyright © 2018 SP Test. All rights reserved.
//

import Foundation

extension ISO8601DateFormatter {
    func toSGTDate(dateStr: String) -> Date? {
        self.timeZone = TimeZone(abbreviation: "SGT")
        let yourDate = self.date(from: dateStr)
        return yourDate
    }
}
