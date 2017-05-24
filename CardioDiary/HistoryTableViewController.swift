//
//  HistoryTableViewController.swift
//  CardioDiary
//
//  Created by Kristen Splonskowski on 2/27/17.
//  Copyright © 2017 Kristen Splonskowski. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

	// MARK: NSFetchedResultsControllerDelegate
	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		
		// new data, reload UI
		tableView.reloadData()
	}

	
	override func viewDidLoad() {
        super.viewDidLoad()

		// get fetchController for cardios and perform fetch
		fetchController = CardioService.shared.cardios()
		fetchController.delegate = self
		try? fetchController.performFetch()
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let cardios = fetchController.fetchedObjects {
			return cardios.count
		} else {
			return 0
		}
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historycell", for: indexPath)

		cell.textLabel?.textColor = .darkText
		cell.detailTextLabel?.textColor = .darkGray
		
        cell.textLabel?.text = "Running"
		cell.detailTextLabel?.text = "\(indexPath.row+1)"
		
		if let cardios = fetchController.fetchedObjects {
			
			// make most recent cardio event first in the last
			let cardio = cardios.reversed()[indexPath.row]
			
			// get type and date
			cell.textLabel?.text = cardio.type
			cell.detailTextLabel?.text = cardio.dateDescription
		}

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		
		if let detailsController = segue.destination as? DetailsViewController,
			let selectedIndexPath = tableView.indexPathForSelectedRow {
			
			if let cardios = fetchController.fetchedObjects {
				let cardio = cardios.reversed()[selectedIndexPath.row]
				detailsController.cardio = cardio
			}
		}
    }

	// MARK: Properties (Private)
	private var fetchController: NSFetchedResultsController<Cardio>!

}
