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
    func getPSI(date:String?) {
        
        
        //target URL
        guard let apiURL = URL(string: kBASE_URL) else {
            log.error("getPSI API Call failed : wrong base url")
            postNotification(name: apiCallFailed)
            return
        }
        
        //the possible date to provide
        var parameters = [String:Any]()
        if let date = date {
            parameters = ["date":date]
        }
        
        Alamofire.request(apiURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: self.buildHeader()).responseSwiftyJSON { (dataResponse) in
            
            
            switch dataResponse.result {
            case .failure(let error):
                log.error("getPSI API Call failed : \(error.localizedDescription)")
                
                
                postNotification(name: apiCallFailed)
                return
            case .success(let json):
                
                print("JSON: \(json)")
                
                let items = json["items"]
                //print(items)
                var psiReadings = [psiReading]()
                
                
                for item in items {
                    
                    //item is tuple string, Any
                    let timestamp = item.1["timestamp"].string
                    let updateTimestamp = item.1["update_timestamp"].string
                    let itemPsi = item.1["readings"]["psi_twenty_four_hourly"]
                    
                    let eastPsi = itemPsi.dictionary?["east"]?.int ?? 0
                    let westPsi = itemPsi.dictionary?["west"]?.int ?? 0
                    let northPsi = itemPsi.dictionary?["north"]?.int ?? 0
                    let southPsi = itemPsi.dictionary?["south"]?.int ?? 0
                    let centralPsi = itemPsi.dictionary?["central"]?.int ?? 0
                    let nationalPsi = itemPsi.dictionary?["national"]?.int ?? 0
                    
                    var newReading = psiReading()
                    newReading.psiValueEast = eastPsi
                    newReading.psiValueWest = westPsi
                    newReading.psiValueSouth = southPsi
                    newReading.psiValueNorth = northPsi
                    newReading.psiValueNational = nationalPsi
                    newReading.psiValueCentral = centralPsi
                    
                    //
                    
                    let dateFormatter = ISO8601DateFormatter()
                    let createdDate = dateFormatter.date(from: timestamp ?? "")
                    newReading.timestamp = createdDate
                    psiReadings.append(newReading)
                }
                
                print(psiReadings)
                
                
                var regions = [String:CLLocationCoordinate2D]()
                let metadata = json["region_metadata"]
                for region in metadata {
                    let name = region.1["name"]
                    let longitude = region.1["label_location"]["longitude"]
                    let latitude = region.1["label_location"]["latitude"]
                    if (!name.exists() || !longitude.exists() || !latitude.exists()) {
                        continue
                    }
                    let coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
                    //
                    //            switch name.stringValue {
                    //            case "north":
                    //                regions.north = coordinate
                    //                break
                    //            case "south":
                    //                regions.south = coordinate
                    //                break
                    //            case "east":
                    //            regions.east = coordinate
                    //                break
                    //            case "west":
                    //            regions.west = coordinate
                    //                break
                    //            case "central":
                    //            regions.central = coordinate
                    //                break
                    //            default :
                    //                break
                    //            }
                    
                    regions[name.stringValue] = coordinate
                    
                }
                
                print(regions)
                
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
