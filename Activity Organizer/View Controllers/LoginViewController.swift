//
//  LoginViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/1.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var error: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        error.alpha = 0
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func loginTapped(_ sender: Any) {
        // Create cleaned versions of the text field
        let emailStr = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordStr = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        Auth.auth().signIn(withEmail: emailStr, password: passwordStr) { (result, error) in
            
            if error != nil {
                // Couldn't sign in
                self.error.text = error!.localizedDescription
                self.error.alpha = 1
            }
            else {
                let home = self.storyboard?.instantiateViewController(identifier: "tabBarController")
                self.view.window?.rootViewController = home
                self.view.window?.makeKeyAndVisible()
            }
        }
    }
    
}
