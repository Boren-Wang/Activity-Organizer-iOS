//  Name: Boren Wang
//  SBU ID: 111385010

//  BrowseActivitiesTableViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/1.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit
import CoreData

/// This class is for the custom table cell for home view
class BrowseActivitiesTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var detailBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
}

/// This class configure is for the "Browser Activities" table
class BrowseActivitiesTableViewController: UITableViewController {
    
    var activities:[NSManagedObject] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentUser:String?
    
    @IBOutlet weak var label: UILabel!
    
    // MARK: - iOS Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // MARK: - Functions for handling touch event
    
    /// Add the activity to the user's 'Joined Activities' list when the user click 'Join'
    /// - Parameter sender: the Join buttion
    @IBAction func joinTapped(_ sender: UIButton) {
        print("Join tapped")
        let selectedRow = sender.tag
        let selectedActivity = activities[selectedRow] as! Activity
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            let users = try context.fetch(request)
            for i in users {
                if let u = i as? User {
                    if u.username == currentUser {
                        u.addToActivities(selectedActivity)
                        appDelegate.saveContext()
                        let alertController = UIAlertController(title: "Success",
                                                                message: "You joined an activity!\nClick 'My Activities' to see all joined activities",
                            preferredStyle: .alert)
                        
                        let actionCancel = UIAlertAction(title: "Okay",
                                                         style: .cancel,
                                                         handler: nil)
                        alertController.addAction(actionCancel)
                        present(alertController, animated: true, completion: nil)
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// Delete an activity from the home, if the user is the author of that activity
    /// - Parameter sender: the Delete button
    @IBAction func deleteTapped(_ sender: UIButton) {
        // Delete the row from the data source
        let activity = activities[sender.tag] as? Activity
        let context = appDelegate.persistentContainer.viewContext
        context.delete(activity!)
        do {
            try context.save()
        }
        catch  {
            fatalError("Error saving context: \(error)")
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
    
    // MARK: - Load data from Core Data
    
    /// Load all the activities from the Core Data
    func loadDataFromDatabase() {
        let settings = UserDefaults.standard
        let sortField = settings.string(forKey: Constants.sortField)
        let sortAscending = settings.bool(forKey: Constants.sortDirectionAscending)
        //Set up Core Data Context
        let context = appDelegate.persistentContainer.viewContext
        //Set up Request
        let request = NSFetchRequest<NSManagedObject>(entityName: "Activity")
        //Specify sorting
        let sortDescriptor = NSSortDescriptor(key: sortField, ascending: sortAscending)
        let sortDescriptorArray = [sortDescriptor]
        //to sort by multiple fields, add more sort descriptors to the array
        request.sortDescriptors = sortDescriptorArray
        do {
            activities = try context.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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
        return activities.count
    }
    
    /// Configure the custom tabel cell and add tag to all buttons
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "browseTableCell", for: indexPath) as! BrowseActivitiesTableViewCell

        // Configure the cell...
        let activity = activities[indexPath.row] as? Activity

        if let titleStr = activity?.title {
            cell.title?.text = "Title: "+titleStr
        } else {
            cell.title?.text = "Title: "
        }
        
        if let locationStr = activity?.location {
            cell.location?.text = "Location: "+locationStr
        } else {
            cell.location?.text = "Location: "
        }
        
        if let authorStr = activity?.author {
            cell.author?.text = "Author: "+authorStr
        } else {
            cell.author?.text = "Author: "
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        if let dateStr = dateFormatter.string(for: activity?.time) {
            cell.time.text = "Time: "+dateStr
        } else {
            cell.time.text = "Time: "
        }
        
        // add tag to buttons so that their row can be identified when the buttons are clicked
        cell.joinBtn.tag = indexPath.row
        cell.detailBtn.tag = indexPath.row
        cell.deleteBtn.tag = indexPath.row

        // only show delete button if the current user is the author
        if activity?.author != currentUser {
            cell.deleteBtn.isHidden = true
        } else {
            cell.deleteBtn.isHidden = false
        }

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editActivity" {
            let activityController = segue.destination as? ActivityViewController
            let selectedRow = (sender as! UIButton).tag
            let selectedActivity = activities[selectedRow] as? Activity
            activityController?.currentActivity = selectedActivity
            activityController?.currentUser = currentUser!
        } else if segue.identifier == "addActivity" {
            let activityController = segue.destination as? ActivityViewController
            activityController?.currentUser = currentUser!
        }
    }
}
