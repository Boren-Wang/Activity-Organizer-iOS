//
//  MyActivitiesTableViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/1.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit
import CoreData

class MyActivitiesTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var detailBtn: UIButton!
}

class MyActivitiesTableViewController: UITableViewController {

    var myActivities:[Activity] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentUser:String?
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let settings = UserDefaults.standard
        currentUser = settings.string(forKey: "currentUser")
        if let username = currentUser {
            label.text = "You are logined in as \(username)"
        }
        loadDataFromDatabase()
        tableView.reloadData()
    }
    
    func loadDataFromDatabase() {
        //Set up Core Data Context
        let context = appDelegate.persistentContainer.viewContext
        //Set up Request
        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            myActivities = []
            let users = try context.fetch(request)
            for i in users {
                if let u = i as? User {
                    if u.username == currentUser {
                        if let activities = u.activities {
                            print(activities.count)
                            for object in activities {
                                myActivities.append(object as! Activity)
                            }
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // Get the user settings and sort the myActivities
        let settings = UserDefaults.standard
        let sortField = settings.string(forKey: Constants.sortField)
        let sortAscending = settings.bool(forKey: Constants.sortDirectionAscending)
        if sortField == "title" {
            myActivities.sort(by: {
                var res = false
                if let first = $0.title, let second = $1.title {
                    if sortAscending == true {
                        res = first < second
                    } else {
                        res = first > second
                    }
                }
                return res
            })
        } else if sortField == "time" {
            myActivities.sort(by: {
                var res = false
                if let first = $0.time, let second = $1.time {
                    if sortAscending == true {
                        res = first < second
                    } else {
                        res = first > second
                    }
                }
                return res
            })
        } else {
            myActivities.sort(by: {
                var res = false
                if let first = $0.location, let second = $1.location {
                    if sortAscending == true {
                        res = first < second
                    } else {
                        res = first > second
                    }
                }
                return res
            })
        }
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        // Navigate to the home view
        let welcome = self.storyboard?.instantiateViewController(identifier: "welcomeController")
        self.view.window?.rootViewController = welcome
        self.view.window?.makeKeyAndVisible()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myActivities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myTableCell", for: indexPath) as! MyActivitiesTableViewCell

        // Configure the cell...
        let activity = myActivities[indexPath.row]
        
        if let titleStr = activity.title {
            cell.title?.text = "Title: "+titleStr
        } else {
            cell.title?.text = "Title: "
        }
        
        if let locationStr = activity.location {
            cell.location?.text = "Location: "+locationStr
        } else {
            cell.location?.text = "Location: "
        }
        
        if let authorStr = activity.author {
            cell.author?.text = "Author: "+authorStr
        } else {
            cell.author?.text = "Author: "
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        if let dateStr = dateFormatter.string(for: activity.time) {
            cell.time.text = "Time: "+dateStr
        } else {
            cell.time.text = "Time: "
        }
        
        cell.detailBtn.tag = indexPath.row

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let activity = myActivities[indexPath.row]
            
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSManagedObject>(entityName: "User")
            do {
                let users = try context.fetch(request)
                for i in users {
                    if let u = i as? User {
                        if u.username == currentUser {
                            u.removeFromActivities(activity)
                            appDelegate.saveContext()
                        }
                    }
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        loadDataFromDatabase()
        tableView.deleteRows(at: [indexPath], with: .fade)
//        tableView.reloadData()
    }

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editActivity2" {
            let activityController = segue.destination as? ActivityViewController
            let selectedRow = (sender as! UIButton).tag
            let selectedActivity = myActivities[selectedRow]
            activityController?.currentActivity = selectedActivity
            activityController?.currentUser = currentUser!
        }
    }

}
