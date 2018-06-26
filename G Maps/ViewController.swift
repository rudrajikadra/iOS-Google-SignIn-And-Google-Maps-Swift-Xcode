//
//  ViewController.swift
//  G Maps
//
//  Created by Rudra Jikadra on 25/01/18.
//  Copyright © 2018 Rudra Jikadra. All rights reserved.
//
// AIzaSyA2MyIqZDb28GSTHGkCgyum0jXuk4GE5jo

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseDatabase


class ViewController: UIViewController, CLLocationManagerDelegate{
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var ref: DatabaseReference!
    
    var api_key = "AIzaSyA2MyIqZDb28GSTHGkCgyum0jXuk4GE5jo"
    var mapView: GMSMapView!
    var marker =  GMSMarker()
    var nextLocation = CLLocationCoordinate2D(latitude: 25.192231, longitude: 55.274967)
    var nxt = 0
    var zoomLevel: Float = 15.0
    
    var locationManager:CLLocationManager!
    let mymarker =  GMSMarker()
    var myLongitude = 0.0
    var myLatitude = 0.0
    
    
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //get the default data of user
        userId = self.defaults.string(forKey: "userId")
        idToken = self.defaults.string(forKey: "idToken")
        fullName = self.defaults.string(forKey: "fullName")
        givenName = self.defaults.string(forKey: "givenName")
        familyName = self.defaults.string(forKey: "familyName")
        email = self.defaults.string(forKey: "email")
        
        
        
        GMSServices.provideAPIKey(api_key)
        GMSPlacesClient.provideAPIKey(api_key)
        
        let camera = GMSCameraPosition.camera(withLatitude: 25.197231, longitude: 55.274367, zoom: zoomLevel)
        
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Creates a marker in the center of the map.
        marker.position = CLLocationCoordinate2D(latitude: 25.197231, longitude: 55.274367)
        marker.title = "Burj Khalifa"
        marker.snippet = "Dubai, UAE"
        marker.map = mapView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.nextLoc))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "My Location!", style: .plain, target: self, action: #selector(self.myloc))
        
        ref = Database.database().reference()
        
        
        ref.child("MyLocation").observe(.childChanged) { (snapshot) in
            
            if snapshot.key == "location"{
                print(snapshot)
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    print("Latitude is : ", dictionary["latitude"] ?? 0.0)
                    print("Longitude is : ", dictionary["longitude"] ?? 0.0)
                }
            }
        }

//same thing as above but this only observes once where as the thing above refreshes everytime it is updated
//
//        ref.child("MyLocation/location").observeSingleEvent(of: .value) { (snapshot) in
//            print(snapshot)
//
//            if let dictionary = snapshot.value as? [String: AnyObject]{
//                print(dictionary["longitude"] ?? 0.0)
//            }
//        }
        
        print("\n\nIn ViewController for Maps:\n with uid: \(userId!)\n with fullname: \(fullName!)\n with given Name : \(givenName!) \n with family Name: \(familyName!)\n with email: \(email!)")
        
        
    }
    
    @objc func myloc() {
        
        nextLocation = CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude)
        
        CATransaction.begin()
        CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        
        mapView.animate(to: GMSCameraPosition.camera(withLatitude: nextLocation.latitude, longitude: nextLocation.longitude, zoom: 18.0))
        
        CATransaction.commit()
        
        mymarker.position = nextLocation
        mymarker.snippet = "You are here"
        mymarker.opacity = 0.7
        mymarker.icon = GMSMarker.markerImage(with: .green)
        mymarker.map = mapView
    }
   
    @objc func nextLoc() {
        
        if(nxt == 0){
            nextLocation = CLLocationCoordinate2D(latitude: 25.192231, longitude: 55.274967)
            marker.title = "Something"
            marker.snippet = "I dont know what"
            nxt = 1
        } else {
            nextLocation = CLLocationCoordinate2D(latitude: 25.197231, longitude: 55.274367)
            marker.title = "Burj Khalifa"
            marker.snippet = "Dubai, UAE"
            nxt = 0
        }
        
        CATransaction.begin()
        CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        
        mapView.animate(to: GMSCameraPosition.camera(withLatitude: nextLocation.latitude, longitude: nextLocation.longitude, zoom: zoomLevel))
        
        CATransaction.commit()
        
        marker.position = nextLocation
        marker.map = mapView
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        determineMyCurrentLocation()
    }
    
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("Users Latitude: \(userLocation.coordinate.latitude)")
        print("Users Longitude: \(userLocation.coordinate.longitude)")
        
        myLatitude = userLocation.coordinate.latitude
        myLongitude = userLocation.coordinate.longitude
        
        //myloc()
        
        ref.child("MyLocation").child("location").child("latitude").setValue(myLatitude)
        ref.child("MyLocation").child("location").child("longitude").setValue(myLongitude)
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

