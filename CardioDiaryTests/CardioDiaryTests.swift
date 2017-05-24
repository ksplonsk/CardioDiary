//
//  CardioDiaryTests.swift
//  CardioDiaryTests
//
//  Created by Kristen Splonskowski on 2/27/17.
//  Copyright © 2017 Kristen Splonskowski. All rights reserved.
//

import XCTest
@testable import CardioDiary

class CardioDiaryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    	
	
	// need clean database for this test to pass
//	func testCardioServicesInitial() {
//		
//		let fetchController = CardioService.shared.cardios()
//		
//		if let cardios = fetchController.fetchedObjects {
//			XCTAssertEqual(cardios.count, 0, "Database is not empty, it should initially be empty.")
//		}
//		else {
//			XCTFail("Cardios is nil")
//		}
//	}
	
	func testCardioServicesPostAdd() {
		
		let fetchController = CardioService.shared.cardios()
		
		if let cardios = fetchController.fetchedObjects {
			
			let cardioCount = cardios.count
			
			let cardio = Cardio(context: CardioService.shared.viewContext)
			
			cardio.date = NSDate()
			cardio.duration = 13.5*60
			cardio.type = "Running"
			
			let heartRate = HeartRate(context: CardioService.shared.viewContext)
			heartRate.pulse = 130
			cardio.addToHeartRate(heartRate)
			
			let route = Route(context: CardioService.shared.viewContext)
			route.miles = 2
			
			let location = Location(context: CardioService.shared.viewContext)
			location.latitude = 45
			location.longitude = -122
			route.addToLocation(location)
			
			cardio.route = route
			
			CardioService.shared.add(cardio)
			
			
			let fetchController2 = CardioService.shared.cardios()
			
			XCTAssertEqual(fetchController2.fetchedObjects!.count, cardioCount+1, "No cardio was added.")
			
			if let newCardio = fetchController2.fetchedObjects!.last {
				XCTAssertEqual(newCardio.duration, 13.5*60, "Duration was not properly persisted")
				XCTAssertEqual(newCardio.type, "Running", "Type was not properly persisted")
				XCTAssertEqual(newCardio.route!.miles, 2, "Miles were not properly persisted")
				
				let heartRates = newCardio.heartRate as! Set<HeartRate>
				if let heartRate = heartRates.first {
					XCTAssertEqual(heartRate.pulse, 130, "Pulse was not properly persisted")
				}
				else {
					XCTFail("Heart rate was not persisted")
				}
				
				let locations = newCardio.route!.location as! Set<Location>
				if let location = locations.first {
					XCTAssertEqual(location.latitude, 45, "Latitude was not properly persisted")
					XCTAssertEqual(location.longitude, -122, "Duration was not properly persisted")
				}
				else {
					XCTFail("Location was not persisted")
				}
				

			}
			else {
				XCTFail("Added cardio is not present")
			}
			
		}
		else {
			XCTFail("Cardios is nil")
		}
		
	}

	
}
