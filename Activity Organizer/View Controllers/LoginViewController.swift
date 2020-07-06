//
//  LoginViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/1.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var error: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        error.alpha = 0
    }

    @IBAction func loginTapped(_ sender: Any) {
//        print("Login tapped")
        // Create cleaned versions of the text field
        let usernameStr = username.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordStr = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            let users = try context.fetch(request)
            for i in users {
                if let u = i as? User {
                    if u.username == usernameStr {
                        if u.password == passwordStr {
                            // Set current user
                            let settings = UserDefaults.standard
                            settings.set(usernameStr, forKey: "currentUser")
                            settings.synchronize()
                            
                            // Navigate to the home view
                            let home = self.storyboard?.instantiateViewController(identifier: "tabBarController")
                            self.view.window?.rootViewController = home
                            self.view.window?.makeKeyAndVisible()
                            return
                        } else {
                            error.alpha = 1
                            error.text = "Password does not match"
                            return
                        }
                    }
                }
            }
            // No such user
            error.alpha = 1
            error.text = "Username not found"
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

    }
    
}
