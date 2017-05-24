//
//  Cardio.swift
//  CardioDiary
//
//  Created by Kristen Splonskowski on 3/7/17.
//  Copyright © 2017 Kristen Splonskowski. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


public class Cardio: NSManagedObject {
	
	// computed property for formatting dates
	public var dateDescription: String {
		if let date = self.date as? Date {
			let formatter = DateFormatter()
			formatter.setLocalizedDateFormatFromTemplate("EEE d MMM h mm")
			return formatter.string(from: date)
		}
		
		return ""
	}
	
	public var durationDescription: String {
		let minutes = Int(self.duration / 60)
		let seconds = self.duration - Double(minutes*60)
		return "\(minutes)m \(Int(seconds))s"
	}

}
