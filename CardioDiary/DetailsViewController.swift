//
//  DetailsViewController.swift
//  CardioDiary
//
//  Created by Kristen Splonskowski on 2/27/17.
//  Copyright © 2017 Kristen Splonskowski. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		mapView.delegate = self
		
		let gradient = CAGradientLayer()
		gradient.frame = view.bounds
		gradient.colors = [UIColor(red: 138.0/255.0, green: 198.0/255.0, blue: 208.0/255.0, alpha: 0.1).cgColor, UIColor(red: 138.0/255.0, green: 198.0/255.0, blue: 208.0/255.0, alpha: 0.3).cgColor]
		view.layer.insertSublayer(gradient, at: 0)

    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let cardio = cardio {
			
			cardioTypeLabel.text = cardio.type
			cardioDate.text = cardio.dateDescription
			
			cardioDuration.text = cardio.durationDescription
			
			if let heartRates = cardio.heartRate as? Set<HeartRate> {
				
				for heartRate in heartRates {
					heartRatesLabel.text = "\(Int(heartRate.pulse)) beats per minute"
				}
			}
			else {
				heartRatesLabel.text = nil
			}
			
			if let miles = cardio.route?.miles {
				if miles > 0.0 {
					let minutesPerMile = cardio.duration / 60 / miles
					speedLabel.text = "\(minutesPerMile) minute miles"
				}
				else {
					speedLabel.text = nil
				}
				
			}
			
			if let polyline = routePolyline() {
				mapView.add(polyline, level: MKOverlayLevel.aboveRoads)
			}
			
			if let region = routeRegion() {
				mapView.setRegion(region, animated: false)
			}
			
			
		}
		
	}
	
	func routePolyline() -> MKPolyline? {
		
		guard let cardio = cardio else {
			return nil
		}
		var coords = [CLLocationCoordinate2D]()
		
		if let locations = cardio.route?.location as? Set<Location> {
			for location in locations {
				coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
			}
			
			return MKPolyline(coordinates: &coords, count: coords.count)
		}
		
		return nil

	}
	
	func routeRegion() -> MKCoordinateRegion? {
		
		guard let cardio = cardio else {
			return nil
		}
		
		if let locations = cardio.route?.location as? Set<Location> {
			
			guard locations.count > 0 else {
				return nil
			}
			
			var minLat = CLLocationDegrees(90.0)
			var maxLat = CLLocationDegrees(-90.0)
			var minLng = CLLocationDegrees(180.0)
			var maxLng = CLLocationDegrees(-180.0)
			
			for location in locations {
				if location.latitude < minLat {
					minLat = location.latitude
				}
				if location.latitude > maxLat {
					maxLat = location.latitude
				}
				if location.longitude < minLng {
					minLng = location.longitude
				}
				if location.longitude > maxLng {
					maxLng = location.longitude
				}
			}
			
			let center = CLLocationCoordinate2D(latitude: (maxLat+minLat)/2, longitude: (maxLng+minLng)/2)
			
			let span = MKCoordinateSpan(latitudeDelta: fabs(maxLat-minLat) + 0.02, longitudeDelta: fabs(maxLng-minLng) + 0.02)
			
			return MKCoordinateRegion(center: center, span: span)
		}
		
		return nil
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		guard let polyline = overlay as? MKPolyline else {
			fatalError("Overlay was not a polyline?")
		}

		let renderer = MKPolylineRenderer(polyline: polyline)
		renderer.strokeColor = UIColor.blue
		renderer.lineWidth = 4.0
		
		return renderer
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	@IBOutlet weak var cardioTypeLabel: UILabel!
	@IBOutlet weak var cardioType: UILabel!
	@IBOutlet weak var cardioDate: UILabel!
	@IBOutlet weak var cardioDuration: UILabel!
	@IBOutlet weak var heartRatesLabel: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var speedLabel: UILabel!
	
	public var cardio: Cardio?

}
