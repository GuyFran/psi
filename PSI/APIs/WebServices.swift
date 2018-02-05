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
import CoreLocation

fileprivate let kAPI_KEY:String = "iCc0KKrOCQ3jrD2BlPWeyAd0sJgx8iPw"
fileprivate let kBASE_URL:String = "https://api.data.gov.sg/v1/environment/psi"

class WebServices {
    
    //fetch PSI Json and gives back the array of readings and the regions metadata
    //date in format YYYY-MM-DD
    //YYYY-MM-DD
    func getPSI(date:String?, completion: @escaping  ([psiReading], [String:CLLocationCoordinate2D]) -> ()) {
        
        
        //target URL
        guard let apiURL = URL(string: kBASE_URL) else {
            log.error("getPSI API Call failed : wrong base url")
            postNotification(name: apiCallFailed)
            completion([psiReading](), [String:CLLocationCoordinate2D]())
            return
        }
        
        //the possible date to provide
        var parameters = [String:Any]()
        if let date = date {
            parameters = ["date":date]
        }
        
        Alamofire.request(apiURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: self.buildHeader()).responseSwiftyJSON { (dataResponse) in
            
            let hasDate = dataResponse.request?.url?.query?.hasPrefix("date=")
            let isLastPSI = !(hasDate ?? false)
            
            switch dataResponse.result {
                
            case .failure(let error):
                log.error("getPSI API Call failed : \(error.localizedDescription)")
                
                //error
                //if request was for last, try to fetch the saved last psi
                if (isLastPSI) {
                    dataHandling.loadCachedPsi(completion: completion)
                }
                
                postNotification(name: apiCallFailed)
                completion([psiReading](), [String:CLLocationCoordinate2D]())
                return
            case .success(let json):
                dataHandling.mapResponse(receivedJSON: json,
                                         isLastPSIRequest: isLastPSI, completion: completion)
            }
        }
    }
    
    
    //neet to provide API KEY
    func buildHeader() -> HTTPHeaders {
        var headers = HTTPHeaders()
        headers["api-key"] = kAPI_KEY
        
        return headers
    }
}
