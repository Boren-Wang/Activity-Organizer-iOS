//
//  ActivityViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/4.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ActivityViewController: UIViewController, UITextFieldDelegate, DateControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var languageTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    
    let db = Firestore.firestore()
    var currentActivity: Dictionary<String, Any>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        
        if currentActivity != nil {
            titleTextField.text = currentActivity!["title"] as? String
            location.text = currentActivity!["location"] as? String
            descriptionTextField.text = currentActivity!["description"] as? String
            languageTextField.text = currentActivity!["language"] as? String
            categoryTextField.text = currentActivity!["category"] as? String
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            if currentActivity!["time"] != nil {
                timeLabel.text = formatter.string(from: (currentActivity!["time"] as! Timestamp).dateValue())
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func dateChanged(date: Date) {
        if currentActivity == nil {
            currentActivity = [String:Any]()
        }
        currentActivity!["time"] = Timestamp(date: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        timeLabel.text = formatter.string(from: date)
    }
    
    @objc func save() {
        print("save tapped!")
        if currentActivity == nil {
            currentActivity = [String:Any]()
        }
        currentActivity!["title"] = titleTextField.text
        currentActivity!["location"] = location.text
        currentActivity!["description"] = descriptionTextField.text
        currentActivity!["language"] = languageTextField.text
        currentActivity!["category"] = categoryTextField.text
        
        db.collection("activities").document(currentActivity!["title"] as! String).setData(currentActivity!) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueDate"){
            let dateController = segue.destination as! DateViewController
            dateController.delegate = self
        }
    }
}
