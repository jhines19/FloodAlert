//
//  ViewController.swift
//  FloodAlert
//
//  Created by Jaraad Hines on 8/29/20.
//  Copyright © 2020 Jaraad Hines. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {

    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var floodButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationServices()
        self.mapView.delegate = self
        // Do any additional setup after loading the view.
        
        setupUI()
        
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
        self.mapView.setRegion(region, animated: true)
    }
    @IBAction func addFloodButtonPressed() {
       
        //add annotation functionality when putton clicked
        guard let location = self.locationManager.location else {
            return
        }
        let annotation = MKPointAnnotation()
        annotation.title = "Flooded"
        annotation.subtitle = "Reported on 09/01/2020 8:58 AM"
        annotation.coordinate = location.coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    private func setupUI() {
        
        self.floodButton.layer.cornerRadius = 18.0
        self.floodButton.layer.masksToBounds = true
    }
    
    private func configureLocationServices() {
        locationManager.delegate = self

        let status = CLLocationManager.authorizationStatus()

        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
           beginLocationsUpdate(locationManager: locationManager)
        }
    }

    private func beginLocationsUpdate(locationManager: CLLocationManager) {
    // turn on setting to show location if authorized
       mapView.showsUserLocation = true
       // accuracy of location data can choose precision
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
       locationManager.startUpdatingLocation()

    }

    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
//        sets center point with lat 10k meters and long same
        let zoomRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
    }

}


extension ViewController: CLLocationManagerDelegate {

    // method triggered when new location change
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did get latest location")

        guard let latestLocation = locations.first else {return}

        if currentCoordinate == nil {
            zoomToLatestLocation(with: latestLocation.coordinate)
        }

        currentCoordinate = latestLocation.coordinate
    }

    // grant or deny permissions for location services update
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("the status changed")
        if status == .authorizedAlways || status == .authorizedWhenInUse {
           beginLocationsUpdate(locationManager: manager)
        }
    }

}
