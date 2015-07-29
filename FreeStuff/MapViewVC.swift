//
//  MapViewVC.swift
//  FreeStuff
//
//  Created by Julius Danek on 7/29/15.
//  Copyright (c) 2015 Julius Danek. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewVCDelegate {
    func coordinateTransmission (coordinate: CLLocationCoordinate2D, cityName: String)
}

class MapViewVC: UIViewController, UISearchBarDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var delegate: MapViewVCDelegate?
    
    //modeled after http://sweettutos.com/2015/04/24/swift-mapkit-tutorial-series-how-to-search-a-place-address-or-poi-in-the-map/
    var searchController:UISearchController!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "search")
        let userLocationButton = MKUserTrackingBarButtonItem(mapView: mapView)
        navigationItem.rightBarButtonItems = [searchButton, userLocationButton]
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismiss")
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func search () {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        if mapView.annotations.count != 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                var alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
                alert.show()
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse.boundingRegion.center.latitude, longitude:     localSearchResponse.boundingRegion.center.longitude)
            self.pointAnnotation.coordinate = self.coordinate!
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.addAnnotation(self.pinAnnotationView.annotation)
            
            let viewRegion = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, 500, 500)
            let adjustedRegion = self.mapView.regionThatFits(viewRegion)
            self.mapView.setRegion(adjustedRegion, animated: true)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismiss")
        }
    }
    
    func mapView(mapView: MKMapView!, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        if mode == .Follow {
            if mapView.annotations.count != 0 {
                mapView.removeAnnotations(mapView.annotations)
            }
            pointAnnotation = MKPointAnnotation()
            coordinate = mapView.userLocation.coordinate
            pointAnnotation.coordinate = coordinate!
            pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            mapView.addAnnotation(pinAnnotationView.annotation)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismiss")
        }
    }
    
    func dismiss () {
        if coordinate != nil {
            getCityString(coordinate!, completitionHandler: { (success, error, place) -> Void in
                if success {
                    self.delegate?.coordinateTransmission(self.coordinate!, cityName: place!)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }
    
    func getCityString(coordinate: CLLocationCoordinate2D, completitionHandler: (success: Bool, error: String?, place: String?)-> Void) {
        let geoCoder = CLGeocoder()
        let geoLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geoCoder.reverseGeocodeLocation(geoLocation, completionHandler: { (placemarks, error) -> Void in
            if error == nil {
                let placemark = placemarks[0] as! CLPlacemark
                if let city = placemark.locality {
                    completitionHandler(success: true, error: nil, place: city)
                }
            }
        })
        
    }
}
