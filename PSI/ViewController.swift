//
//  ViewController.swift
//  PSI
//
//  Created by Guynemer on 5/2/18.
//  Copyright © 2018 SP Test. All rights reserved.
//

import UIKit
import MapKit

let dataHandling = DataHandling()

class ViewController: UIViewController {
    
    //
    let refreshImageView = UIImageView(image: UIImage(named: "refresh.png"))
    let calendarImageView = UIImageView(image: UIImage(named: "calendar2 copy.png"))
    let warningImageView = UIImageView(image: UIImage(named: "warning.png"))
    
    //MARK: Outlets
    
    @IBOutlet var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.tintColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
            segmentedControl.setTitle("last".localized(), forSegmentAt: 0)
            segmentedControl.setTitle("3hr".localized(), forSegmentAt: 1)
            segmentedControl.setTitle("24hr".localized(), forSegmentAt: 2)
        }
    }
    
    
    @IBOutlet var mapView: MKMapView! {
        didSet {
            mapView.layer.masksToBounds = true;
            mapView.layer.cornerRadius = 8; // if you like rounded corners
            mapView.layer.borderWidth = 0.5
            mapView.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet var bottomBar: UIImageView! {
        didSet {
            bottomBar.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        }
    }
    
    //

    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = "application_title".localized()
        self.setupNavBar()
//        dataHandling.loadLastPSI { (readings, regions) in
//            //
//            print(readings)
//            print(regions)
//        }
//
//        dataHandling.loadPSI(date: "2018-02-04") { (readings, regions) in
//            //
//            print(readings)
//            print(regions)
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Setup
    
    @objc func fake() {
        
    }
    func setupNavBar() {
        
        /*
        let refreshImageView = UIImageView(image: UIImage(named: "refresh.png"))
        let calendarImageView = UIImageView(image: UIImage(named: "calendar2 copy.png"))
        let warningImageView = UIImageView(image: UIImage(named: "warning.png"))
        */
        
        let button = UIButton()
        button.setImage(UIImage(named: "refresh.png"), for: .normal)
        button.addTarget(self, action: #selector(fake), for: .touchUpInside)
        let barItem = UIBarButtonItem(customView: button)
        
        let button2 = UIButton()
        button2.setImage(UIImage(named: "calendar2 copy.png"), for: .normal)
        button2.addTarget(self, action: #selector(fake), for: .touchUpInside)
        let barItem2 = UIBarButtonItem(customView: button2)
        
        let button3 = UIButton()
        button3.setImage(UIImage(named: "warning.png"), for: .normal)
        button3.isUserInteractionEnabled = false
        let barItem3 = UIBarButtonItem(customView: button3)
        
        let width = barItem.customView?.widthAnchor.constraint(equalToConstant: 22)
        width?.isActive = true
        let height = barItem.customView?.heightAnchor.constraint(equalToConstant: 22)
        height?.isActive = true
        
        let width2 = barItem2.customView?.widthAnchor.constraint(equalToConstant: 22)
        width2?.isActive = true
        let height2 = barItem2.customView?.heightAnchor.constraint(equalToConstant: 22)
        height2?.isActive = true
        
        let width3 = barItem3.customView?.widthAnchor.constraint(equalToConstant: 22)
        width3?.isActive = true
        let height3 = barItem3.customView?.heightAnchor.constraint(equalToConstant: 22)
        height3?.isActive = true
        
        self.navigationItem.leftBarButtonItems = [barItem, barItem2]
        self.navigationItem.rightBarButtonItem = barItem3
    }
    
    
    // MARK: Actions
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
    }
    

}

