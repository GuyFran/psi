//
//  WebServices.swift
//  PSI
//
//  Created by Guynemer on 5/2/18.
//  Copyright © 2018 SP Test. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

fileprivate let kAPI_KEY:String = "iCc0KKrOCQ3jrD2BlPWeyAd0sJgx8iPw"
fileprivate let kBASE_URL:String = "https://api.data.gov.sg/v1/environment/psi"

class WebServices {
    
    //fetch PSI Json and gives back the array of readings and the regions metadata
    //date in format YYYY-MM-DD
    func getPSI(date:String?) {
        
        
        //target URL
        guard let apiURL = URL(string: kBASE_URL) else {
            log.error("getPSI API Call failed : wrong base url")
            postNotification(name: apiCallFailed)
            return
        }
    }
    
    
    //neet to provide API KEY
    func buildHeader() -> HTTPHeaders {
        var headers = HTTPHeaders()
        headers["api-key"] = kAPI_KEY
        
        return headers
    }
}
