//
//  MapViewController.swift
//  Assignment1
//
//  Created by Xcode User on 2020-10-16.
//  Copyright © 2020 Xcode User. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController , UITextFieldDelegate , MKMapViewDelegate , UITableViewDataSource, UITableViewDelegate {
    
    let locationManager = CLLocationManager()
    let initialLocation = CLLocation(latitude: 43.655787, longitude: -79.739534)
    let newLocation = CLLocation(latitude: 43.6426 , longitude: 79.3871)
    
    @IBOutlet var myMapView : MKMapView!
    @IBOutlet var tbLocEntered : UITextField!
    @IBOutlet var tbLandmarkEntered : UITextField!
    @IBOutlet var viewPoint2 : UITextField!
    @IBOutlet var myTableView : UITableView!
    private var coordinates = [CLLocationCoordinate2D]()
    
    var routeSteps = ["Enter a desination to see the steps"]
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    let regionradius : CLLocationDistance = 1000
    func centerMapOnLocation(location : CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate , latitudinalMeters: regionradius * 2.0 , longitudinalMeters: regionradius * 2.0)
        myMapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        centerMapOnLocation(location: initialLocation)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = initialLocation.coordinate
        dropPin.title = "starting at sheridan college"
        self.myMapView.addAnnotation(dropPin)
        self.myMapView.selectAnnotation(dropPin, animated: true)
        
        //Adding circle with radius around the MK point (bounding box)
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(57.734274, -124.654364)
        
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = location
        annotation.title = "Selected Area"
        
        myMapView.addAnnotation(annotation)

        
        
        showCircle(coordinate: annotation.coordinate, radius: 1000, mapView: myMapView)
    }
    
    func showCircle(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, mapView: MKMapView) {
        let circle = MKCircle(center: coordinate, radius: radius)
        mapView.addOverlay(circle)
    }
    
    @IBAction func findNewLocation() {
        let locEnteredText = tbLocEntered.text!
        let landmarkEnteredText = tbLandmarkEntered.text!
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(locEnteredText, completionHandler: {(placemarks, error) -> Void in
            if(error != nil){
                print("Error", error)
            }
            
            if let placemark = placemarks?.first {
                let coordinates : CLLocationCoordinate2D = placemark.location!.coordinate
                
                
                let newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                
                self.centerMapOnLocation(location: newLocation)
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                dropPin.title = placemark.name
                self.myMapView.addAnnotation(dropPin)
                self.myMapView.selectAnnotation(dropPin, animated: true)
                
                
                
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.initialLocation.coordinate, addressDictionary: nil))
                
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: nil))
                
                request.requestsAlternateRoutes = false
                
                request.transportType = .automobile
                
                let directions = MKDirections(request: request)
                directions.calculate(completionHandler:
                    
                    
                    {[unowned self ] response, error in
                        
                        for route in (response?.routes)! {
                            
                            
                            self.myMapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
                            
                            
                            self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                            
                            
                            
                            self.routeSteps.removeAll()
                            for step in route.steps {
                                self.routeSteps.append(step.instructions)
                            }
                            self.myTableView.reloadData()
                        }
                        
                    }
                )
                
            }
            
            else if let placemarkNext = placemarks?.first {
                
                let newCoordinate: CLLocationCoordinate2D=placemarkNext.location!.coordinate
                
                let newLocationNext = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
                
                self.centerMapOnLocation(location: newLocationNext)
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = newCoordinate
                dropPin.title = placemarkNext.name
                self.myMapView.addAnnotation(dropPin)
                self.myMapView.selectAnnotation(dropPin, animated: true)
                
                let requestNext = MKDirections.Request()
                requestNext.source = MKMapItem(placemark: MKPlacemark(coordinate: self.newLocation.coordinate, addressDictionary: nil))
                
               // requestNext.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: nil))
                
                requestNext.requestsAlternateRoutes = false
                requestNext.transportType = .automobile
              
                    }
            
                
                
            }
            
       )
        
    
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeSteps.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        
        tableCell.textLabel?.text = routeSteps[indexPath.row]
        return tableCell
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        return renderer
        
        
        
    }
    
}
