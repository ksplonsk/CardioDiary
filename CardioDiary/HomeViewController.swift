//
//  HomeViewController.swift
//  CardioDiary
//
//  Created by Kristen Splonskowski on 2/27/17.
//  Copyright © 2017 Kristen Splonskowski. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, NSFetchedResultsControllerDelegate {

	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		
		updateLastWorkout()
		updateGoalStatus()
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let gradient = CAGradientLayer()
		gradient.frame = view.bounds
		gradient.colors = [UIColor(red: 138.0/255.0, green: 198.0/255.0, blue: 208.0/255.0, alpha: 0.1).cgColor, UIColor(red: 138.0/255.0, green: 198.0/255.0, blue: 208.0/255.0, alpha: 0.3).cgColor]
		view.layer.insertSublayer(gradient, at: 0)
		
		startCardioButton.layer.cornerRadius = 13.0
		startCardioButton.layer.backgroundColor = UIColor(red: 138.0/255.0, green: 198.0/255.0, blue: 208.0/255.0, alpha: 1).cgColor
		
		cardioHistoryButton.layer.cornerRadius = 13.0
		cardioHistoryButton.layer.backgroundColor = UIColor.white.cgColor
		
		goalsButton.layer.cornerRadius = 13.0
		goalsButton.layer.backgroundColor = UIColor.white.cgColor
		
		// get fetchController for cardios and perform fetch
		fetchController = CardioService.shared.cardios()
		fetchController.delegate = self
		try? fetchController.performFetch()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLastWorkout()
		updateGoalStatus()
		
		
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		var forceNameAlert = false
		if let uiTesting = ProcessInfo.processInfo.environment["uitesting"], uiTesting == "yes", uiTestingNameAlertShown == false {
			forceNameAlert = true
		}
		
		if let name = UserDefaults.standard.string(forKey: "username"), forceNameAlert == false {
			welcomeLabel.text = NSString(format: "Welcome, %@", name) as String
		}
		else {
			uiTestingNameAlertShown = true // we've already forced shown for UI testing
			
			let alertController = UIAlertController(title: "Welcome", message: "Please enter your name.", preferredStyle: .alert)
			
			let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
				if let name = alertController.textFields?[0].text {
					UserDefaults.standard.set(name, forKey: "username")
					UserDefaults.standard.synchronize()
					self.welcomeLabel.text = NSString(format: "Welcome, %@", name) as String
				}
			})
			
			okAction.isEnabled = false
			
			alertController.addAction(okAction)
			alertController.addTextField(configurationHandler: { (textField) in
				textField.placeholder = "Your Name"
				
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
	}
	
	private func updateLastWorkout() {
		
		if fetchController.fetchedObjects?.count == 0 {
			lastWorkout.text = "Tap the Start Workout button to do your first workout"
		}
		else {
			if let cardio = fetchController.fetchedObjects?.last {
				lastWorkout.text = "Your last workout was on \(cardio.dateDescription)"
			}
		}
	}
	
	private func updateGoalStatus() {
		
		let mpwGoal = UserDefaults.standard.double(forKey: "milesperweekgoal")
		if mpwGoal == 0 {
			goalStatusLabel.text = "Tap the Goals button to set a weekly goal"
		}
		else {
			// make date that was 1 week ago
			let lastWeek = Date(timeIntervalSinceNow: -7.0*24.0*60.0*60.0)
			
			var miles = 0.0
			if let cardios = fetchController.fetchedObjects {
				for cardio in cardios.reversed() {
					if (cardio.date as! Date) < lastWeek {
						break
					}
					if let route = cardio.route {
						miles = miles + route.miles
					}
				}
			}
			goalStatusLabel.text = "You are \(mpwGoal - miles) miles from your goal"
			
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBOutlet weak var startCardioButton: UIButton!
	@IBOutlet weak var welcomeLabel: UILabel!
	@IBOutlet weak var lastWorkout: UILabel!
	@IBOutlet weak var goalStatusLabel: UILabel!
	@IBOutlet weak var cardioHistoryButton: UIButton!
	@IBOutlet weak var goalsButton: UIButton!
	
	private var fetchController: NSFetchedResultsController<Cardio>!
	private var uiTestingNameAlertShown = false
	
}

