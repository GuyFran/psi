//
//  WebServicesTest.swift
//  PSITests
//
//  Created by Guynemer on 5/2/18.
//  Copyright © 2018 SP Test. All rights reserved.
//

import Foundation
import XCTest
@testable import PSI
import Quick
import Nimble
import CoreLocation

class WebServicesTest:QuickSpec {
    
    let webservices = WebServices()
    
    
    override func spec() {
        describe("getPSI") {
            it("Fetch last reading") {
                
                var reading:psiReading?
                self.webservices.getPSI(date: nil, completion: { (readings, regions) in
                    reading = readings[0]
                })
                
                expect(reading).toEventuallyNot(beNil(), timeout:5)
                
            }
        }
        
        describe("getPSI") {
            it("Check if receive and map all recordings of a full day") {
                //let webservices = Webservices()
                var psiReadings:[psiReading]?
                self.webservices.getPSI(date: "2018-02-04", completion: { (readings, regions) in
                    psiReadings = readings
                })
                
                expect(psiReadings?.count).toEventually(equal(23), timeout:5)
                
            }
        }
        
        describe("getPSI") {
            it("Check if receive the proper number of regions and check each name key") {
                //let webservices = Webservices()
                var mapRegions: [String:CLLocationCoordinate2D]?
                var regionNames = [String]()
                self.webservices.getPSI(date: nil, completion: { (readings, regions) in
                    mapRegions = regions
                    
                    for region in regions {
                        regionNames.append(region.key)
                    }
                    //print("region \(region))
                })
                
                expect(mapRegions).toEventuallyNot(beNil(), timeout:5)
                expect(mapRegions?.count).toEventually(equal(6), timeout:5)
                expect(regionNames).toEventually(contain("north"))
                expect(regionNames).toEventually(contain("east"))
                expect(regionNames).toEventually(contain("west"))
                expect(regionNames).toEventually(contain("south"))
                expect(regionNames).toEventually(contain("central"))
                expect(regionNames).toEventually(contain("national"))
                
            }
        }
    }
    
}
