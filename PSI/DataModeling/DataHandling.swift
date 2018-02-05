//
//  DataHandling.swift
//  PSI
//
//  Created by Guynemer on 5/2/18.
//  Copyright © 2018 SP Test. All rights reserved.
//

import Foundation
import SwiftyJSON
import Cache
import CoreLocation

class DataHandling {
    
    func loadLastPSI(completion:@escaping  ([psiReading], [String:CLLocationCoordinate2D]) -> ()) {
        self.loadPSI(date: nil, completion: completion)
    }
    
    //YYYY-MM-DD
    func loadPSI(date:String?, completion: @escaping ([psiReading], [String:CLLocationCoordinate2D]) -> ()) {
        let webservices = WebServices()
        
        webservices.getPSI(date: date, completion: completion)
    }
    
    //response handling
    func mapResponse(receivedJSON:JSON, isLastPSIRequest: Bool, completion:([psiReading], [String:CLLocationCoordinate2D]) -> ()) {
        
        //check for api status
        let status = receivedJSON["api_info"]["status"]
        if status.exists() {
            if status.stringValue != "healthy" {
                postNotification(name: apiCallWarningStatus)
            }
        } else {
            log.warning("API Status uncertain")
        }
        
        let items = receivedJSON["items"]
        
        var psiReadings = [psiReading]()
        
        for item in items {
            
            //item is tuple string, Any
            let timestamp = item.1["timestamp"].string
            //let updateTimestamp = item.1["update_timestamp"].string
            let itemPsi = item.1["readings"]["psi_twenty_four_hourly"]
            
            let eastPsi = itemPsi.dictionary?["east"]?.int ?? -1
            let westPsi = itemPsi.dictionary?["west"]?.int ?? -1
            let northPsi = itemPsi.dictionary?["north"]?.int ?? -1
            let southPsi = itemPsi.dictionary?["south"]?.int ?? -1
            let centralPsi = itemPsi.dictionary?["central"]?.int ?? -1
            let nationalPsi = itemPsi.dictionary?["national"]?.int ?? -1
            
            var newReading = psiReading()
            newReading.psiValueEast = eastPsi
            newReading.psiValueWest = westPsi
            newReading.psiValueSouth = southPsi
            newReading.psiValueNorth = northPsi
            newReading.psiValueNational = nationalPsi
            newReading.psiValueCentral = centralPsi
            
            //date formatting
            let dateFormatter = ISO8601DateFormatter()
            let createdDate = dateFormatter.date(from: timestamp ?? "")
            newReading.timestamp = createdDate
            
            psiReadings.append(newReading)
        }
        
        //caching last data
        if (isLastPSIRequest) {
            try? storage?.setObject(psiReadings, forKey: "psi")
        }
        
        //handling map regions
        var regions = [String:CLLocationCoordinate2D]()
        let metadata = receivedJSON["region_metadata"]
        for region in metadata {
            let name = region.1["name"]
            let longitude = region.1["label_location"]["longitude"]
            let latitude = region.1["label_location"]["latitude"]
            if (!name.exists() || !longitude.exists() || !latitude.exists()) {
                continue
            }
            let coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
            
            regions[name.stringValue] = coordinate
            
        }
        completion(psiReadings, regions)
    }
    
    //back up method to load cached info in case api call fails
    func loadCachedPsi(completion:([psiReading], [String:CLLocationCoordinate2D]) -> ()) {
        
        if let readings = try? storage?.object(ofType: Array<psiReading>.self, forKey: "psi"),
            let regions =  try? storage?.object(ofType: Dictionary<String, CLLocationCoordinate2D>.self, forKey: "regions") {
            
            if let readings = readings, let regions = regions {
                log.info("Loading last psi and region values from cache")
                completion(readings, regions)
            }
        }
        
        log.info("Failed to load last psi and region values from cache")
        completion([psiReading](), [String:CLLocationCoordinate2D]())
    }
}
