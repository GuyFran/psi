//
//  ViewController.swift
//  PSI
//
//  Created by Guynemer on 5/2/18.
//  Copyright © 2018 SP Test. All rights reserved.
//

import UIKit

let dataHandling = DataHandling()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = "application_title".localized()
        dataHandling.loadLastPSI { (readings, regions) in
            //
            print(readings)
            print(regions)
        }
        
        dataHandling.loadPSI(date: "2018-02-04") { (readings, regions) in
            //
            print(readings)
            print(regions)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

