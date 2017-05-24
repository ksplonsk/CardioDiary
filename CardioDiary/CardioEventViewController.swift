//
//  CardioEventViewController.swift
//  CardioDiary
//
//  Created by Kristen Splonskowski on 2/27/17.
//  Copyright © 2017 Kristen Splonskowski. All rights reserved.
//

import UIKit
import CoreLocation

class CardioEventViewController: UIViewController, CLLocationManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		locationManager.requestAlwaysAuthorization()
		locationManager.distanceFilter = 3.0
		
		let gradient = CAGradientLayer()
		gradient.frame = view.bounds
		gradient.colors = [UIColor(red: 138.0/255.0, green: 198.0/255.0, blue: 208.0/255.0, alpha: 0.1).cgColor, UIColor(red: 138.0/255.0, green: 198.0/255.0, blue: 208.0/255.0, alpha: 0.3).cgColor]
		view.layer.insertSublayer(gradient, at: 0)
		
		startWorkoutButton.layer.cornerRadius = 13.0
		startWorkoutButton.layer.backgroundColor = UIColor(red: 138.0/255.0, green: 198.0/255.0, blue: 208.0/255.0, alpha: 1).cgColor
		
		checkHeartRateButton.layer.cornerRadius = 13.0
		checkHeartRateButton.layer.backgroundColor = UIColor.white.cgColor
		

	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		timerView.alpha = 0
		heartRateInstructions.alpha = 0
		displayHeartRate.alpha = 0
		
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
	
	dynamic func updateDuration() {
		
		if let startDate = startDate {
			let elapsed = Date().timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate
			
			let minutes = Int(elapsed / 60)
			let seconds = elapsed - Double(minutes*60)
			duration.text = "\(minutes)m \(Int(seconds))s"
			
		}
		
	}
	
	@IBAction func startCardio(_ sender: UIButton) {
		
		if durationTimer == nil {
			
			// start running
			locationManager.startUpdatingLocation()
			startButton.setTitle("End Workout", for: .normal)
			startDate = Date()
			runDistance = 0.0
			
			durationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateDuration), userInfo: nil, repeats: true)
		}
		else {
			if let startDate = startDate {
				locationManager.stopUpdatingLocation()
				runDuration = Date().timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate
				startButton.setTitle("Workout Ended", for: .normal)
				startButton.isEnabled = false
				durationTimer?.invalidate()
				durationTimer = nil
			}
			
		}
		
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		guard locations.count > 0 else {
			return
		}
		
		// get rid of inaccurate points
		for location in locations {
			guard location.horizontalAccuracy > 0.0 && location.horizontalAccuracy < 20.0 else {
				continue
			}
			
			// calculate distance from new location to previous location and sum it up
			if let lastCoordinate = routeLocations.last {
				let distance = location.distance(from: CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude))
				runDistance += distance
			}
			
			routeLocations.append(location.coordinate)
			
		}
		
		
		print(locations[0])
		
	}
	
	@IBAction func done(_ sender: UIBarButtonItem) {
		
		if let startDate = startDate, runDuration > 0.0 {
			
			let cardio = Cardio(context: CardioService.shared.viewContext)
			
			cardio.date = startDate as NSDate
			cardio.duration = runDuration
			cardio.type = "Running"
			
			for hr in heartRates {
				let heartRate = HeartRate(context: CardioService.shared.viewContext)
				heartRate.pulse = hr
				cardio.addToHeartRate(heartRate)
			}
			
			let route = Route(context: CardioService.shared.viewContext)
			route.miles = runDistance / 1609.344
			
			for routeLocation in routeLocations {
				let location = Location(context: CardioService.shared.viewContext)
				location.latitude = routeLocation.latitude
				location.longitude = routeLocation.longitude
				route.addToLocation(location)
				
			}
			
			cardio.route = route
			
			CardioService.shared.add(cardio)
			
		}
		
		dismiss(animated: true, completion: nil)
	}
	
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var duration: UILabel!
	
	@IBAction func startHeartRateCheck(_ sender: UIButton) {
		
		UIView.animate(withDuration: 0.3) { 
			self.timerView.alpha = 1
			self.heartRateInstructions.alpha = 1
		}
		
		// delay start to allow reading instructions
		perform(#selector(runHeartRateTimer), with: nil, afterDelay: 3.0)
	}
	
	dynamic func runHeartRateTimer() {
		
		let startDate = Date()
		
		
		Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
			let elapsed = Date().timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate
			
			var remaining = 10.0 - elapsed
			
			if remaining < 0 {
				remaining = 0
			}
			
			self.timerView.percentage = CGFloat(remaining/10.0)
			
			// check to see if we are done
			if remaining <= 0 {
				timer.invalidate()
				self.promptForHeartRate()
				
				UIView.animate(withDuration: 0.3) {
					self.timerView.alpha = 0
					self.heartRateInstructions.alpha = 0
				}
			}
			
		}
	}
	
	// prompt for heart rate
	func promptForHeartRate() {
		let alertController = UIAlertController(title: "Heart Rate", message: "Please enter the number of beats you counted.", preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
			if let beatsStr = alertController.textFields?[0].text {
				if let beats = Double(beatsStr) {
					self.heartRates.append(beats*6)
					UIView.animate(withDuration: 0.3) {
						self.displayHeartRate.text = "\(Int(beats*6)) beats per minute"
						self.displayHeartRate.alpha = 1
					}
				}
			}
		})
		
		okAction.isEnabled = false
		
		alertController.addAction(okAction)
		alertController.addTextField(configurationHandler: { (textField) in
			textField.placeholder = "Number of Beats"
			textField.keyboardType = .numberPad
			
			NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: { (notification) in
				if let text = textField.text {
					okAction.isEnabled = !text.isEmpty
				} else {
					okAction.isEnabled = false
				}
			})
		})
		
		present(alertController, animated: true, completion: nil)
	}
	
	@IBOutlet weak var timerView: TimerView!
	@IBOutlet weak var heartRateInstructions: UILabel!
	@IBOutlet weak var displayHeartRate: UILabel!
	@IBOutlet weak var startWorkoutButton: UIButton!
	@IBOutlet weak var checkHeartRateButton: UIButton!
	
	var durationTimer: Timer?
	var startDate: Date?
	var runDuration = 0.0
	var heartRates = [Double]()
	var locationManager: CLLocationManager!
	var routeLocations = [CLLocationCoordinate2D]()
	var runDistance = 0.0

}
