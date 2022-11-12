//
//  MapaViewController.swift
//  MapasYgps
//
//  Created by Ángel González on 12/11/22.
//

import UIKit
import MapKit

class MapaViewController: UIViewController {
    var elCentro = CLLocationCoordinate2D(latitude: 19.331912, longitude: -99.192177)
    
    var elMapa = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        elMapa.mapType = .hybrid
        elMapa.frame = self.view.bounds
        self.view.addSubview(elMapa)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        elMapa.setRegion(MKCoordinateRegion(center: elCentro, latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
