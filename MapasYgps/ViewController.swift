//
//  ViewController.swift
//  MapasYgps
//
//  Created by Ángel González on 12/11/22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: - metodos del protocolo
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let aut = administradorUbicacion.authorizationStatus
        if aut == .authorizedAlways || aut == .authorizedWhenInUse {
            // si tengo permiso de usar el gps, entonces iniciamos la detección
            administradorUbicacion.startUpdatingLocation()
        }
        else if aut == .notDetermined {
            administradorUbicacion.requestAlwaysAuthorization()
        }
        else {
            // otra vez nos fue negado el permiso
            // Si necesitamos terminar una app. El código indica el tipo de error
            exit(666)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // las lecturas obtenidas llegan ordenadas de la mejor a la peor, asi que tomamos la primera
        guard let ubicacion = locations.first else { /* el arreglo llegó vacio */ return }
        let textView = UITextView()
        textView.frame = self.view.frame.insetBy(dx: 30, dy: 100)
        // Para obtener direcciones en lenguaje humano, necesitamos usar el servicio de GEOCoding y solicitar un "reverse"
        CLGeocoder().reverseGeocodeLocation(ubicacion) { lugares, error in
            if error != nil {
                print ("no se pudo encontrar ninguna dirección")
            }
            else {
                // se encontró al menos un lugar que corresponde con la ubicacion especificada
                guard let lugar = lugares?.first else { /* el arreglo llegó vacío */ return }
                let thoroughfare = (lugar.thoroughfare ?? "")
                let subThoroughfare = (lugar.subThoroughfare ?? "")
                let locality = (lugar.locality ?? "")
                let subLocality = (lugar.subLocality ?? "")
                let administrativeArea = (lugar.administrativeArea ?? "")
                let subAdministrativeArea = (lugar.subAdministrativeArea ?? "")
                let postalCode = (lugar.postalCode ?? "")
                let country = (lugar.country ?? "")
                let direccion = "Dirección: \(thoroughfare) \(subThoroughfare) \(locality) \(subLocality) \(administrativeArea) \(subAdministrativeArea) \(postalCode) \(country)"
                textView.text = "Usted está en: \(ubicacion.coordinate.latitude), \(ubicacion.coordinate.longitude)\n\(direccion)"
            }
        }
        self.view.addSubview(textView)
        // si solo necesitamos una lectura
        administradorUbicacion.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // si no se obtienen lecturas, apagamos el locationManager para no gastar bateria
        administradorUbicacion.stopUpdatingLocation()
    }
    
    var administradorUbicacion = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        administradorUbicacion.desiredAccuracy = kCLLocationAccuracyHundredMeters
        administradorUbicacion.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Verificamos si la geolocalización está activada en el dispositivo
        if CLLocationManager.locationServicesEnabled() {
            // Verificar permisos para mi aplicación
            if administradorUbicacion.authorizationStatus == .authorizedAlways ||
                administradorUbicacion.authorizationStatus == .authorizedWhenInUse {
                // si tengo permiso de usar el gps, entonces iniciamos la detección
                administradorUbicacion.startUpdatingLocation()
            }
            else {
                // no tenemos permisos, hay que volver a solicitarlos
                administradorUbicacion.requestAlwaysAuthorization()
            }
        }
        else {
            let ac = UIAlertController(title:"Error", message:"Lo sentimos, pero al parecer no hay geolocalización. Deseas habilitarla?", preferredStyle: .alert)
            let action = UIAlertAction(title: "SI", style: .default) {
                action1 in
                // abrimos los setting del dispositivo para que habilite la localizacion
                let settingsURL = URL(string: UIApplication.openSettingsURLString)!
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:])
                }
            }
            ac.addAction(action)
            let action2 = UIAlertAction(title: "NO", style: .default) {
                action2 in
                // Si necesitamos terminar una app. El código indica el tipo de error
                exit(666)
            }
            ac.addAction(action2)
            self.present(ac, animated: true)
        }
    }

}

