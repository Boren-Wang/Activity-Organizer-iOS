//
//  SignupViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/1.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignupViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var error: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        error.alpha = 0
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        // Validate the fields
        if firstName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            // show error message
            error.text = "Please fill in all fields."
            error.alpha = 1
        } else {
            // Create cleaned versions of the data
            let firstNameStr = firstName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastNameStr = lastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let emailStr = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let passwordStr = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create the user
            Auth.auth().createUser(withEmail: emailStr, password: passwordStr) { (result, err) in
                // Check for errors
                if err != nil {
                    // There was an error creating the user
                    self.error.text = err!.localizedDescription
                    self.error.alpha = 1
                }
                else {
                    // User was created successfully, now store the first name and last name
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["firstname":firstNameStr, "lastname":lastNameStr, "uid": result!.user.uid ]) { (error) in
                        if error != nil {
                            // Show error message
                            self.error.text = error!.localizedDescription
                            self.error.alpha = 1
                        }
                    }
                    
                    // Transition to the home screen
                    let home = self.storyboard?.instantiateViewController(identifier: "tabBarController")
                    self.view.window?.rootViewController = home
                    self.view.window?.makeKeyAndVisible()
                }
            }
        }
    }
}
