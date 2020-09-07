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
import Firebase
import FirebaseFirestore


    class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

        @IBOutlet weak var mapView: MKMapView!
        @IBOutlet weak var floodButton: UIButton!

        private(set) var floods = [Flood]()
        
        private var currentCoordinate: CLLocationCoordinate2D?
        
        private var documentRef: DocumentReference!

        private lazy var db: Firestore = {
            
            let firestoreDB = Firestore.firestore()
            let settings = firestoreDB.settings
            settings.areTimestampsInSnapshotsEnabled = true
            firestoreDB.settings = settings
            return firestoreDB
        }()
        
        private lazy var locationManager: CLLocationManager = {
            
            let manager = CLLocationManager()
            manager.requestAlwaysAuthorization()
            return manager
        } ()
        
      override func viewDidLoad() {
            super.viewDidLoad()
        
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
            self.mapView.delegate = self
           
        // Do any additional setup after loading the view.
            
            setupUI()
            configureObservers()
        }
        
        private func updateAnnotations() {
            
            DispatchQueue.main.async {
                
                self.mapView.removeAnnotations((self.mapView.annotations))
                self.floods.forEach {
                    self.addFloodToMap($0)
                }
            }
            
        }
        private func configureObservers() {
            
            self.db.collection("flooded-regions").addSnapshotListener { [weak self] snapshot, error in
                
                guard let _ = snapshot, error == nil else { print("Error fetching document")
                    return
                }
                
                snapshot?.documentChanges.forEach { diff in
                    
                    if diff.type == .added {
                        if let flood = Flood(diff.document) {
                            self?.floods.append(flood)
                            self?.updateAnnotations()
                        }
                        
                    } else if diff.type == .removed {
                        if let flood = Flood(diff.document) {
                            if let floods = self?.floods {
                                self?.floods = floods.filter { $0.documentId != flood.documentId}
                                self?.updateAnnotations()
                            }
                        }
                    }
                }
            }
        }
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            
            let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
            self.mapView.setRegion(region, animated: true)
        }
        
        @IBAction func addFloodButtonPressed() {
            
            saveFloodToFirebase()
        }

        private func addFloodToMap(_ flood: Flood) {
            
            let annotation = FloodAnnotation(flood)
            annotation.coordinate = CLLocationCoordinate2D(latitude: flood.latitude, longitude: flood.longitude)
            annotation.title = "Flooded"
            annotation.subtitle = flood.reportedDate.formatAsString()
            self.mapView.addAnnotation(annotation)
            
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            
            if let floodAnnotation = view.annotation as? FloodAnnotation {
                
                let flood = floodAnnotation.flood
                
                self.db.collection("flooded-regions").document(flood.documentId!).delete()
                    { [weak self] error in
                    
                        if let error = error {
                            print("Error removing document \(error)")
                        } else {
                            print("Document removed")
                }
        }
    
    }

}
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation is MKUserLocation {
                return nil
            }
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "FloodAnnotationView")
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "FloodAnnotationView")
                annotationView?.canShowCallout = true
                annotationView?.image = UIImage(named: "flood-annotation")
                annotationView?.rightCalloutAccessoryView = UIButton.buttonForRightAccesoryView()
            }
            
            return annotationView
            
        }
        
        private func saveFloodToFirebase() {
        
            guard let location = self.locationManager.location else {
                return
        }
            var flood = Flood(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            self.documentRef = self.db.collection("flooded-regions").addDocument(data: flood.toDictionary()) { [weak self] error in
                
                if let error = error {
                    print(error)
                } else {
                    flood.documentId = self?.documentRef.documentID
                    self?.addFloodToMap(flood)
                }
                
            }
}
        private func setupUI() {
                   
                   self.floodButton.layer.cornerRadius = 18.0
                   self.floodButton.layer.masksToBounds = true
        }
        
            //get a location
            
    
       func configureLocationServices() {
            locationManager.delegate = self

            let status = CLLocationManager.authorizationStatus()

            if status == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            } else if status == .authorizedAlways || status == .authorizedWhenInUse {
               beginLocationsUpdate(locationManager: locationManager)
            }
        }
            
        func beginLocationsUpdate(locationManager: CLLocationManager) {
        // turn on setting to show location if authorized
           mapView.showsUserLocation = true
           // accuracy of location data can choose precision
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.startUpdatingLocation()

        }

        func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
    //        sets center point with lat 10k meters and long same
            let zoomRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(zoomRegion, animated: true)
        }

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
