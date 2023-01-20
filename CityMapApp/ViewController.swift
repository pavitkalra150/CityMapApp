//
//  ViewController.swift
//  CityMapApp
//
//  Created by PAVIT KALRA on 2023-01-18.
//

import UIKit
import MapKit
class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var directionbtn: UIButton!
    
    var locationManager = CLLocationManager()
    
    var destination1: CLLocationCoordinate2D!
    var distance: Double = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        map.delegate = self
        
        doubleTap()
        
        map.isZoomEnabled = false
        
        directionbtn.isHidden = true
        
        
    }


    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let userLocations = locations[0]
        
        let latitude = userLocations.coordinate.latitude
        let longitude = userLocations.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "myLocation", subtitle: "I am here")
        
        
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                print(error!)
            } else {
                if let placemark = placemarks?[0] {
                    
                    var address = ""
                    
                    if placemark.subLocality != nil {
                        address += placemark.subLocality! + "\n"
                    }
                    
                    //self.addressLbl.text = address
                    
                    
                }
            }
        }
    }
    
    
    
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subtitle: String){
        
        
        //DEFINE SPAN
        let latdelta: CLLocationDegrees = 0.4
        let lngdelta: CLLocationDegrees = 0.4
        
        let span = MKCoordinateSpan(latitudeDelta: latdelta, longitudeDelta: lngdelta)
        
        //define location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        //define region
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        
        
        //set region on map
        
        map.setRegion(region, animated: true)
        
        
        let annotation = MKPointAnnotation()
        
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        //map.addAnnotation(annotation)
        
    
    }
    
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        print(map.annotations.count)
        
        
        let touchPoint = sender.location(in: map)

        let coordinate1 = map.convert(touchPoint, toCoordinateFrom: map)
        
        let annotationCity = City(coordinate: coordinate1)
        
        map.addAnnotation(annotationCity)
        
        
        destination1 = coordinate1
        
      
        directionbtn.isHidden = false
        print(map.annotations.count)

    }
    
    func doubleTap(){
        let double = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        double.numberOfTapsRequired = 2
        map.addGestureRecognizer(double)
    }
    
    @IBAction func drawRoute(_ sender: UIButton) {
        
        print(map.annotations.count)
        
        var nextIndex = 0
        for index in 0 ... 2 {
            if index == 2 {
                nextIndex = 0
            } else {
                nextIndex = index + 1
            }
            
            
            let source = MKPlacemark(coordinate: map.annotations[index].coordinate)
            
            let destination = MKPlacemark(coordinate: map.annotations[nextIndex].coordinate)
            
            let directionRequest = MKDirections.Request()
            
            directionRequest.source = MKMapItem(placemark: source)
            directionRequest.destination = MKMapItem(placemark: destination)
            
            directionRequest.transportType = .automobile
            
            let directions = MKDirections(request: directionRequest)
            
            directions.calculate{ (response, error) in
                guard let directionResponse = response else {return}
                
                //CREATE ROUTE
                let route = directionResponse.routes[0]
                let distanceInMeters = route.distance
                let distanceInKilometers = distanceInMeters / 1000
                print("Distance between annotations: \(distanceInKilometers) kilometers")
                
                self.map.addOverlay(route.polyline, level: .aboveRoads)
        
            }
        }
        

    }
    
    
    @IBAction func zoomIn(_ sender: UIButton) {
        let currentRegion = map.region
            let newRegion = MKCoordinateRegion(center: currentRegion.center, span: MKCoordinateSpan(latitudeDelta: currentRegion.span.latitudeDelta/2, longitudeDelta: currentRegion.span.longitudeDelta/2))
           map.setRegion(newRegion, animated: true)
    }
    
    
    @IBAction func zoomOut(_ sender: UIButton) {
        let currentRegion = map.region
            let newRegion = MKCoordinateRegion(center: currentRegion.center, span: MKCoordinateSpan(latitudeDelta: currentRegion.span.latitudeDelta*2, longitudeDelta: currentRegion.span.longitudeDelta*2))
            map.setRegion(newRegion, animated: true)
    }
    
    
}


extension ViewController: MKMapViewDelegate {
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation{
            return nil
        }
        
        switch annotation.title {
        case "myLocation":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myMarker")
            annotationView.markerTintColor = UIColor.blue
            return annotationView
        case "destintion1":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "first")
            annotationView.markerTintColor = UIColor.orange
            annotationView.animatesWhenAdded = true
            return annotationView
        case "destintion2":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "second")
            annotationView.markerTintColor = UIColor.black
            annotationView.animatesWhenAdded = true
            return annotationView
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
                    renderer.strokeColor = UIColor.blue
                    renderer.lineWidth = 2.0
//                    let rect = renderer.path.boundingBox
//                    let center = MKMapPoint(x: rect.midX, y: rect.midY)
//            let coordinate = map.convert(center, toCoordinateFrom: map)
//                    //let coordinate = map.convert(center, toCoordinateFrom: map)
//                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
//                    label.text = "\(distance) km"
//                    label.textAlignment = .center
//                    label.backgroundColor = UIColor.white
//                    label.textColor = UIColor.black
//                    label.center = mapView.convert(coordinate, toPointTo: mapView)
//                    mapView.addSubview(label)
            return renderer
        }
        return MKOverlayRenderer()
    }
}
