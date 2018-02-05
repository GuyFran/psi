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
    
    var refreshBtn: UIButton?
    var warningBtn: UIButton?
    var calendarBtn: UIButton?
    
    
    
    var isRefreshing = false
    var isShowingDatePicker = false
    
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
            mapView.layer.masksToBounds = true
            mapView.layer.cornerRadius = 8
            mapView.layer.borderWidth = 0.5
            mapView.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet var translucentCache: UIView! {
        didSet {
            translucentCache.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.399100598)
            translucentCache.layer.masksToBounds = true
            translucentCache.layer.cornerRadius = 8
        }
    }
    
    
    @IBOutlet var dateView: UIView!
    
    @IBOutlet var datePicker: UIDatePicker! {
        didSet {
            datePicker.backgroundColor = UIColor.white
            datePicker.layer.cornerRadius = 8
            datePicker.layer.masksToBounds = true
            datePicker.layer.borderColor = UIColor.black.cgColor
            datePicker.layer.borderWidth = 1.0
        }
    }
    
    @IBOutlet var bottomBar: UIImageView! {
        didSet {
            bottomBar.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        }
    }
    
    //

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = "application_title".localized()
        self.setupNavBar()
        
        
        self.perform(#selector(showWarning), with: nil, afterDelay: 5.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Setup
    
    func setupNavBar() {
        
        /*
        let refreshImageView = UIImageView(image: UIImage(named: "refresh.png"))
        let calendarImageView = UIImageView(image: UIImage(named: "calendar2 copy.png"))
        let warningImageView = UIImageView(image: UIImage(named: "warning.png"))
        */
        
        refreshBtn = UIButton()
        refreshBtn?.setImage(UIImage(named: "refresh.png"), for: .normal)
        refreshBtn?.addTarget(self, action: #selector(refreshClick), for: .touchUpInside)
        let barItem = UIBarButtonItem(customView: refreshBtn!)
        
        calendarBtn = UIButton()
        calendarBtn?.setImage(UIImage(named: "calendar2 copy.png"), for: .normal)
        calendarBtn?.addTarget(self, action: #selector(toggleDatePicker), for: .touchUpInside)
        let barItem2 = UIBarButtonItem(customView: calendarBtn!)
        
        warningBtn = UIButton()
        warningBtn?.setImage(UIImage(named: "warning.png"), for: .normal)
        warningBtn?.isUserInteractionEnabled = false
        let barItem3 = UIBarButtonItem(customView: warningBtn!)
        
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
        
        warningBtn?.isHidden = true
    }
    
    
    // MARK: - Actions
    
    @objc func refreshClick() {
        if isShowingDatePicker || self.isRefreshing {
            return
        }
        
        showProgress()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
    }
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
    }
    
    // MARK: - Animations
    
    
    func showProgress() {
        self.showCache()
        self.startRefreshAnimation()
    }
    
    func hideProgress() {
        self.hideCache()
        self.stopRefreshAnimation()
    }
    
    
    func showCache() {
        self.translucentCache.isHidden = false
    }
    
    func hideCache() {
        self.translucentCache.isHidden = true
    }

    
    func startRefreshAnimation() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2.0)
        rotateAnimation.duration = 1.0
        rotateAnimation.repeatCount = .infinity
        self.refreshBtn?.layer.add(rotateAnimation, forKey: nil)
    }
    
    func stopRefreshAnimation() {
        self.refreshBtn?.layer.removeAllAnimations()
    }
    
    @objc func showWarning() {
        self.warningBtn?.alpha = 0.0
        self.warningBtn?.isHidden = false
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: .calculationModeCubicPaced, animations: {
            //
            self.warningBtn!.alpha = 1.0
        }) { (completed) in
            //
            UIView.animateKeyframes(withDuration: 0.5, delay: 2.0, options: .calculationModeCubicPaced, animations: {
                self.warningBtn?.alpha = 0.0
            }, completion: { (completed) in
                //
                self.warningBtn?.alpha = 0.0
                self.warningBtn?.isHidden = true
            })
        }
    }
    
    @objc func toggleDatePicker() {
        if self.isRefreshing {
            return
        }
        
        if self.isShowingDatePicker {
            hideDatePicker()
        } else {
            showDatePicker()
        }
    }
    
    @objc func showDatePicker() {
        self.isShowingDatePicker = true
        
        self.datePicker.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.dateView.isHidden = false
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: .allowUserInteraction, animations: {
            //
            self.datePicker.transform = .identity
        }) { (completed) in
            //
        }
    }
    
    @objc func hideDatePicker() {
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.datePicker.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (completed) in
            self.dateView.isHidden = true
            self.isShowingDatePicker = false
        }
//
//
//        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: .curveEaseIn, animations: {
//            //
//            self.dateView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//        }) { (completed) in
//            //
//            self.dateView.isHidden = true
//            self.isShowingDatePicker = false
//        }
    }
    
    
    
}

