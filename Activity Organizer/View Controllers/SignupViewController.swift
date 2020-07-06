//  Name: Boren Wang
//  SBU ID: 111385010
//
//  SignupViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/1.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit
import CoreData

/// This class is for the signup view
class SignupViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var error: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the error label
        error.alpha = 0
    }
    
    /// Create a new user and navigate to the home view
    /// - Parameter sender: the Signup button
    @IBAction func signupTapped(_ sender: Any) {
        // Validate the fields
        if username.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            // show error message
            error.text = "Please fill in all fields."
            error.alpha = 1
        } else {
            // Create cleaned versions of the data
            let usernameStr = username.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let passwordStr = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // First check if the username already exists
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSManagedObject>(entityName: "User")
            do {
                let users = try context.fetch(request)
                for i in users {
                    if let u = i as? User {
                        if u.username == usernameStr {
                            error.text = "Username alreay exists"
                            error.alpha = 1
                            return
                        }
                    }
                }
                // Create the user
                let user = User(context: context)
                user.username = usernameStr
                user.password = passwordStr
                appDelegate.saveContext()
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            // Set current user
            let settings = UserDefaults.standard
            settings.set(usernameStr, forKey: "currentUser")
            settings.synchronize()
            
            // Navigate to the home view
            let home = self.storyboard?.instantiateViewController(identifier: "tabBarController")
            self.view.window?.rootViewController = home
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    
}
