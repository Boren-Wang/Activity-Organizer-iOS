//  Name: Boren Wang
//  SBU ID: 111385010
//
//  MyActivitiesTableViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/1.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit
import CoreData


/// This is the class for the table cel for "Joined Activities"
class MyActivitiesTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var detailBtn: UIButton!
    @IBOutlet weak var quitBtn: UIButton!
}


/// This is the class for "Joined Activities" table
class MyActivitiesTableViewController: UITableViewController {

    var myActivities:[Activity] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentUser:String?
    
    @IBOutlet weak var label: UILabel!
    
    // MARK: - iOS Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    /// Show the current user and load the data when the user is back to the home view
    /// - Parameter animated: specify whether you want the animation effect
    override func viewWillAppear(_ animated: Bool) {
        let settings = UserDefaults.standard
        currentUser = settings.string(forKey: "currentUser")
        if let username = currentUser {
            label.text = "You are logined in as \(username)"
        }
        loadDataFromDatabase()
        tableView.reloadData()
    }
    
    // MARK: - Load data from Core Data
    
    /// Load all the activities from the Core Data
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
    
    // MARK: - Functions for handling touch event
    
    /// Delete the activit from the user's Joined Activities list
    /// - Parameter sender: the Quit button
    @IBAction func quitTapped(_ sender: UIButton) {
        // Delete the activity from the joined activities list
        let activity = myActivities[sender.tag]
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            let users = try context.fetch(request)
            for i in users {
                if let u = i as? User {
                    if u.username == currentUser {
                        // Delete the activity from the user's joint activities list
                        u.removeFromActivities(activity)
                        appDelegate.saveContext() // save
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        loadDataFromDatabase()
        tableView.reloadData()
    }
    
    /// Logout the user
    /// - Parameter sender: the Logout button
    @IBAction func logoutTapped(_ sender: UIButton) {
        // Navigate to the home view
        let welcome = self.storyboard?.instantiateViewController(identifier: "welcomeController")
        self.view.window?.rootViewController = welcome
        self.view.window?.makeKeyAndVisible()
    }
    
    // MARK: - Table view data source

    /// Specify the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    /// Specify the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myActivities.count
    }

    /// Configure the custom tabel cell and add tag to all buttons
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
        
        // add tag to buttons so that their row can be identified when the buttons are clicked
        cell.detailBtn.tag = indexPath.row
        cell.quitBtn.tag = indexPath.row

        return cell
    }

    /// Delete the activity from the user's joint activities list
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the activity from the joined activities list
            let activity = myActivities[indexPath.row]
            
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSManagedObject>(entityName: "User")
            do {
                let users = try context.fetch(request)
                for i in users {
                    if let u = i as? User {
                        if u.username == currentUser {
                            // Delete the activity from the user's joint activities list
                            u.removeFromActivities(activity)
                            appDelegate.saveContext() // save
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
