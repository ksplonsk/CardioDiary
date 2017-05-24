//
//  CardioService.swift
//  CardioDiary
//


import CoreData


class CardioService {
	// MARK: Service
	func cardios() -> NSFetchedResultsController<Cardio> {
		
		//  get FetchRequest for entity type category and sort by title
		let fetchRequest: NSFetchRequest<Cardio> = NSFetchRequest(entityName: "Cardio")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
		
		let fetchController: NSFetchedResultsController<Cardio> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		
		try! fetchController.performFetch()
		
		return fetchController
	
	}
	
	func add(_ cardio: Cardio) {
		self.persistentContainer.viewContext.perform {
			self.persistentContainer.viewContext.insert(cardio)
			do {
				try self.persistentContainer.viewContext.save()
			}
			catch {
				print(error)
			}
		}
	}

	// MARK: Initialization
	private init() {
		persistentContainer = NSPersistentContainer(name: "CardioDiary")
		persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
			
		})
	}
	
	// MARK: Public
	public var viewContext: NSManagedObjectContext {
		return persistentContainer.viewContext
	}

	// MARK: Private
	private let persistentContainer: NSPersistentContainer

	// MARK: Properties (Static)
	static let shared = CardioService()
}
