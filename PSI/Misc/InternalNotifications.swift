//
//  InternalNotifications.swift
//  PSI
//
//  Created by Guynemer on 5/2/18.
//  Copyright © 2018 SP Test. All rights reserved.
//

import Foundation

let apiCallFailed = "nf_apiCallFailed";

func postNotification(name: String) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: nil)
}
