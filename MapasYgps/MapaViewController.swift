//
//  MapaViewController.swift
//  MapasYgps
//
//  Created by Ángel González on 12/11/22.
//

import UIKit
import MapKit

class MapaViewController: UIViewController, MKMapViewDelegate {
    var elCentro = CLLocationCoordinate2D(latitude: 19.331912, longitude: -99.192177)
    var estadioAzul = CLLocationCoordinate2D(latitude: 19.3834381, longitude: -99.1804635)
    
    var elMapa = MKMapView()
    let colores = [UIColor.blue, UIColor.green, UIColor.orange, UIColor.yellow, UIColor.brown]
    var ruta = 0
    
    // Detectar aceleración. (sacudida)
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if elMapa.mapType == .standard {
            elMapa.mapType = .hybrid
        }
        else {
            elMapa.mapType = .standard
        }
    }
    
    // Detectar rotación (sobre eje X / Y)
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        print ("cambiando a \(UIDevice.current.orientation)")
    }
    
    override func viewWillLayoutSubviews() {
        // se invoca siempre que sea necesario redibujar la vista
        print ("la vista cambió a \(UIDevice.current.orientation), rediseñar?")
        // cambiar la interface dependiendo de la nueva orientación
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        elMapa.mapType = .standard
        elMapa.frame = self.view.bounds
        elMapa.delegate = self
        self.view.addSubview(elMapa)
        NotificationCenter.default.addObserver(self, selector:#selector(ubicacionActualizada(_ :)), name: NSNotification.Name("Coordenada_Recibida"), object:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        elMapa.setRegion(MKCoordinateRegion(center: elCentro, latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
    }
    
    func actualizarMapa () {
        ruta = 0
        let lineas = elMapa.overlays
        elMapa.removeOverlays(lineas)
        let elPin = MKPointAnnotation()
        elPin.coordinate = elCentro
        elPin.title = "Estadio Olímpico UNAM"
        elMapa.addAnnotation(elPin)
        let elPin2 = MKPointAnnotation()
        elPin2.coordinate = estadioAzul
        elPin2.title = "Estadio Azul"
        elMapa.addAnnotation(elPin2)
        comoLlegar(de: elCentro, a: estadioAzul)
    }

    @objc func ubicacionActualizada(_ notif:Notification) {
        if let userInfo = notif.userInfo {
            elCentro.latitude = (userInfo["lat"] as? Double) ?? 0.0
            elCentro.longitude = (userInfo["lon"] as? Double) ?? 0.0
            actualizarMapa()
        }
    }
    
    func comoLlegar(de: CLLocationCoordinate2D, a: CLLocationCoordinate2D) {
        let indicaciones = MKDirections.Request()
        indicaciones.source = MKMapItem(placemark: MKPlacemark(coordinate: de))
        indicaciones.destination = MKMapItem(placemark: MKPlacemark(coordinate: a))
        indicaciones.transportType = .automobile
        indicaciones.requestsAlternateRoutes = false
        let rutas = MKDirections(request: indicaciones)
        rutas.calculate { response, error in
            if error != nil {
                print ("No se pueden obtener rutas para llegar \(String(describing: error?.localizedDescription))")
            }
            guard let lasRutas = response?.routes else { print ("No se pueden obtener rutas. Error desconocido"); return }
            for unaRuta in lasRutas {
                self.elMapa.addOverlay(unaRuta.polyline)
                self.elMapa.setVisibleMapRect(unaRuta.polyline.boundingMapRect, animated: true)
                self.ruta += 1
            }
        }
    }
    
    // MARK: - MapView Delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        render.strokeColor = colores[ruta]
        render.lineWidth = 2
        return render
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // implementación reutilizable de anotaciones
        let anotacion = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "confy")
        anotacion.markerTintColor = UIColor.blue
        let detalle = UILabel(frame: CGRect(x:0,y:0,width:100,height:30))
        detalle.text = "Esto es una prueba"
        anotacion.detailCalloutAccessoryView = detalle
        anotacion.canShowCallout = true
        if annotation.title == "Estadio Azul" {
            // dentro de la anotacion
            anotacion.glyphImage = UIImage(systemName: "soccerball.circle")
            // UIImage(named: "franky")
        }
        else {
            anotacion.glyphImage = UIImage(systemName: "figure.soccer")
            //UIImage(named: "drac")
        }
        return anotacion
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
