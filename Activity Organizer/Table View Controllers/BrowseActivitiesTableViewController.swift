//
//  BrowseActivitiesTableViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/1.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class BrowseActivitiesTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var detailBtn: UIButton!
}

class BrowseActivitiesTableViewController: UITableViewController {
    
    @IBOutlet weak var loadLabel: UILabel!
    
    let db = Firestore.firestore()
    var activities:[QueryDocumentSnapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDataFromDatabase()
    }
    
    @IBAction func joinTapped(_ sender: UIButton) {
        let activity = activities[sender.tag]
        db.collection("users").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    let document = querySnapshot!.documents[0]
                    var joined_activities = document.data()["joined activities"] as! [DocumentReference]
                    if !joined_activities.contains(activity.reference) {
                        joined_activities.append(activity.reference)
                        // joined!!!!!
                    } else {
                        print("Already joined!")
                    }
//                    print(type(of: activity.reference))
//                    print(joined_activities)
                    self.db.collection("users").document(document.documentID).setData([ "joined activities": joined_activities ], merge: true)
                }
        }
    }
    
    func loadDataFromDatabase() {
        let activitiesRef = db.collection("activities")
        self.loadLabel.text = "Loading data from firestore..."
        activitiesRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.loadLabel.text = "Error getting data from firestore"
            } else {
                self.activities = []
                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    print(type(of: document))
                    print(type(of: document.data()))
                    self.activities.append(document)
                    self.tableView.reloadData()
                }
                self.loadLabel.text = "Data loaded~"
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        print(activities.count)
        return activities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "browseTableCell", for: indexPath) as! BrowseActivitiesTableViewCell

        // Configure the cell...
        let activity = activities[indexPath.row]
        if let title = activity.data()["title"] as? String {
            cell.title.text = "Title: "+title
        }

        if let location = activity.data()["location"] as? String {
            cell.location.text = "Location: "+location
        }
        
//        if let maxPeopleInt = activity.data()["max people"] as? Int {
//            cell.attendee.text = "Attendee: "+String(maxPeopleInt)
//        }
        
        let time = (activity.data()["time"] as? Timestamp)?.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        if let timeStr = dateFormatter.string(for: time) {
            cell.time.text = "Time: "+timeStr
        }
        
        cell.joinBtn.tag = indexPath.row
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

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        if segue.identifier == "editActivity" {
            let activityController = segue.destination as? ActivityViewController
            let selectedRow = (sender as! UIButton).tag
            let selectedActivity = activities[selectedRow].data()
            activityController?.currentActivity = selectedActivity
        }
    }
}
