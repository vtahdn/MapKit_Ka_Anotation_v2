//
//  PathFind.swift
//  Ka_MapKit
//
//  Created by Viet Asc on 1/10/19.
//  Copyright © 2019 Viet Asc. All rights reserved.
//

import UIKit
import MapKit

class PathFind: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flag: UIImageView!
    
    var fromLocation: CLLocation?
    var locationManager: CLLocationManager?
    var overlay: MKOverlay?
    var direction: MKDirections?
    var foundPlace: CLPlacemark?
    var geoCoder: CLGeocoder?
    
    // Draw a tracking line on the map.
    lazy var show = { (_ response: MKDirections.Response) in
        
        for route in response.routes {
            self.overlay = route.polyline
            self.mapView.addOverlay(self.overlay!, level: .aboveRoads)
            for step in route.steps {
                print(step.instructions)
            }
        }
        
    }
    
    lazy var routePath = { (_ from: MKPlacemark, _ to: MKPlacemark) in
        
        let request = MKDirections.Request()
        let fromMapItem = MKMapItem(placemark: from)
        request.source = fromMapItem
        let toMapItem = MKMapItem(placemark: to)
        request.destination = toMapItem
        self.direction = MKDirections(request: request)
        self.direction?.calculate(completionHandler: { (response, error) in
            if error == nil {
                self.show(response!)
                self.flag.backgroundColor = .green
            } else {
                self.flag.backgroundColor = .black
            }
        })
        
    }
    
    lazy var address = { (_ string: String) in
        
        if string == "" {
            return
        }
        self.geoCoder?.geocodeAddressString(string, completionHandler: { (placemarks, error) in
            if error == nil {
                self.foundPlace = placemarks?.first
                let toPlace = MKPlacemark(placemark: self.foundPlace!)
                self.routePath(MKPlacemark(coordinate: self.fromLocation!.coordinate, addressDictionary: nil), toPlace)
            }
        })
        
    }
    
    lazy var region = { (_ scale: CGFloat) in
        
        let size: CGSize = self.mapView.bounds.size
        let region = MKCoordinateRegion(center: self.fromLocation!.coordinate, latitudinalMeters: Double(size.height * scale), longitudinalMeters: Double(size.width * scale))
        self.mapView.setRegion(region, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        mapView.delegate = self
        edgesForExtendedLayout = []
        self.geoCoder = CLGeocoder()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        mapView.showsUserLocation = true
        
    }

}

extension PathFind: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = .black
        render.lineWidth = 5.0
        return render
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        } else {
            annotationView?.annotation = annotation
        }
        let viewDetail = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let labelName = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        labelName.numberOfLines = 0
        labelName.textAlignment = .center
        let imgView = UIImageView(frame: CGRect(x: 0, y: 30, width: 200, height: 150))
        imgView.contentMode = .scaleAspectFit
        switch annotation.subtitle! {
        case "Ka":
            imgView.image = UIImage(named: "Ka_s")
            labelName.text = "Ka"
            annotationView?.image = UIImage(named: "Ka_r")
            break
        case "Hoang":
            imgView.image = UIImage(named: "Hoang_s")
            labelName.text = "Hoang"
            annotationView?.image = UIImage(named: "Hoang_r")
            break
        case "Be":
            imgView.image = UIImage(named: "Be_s")
            labelName.text = "Be"
            annotationView?.image = UIImage(named: "Be_r")
            break
        case "Bii":
            imgView.image = UIImage(named: "Bii_s")
            labelName.text = "Bii"
            annotationView?.image = UIImage(named: "Bii_r")
            break
        default:
            break
        }
        viewDetail.addSubview(labelName)
        viewDetail.addSubview(imgView)
        let widthConstraint = NSLayoutConstraint(item: viewDetail, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        let heightConstraint = NSLayoutConstraint(item: viewDetail, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        viewDetail.addConstraints([widthConstraint, heightConstraint])
        annotationView?.detailCalloutAccessoryView = viewDetail
        annotationView?.frame = CGRect(x: 100, y: 0, width: 50, height: 50)
        annotationView?.contentMode = .scaleToFill
        annotationView?.canShowCallout = true
        return annotationView
        
    }
    
}

extension PathFind: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.locationManager?.stopUpdatingLocation()
        self.fromLocation = locations.last
        region(2)
        
        // Add annotations
        let kaLocation = locations.last?.coordinate
        let hoangLocation = CLLocationCoordinate2D(latitude: kaLocation!.latitude + 0.003, longitude: kaLocation!.longitude + 0.003)
        let beLocation = CLLocationCoordinate2D(latitude: kaLocation!.latitude - 0.003, longitude: kaLocation!.longitude + 0.003)
        let biiLocation = CLLocationCoordinate2D(latitude: kaLocation!.latitude + 0.003, longitude: kaLocation!.longitude - 0.003)
        let kaAnnotation = LocationAnnotation(coordinate: kaLocation!, title: "Ka ♡", subtitle: "Ka")
        let hoangAnnotation = LocationAnnotation(coordinate: hoangLocation, title: "Ka ♡", subtitle: "Hoang")
        let beAnnotation = LocationAnnotation(coordinate: beLocation, title: "Ka ♡", subtitle: "Be")
        let biiAnnotation = LocationAnnotation(coordinate: biiLocation, title: "Ka ♡", subtitle: "Bii")
        mapView.addAnnotations([kaAnnotation, hoangAnnotation, beAnnotation, biiAnnotation])
        
    }
    
}

extension PathFind: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if overlay != nil {
            mapView.removeOverlay(overlay!)
        }
        address(textField.text!)
        return true
        
    }
    
}
