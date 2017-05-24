//
//  GoalsViewController.swift
//  CardioDiary
//
//  Created by Kristen Splonskowski on 2/27/17.
//  Copyright © 2017 Kristen Splonskowski. All rights reserved.
//

import UIKit

class GoalsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		let gradient = CAGradientLayer()
		gradient.frame = view.bounds
		gradient.colors = [UIColor(red: 138.0/255.0, green: 198.0/255.0, blue: 208.0/255.0, alpha: 0.1).cgColor, UIColor(red: 138.0/255.0, green: 198.0/255.0, blue: 208.0/255.0, alpha: 0.3).cgColor]
		view.layer.insertSublayer(gradient, at: 0)
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let mpw = UserDefaults.standard.double(forKey: "milesperweekgoal")
		if mpw > 0.0 {
			milesPerWeekField.text = "\(mpw)"
		} else {
			milesPerWeekField.becomeFirstResponder()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		if let mpwStr = milesPerWeekField.text, let mpw = Double(mpwStr) {
			UserDefaults.standard.set(mpw, forKey: "milesperweekgoal")
		}
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
	
	@IBOutlet weak var milesPerWeekField: UITextField!

}
