//
//  StringsExtension.swift
//  PSI
//
//  Created by Guynemer on 5/2/18.
//  Copyright © 2018 SP Test. All rights reserved.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
