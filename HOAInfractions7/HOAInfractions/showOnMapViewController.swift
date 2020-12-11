//
//  PROGRAMMERS: Hayron Alvarez, Ariel Pentzke
//  PANTHERID'S: 5200111, 1364786
//  CLASS: COP 4655 RH1 & U01 TR 5:00
//  INSTRUCTOR: Steve Luis Online
//  ASSIGNMENT: Deliverable #2
//  DUE: Firday 12/11/20
//
//  This work is licensed under a Creative Commons Attribution 4.0 International License.
//  Details can be found under  https://creativecommons.org/licenses/by/4.0/

import UIKit
import MapKit

class showOnMapViewController: UIViewController,CLLocationManagerDelegate {
    var latitude: Double!
    var longitude: Double!
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
               let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
               let region = MKCoordinateRegion(center: coordinate,span:span)
               mapView.setRegion(region, animated: true)
               let pin = MKPointAnnotation()
               pin.coordinate = coordinate
               mapView.addAnnotation(pin)
    }
   

}
