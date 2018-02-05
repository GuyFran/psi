//
//  ViewController.swift
//  PSI
//
//  Created by Guynemer on 5/2/18.
//  Copyright © 2018 SP Test. All rights reserved.
//

import UIKit
import MapKit
import Charts

let dataHandling = DataHandling()

enum viewFormat {
    case format_last
    case format_3hr
    case format_24hr
}

class ViewController: UIViewController, MKMapViewDelegate, ChartViewDelegate {
    
    //
    var viewStyle = viewFormat.format_last
    
    let refreshImageView = UIImageView(image: UIImage(named: "refresh.png"))
    let calendarImageView = UIImageView(image: UIImage(named: "calendar2 copy.png"))
    let warningImageView = UIImageView(image: UIImage(named: "warning.png"))
    
    var refreshBtn: UIButton?
    var warningBtn: UIButton?
    var calendarBtn: UIButton?
    
    
    
    var isRefreshing = false
    var isShowingDatePicker = false
    var alreadyDrawnPins = false
    
    var lastReading:psiReading?
    var readings:[psiReading]?
    var regions = [String:CLLocationCoordinate2D]()
    
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
            mapView.delegate = self
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
    
    @IBOutlet var updateTimeTxt: UILabel!
    
    @IBOutlet var barChartView: BarChartView! {
        didSet {
            barChartView.delegate = self
            
            barChartView.chartDescription?.enabled = false
            barChartView.maxVisibleCount = 60
            barChartView.pinchZoomEnabled = false
            barChartView.drawBarShadowEnabled = false
            
            let xAxis = barChartView.xAxis
            xAxis.labelPosition = .bottom
            xAxis.valueFormatter = XAxisFormatter()
            //xAxis.granularity = 1
            xAxis.centerAxisLabelsEnabled = true
            
            let leftAxisFormatter = NumberFormatter()
            leftAxisFormatter.maximumFractionDigits = 1
            
            //barChartView.leftAxis.axisMinimum = 0
            //barChartView.rightAxis.axisMinimum = 0
            
            barChartView.legend.enabled = false
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //initial load for current values
        self.refreshLastReading()
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
        
        if (viewStyle == .format_last) {
            self.refreshLastReading()
        } else {
            self.refreshReadingsForSelectedDate()
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            viewStyle = .format_last
            self.refreshLastReading()
        case 1:
            viewStyle = .format_3hr
            self.refreshReadingsForSelectedDate()
        case 2:
            viewStyle = .format_24hr
            self.refreshReadingsForSelectedDate()
        default:
            break
        }
        self.updateUIToViewStyle()
    }
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
    }
    
    // MARK: -UI Update
    
    func updateUIToViewStyle() {
        
        //check if call out is allowed or not, set accordingly
        var showCallOut = true
        
        if viewStyle != .format_last {
            showCallOut = false
        }
        for annotation in mapView.annotations {
            let view = self.mapView.view(for: annotation)
            view?.canShowCallout = showCallOut
        }
        //
        
        //force refrsh annotation
        let selected = self.mapView.selectedAnnotations
        for annotation in selected {
            self.mapView.deselectAnnotation(annotation, animated: false)
            self.mapView.selectAnnotation(annotation, animated: false)
            let castedAnnotation = annotation as? MyAnnotation
            print("Selected annotation \(castedAnnotation?.region)")
        }
        //
        
        
        //charts
        self.barChartView.isHidden = true
    }
    
    func updateInfos() {
        
        //put pins on map
        if (!alreadyDrawnPins) {
            var annotations = [MyAnnotation]()
            for region in self.regions {
                let annotation = MyAnnotation()
                annotation.coordinate = region.value
                
                annotation.title = self.psiStringForRegion(region: region.key)
                annotation.region = region.key
                annotations.append(annotation)
            }
            self.mapView.addAnnotations(annotations)
            alreadyDrawnPins = true
        }
        //
        
        //update txt
        if (viewStyle == .format_last) {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            if let readingTimestamp = lastReading?.timestamp {
                self.updateTimeTxt.text = "update_time".localized() + ": " + formatter.string(from: readingTimestamp)
            } else {
                self.updateTimeTxt.text = "n.a"
            }
        } else {
            guard let readings = self.readings else { return }
            
            self.barChartView.isHidden = false
            
            if (viewStyle == .format_3hr) {
                if (readings.count >= 3) {
                    let newReadings = readings[readings.count - 3..<readings.count]
                    self.readings = Array(newReadings)
                }
            }
            
            self.updateChartData()
            self.updateTimeTxt.text = ""
        }
        //
        
        
        
    }
    
    func updateChartData() {
        guard let readings = self.readings else { return }
        
        
        let calendar = Calendar.current
        let yVals = (0..<readings.count).map { (i) -> BarChartDataEntry in
            
            let reading = readings[i]
            guard let timestamp = reading.timestamp else { return BarChartDataEntry(x: Double(0), y: 0)}
            let hour = calendar.component(.hour, from: timestamp)
            print("hour : \(hour)")
            return BarChartDataEntry(x: Double(hour), y: Double(reading.psiValueNational))
        }
        
        
        var set1: BarChartDataSet! = nil
        if let set = barChartView.data?.dataSets.first as? BarChartDataSet {
            set1 = set
            set1?.values = yVals
            barChartView.data?.notifyDataChanged()
            barChartView.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(values: yVals, label: "Data Set")
            set1.colors = ChartColorTemplates.liberty()
            set1.drawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            barChartView.data = data
            barChartView.fitBars = true
        }
        
        barChartView.setNeedsDisplay()
        barChartView.animate(yAxisDuration: 1.5)
    }
    
    // MARK: - Fetching Data
    func refreshLastReading() {
        self.showProgress()
        
        dataHandling.loadLastPSI { (readings, regions) in
            self.hideProgress()
            if (readings.count == 1) {
                self.lastReading = readings[0]
            } else {
                log.error("More than 1 record for last PSI!")
            }
            
            self.regions = regions
            
            self.updateInfos()
        }
    }
    
    func refreshReadingsForSelectedDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateToUse = formatter.string(from: self.datePicker.date)
        self.refreshReadingsForDate(date: dateToUse)
    }
    
    func refreshReadingsForDate(date: String) {
        self.showProgress()
        
        dataHandling.loadPSI(date: date) { (readings, regions) in
            self.hideProgress()
            self.readings = readings
            
            self.regions = regions
            
            self.updateInfos()
        }
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
    }
    
    
    // MARK: - MKDelegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pinView = view as? MKPinAnnotationView
        pinView?.pinTintColor = UIColor.red
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let pinView = view as? MKPinAnnotationView
        pinView?.pinTintColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if(pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView?.pinTintColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        }
        return pinView
    }
    
    // MARK: - Utils
    func psiStringForRegion(region: String) -> String {
        switch region {
        case "north":
            return "north".localized() + " :\(lastReading?.psiValueNorth ?? 0)"
        case "south":
            return "south".localized() + " :\(lastReading?.psiValueSouth ?? 0)"
        case "west":
            return "west".localized() + " :\(lastReading?.psiValueWest ?? 0)"
        case "east":
            return "east".localized() + " :\(lastReading?.psiValueEast ?? 0)"
        case "central":
            return "central".localized() + " :\(lastReading?.psiValueCentral ?? 0)"
        default:
            return "n.a."
        }
    }
    
    
}

