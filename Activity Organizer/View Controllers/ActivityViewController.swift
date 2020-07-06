//  Name: Boren Wang
//  SBU ID: 111385010
//
//  ActivityViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/4.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit

/// This class is for the Activity Details view
class ActivityViewController: UIViewController, UITextFieldDelegate, DateControllerDelegate {
    
    var currentUser: String?
    var currentActivity: Activity?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var languageTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var sgmtEditMode: UISegmentedControl!
    @IBOutlet weak var btnChange: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentActivity != nil {
            titleLabel.text = "Edit a Activity"
            titleTextField.text = currentActivity!.title
            location.text = currentActivity!.location
            descriptionTextField.text = currentActivity!.intro
            languageTextField.text = currentActivity!.language
            categoryTextField.text = currentActivity!.category

            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy HH:mm"
            if currentActivity!.time != nil {
                timeLabel.text = formatter.string(from: currentActivity!.time!)
            }
            
            // if the current user is not the author, disable the edit function
            if currentActivity?.author != currentUser {
                sgmtEditMode.setEnabled(false, forSegmentAt: 1)
            }
        }
        
        self.changeEditMode(self)
    }
    
    /// Used to enable or disable all the text fields and other controls
    /// - Parameter sender: the segmented control
    @IBAction func changeEditMode(_ sender: Any) {
        let textFields: [UITextField] = [titleTextField, location, descriptionTextField, languageTextField, categoryTextField]
        if sgmtEditMode.selectedSegmentIndex == 0 {
            for textField in textFields {
                textField.isEnabled = false
                textField.borderStyle = UITextField.BorderStyle.none
            }
            btnChange.isHidden = true
            navigationItem.rightBarButtonItem = nil
        }
        else if sgmtEditMode.selectedSegmentIndex == 1{
            for textField in textFields {
                textField.isEnabled = true
                textField.borderStyle = UITextField.BorderStyle.roundedRect
            }
            btnChange.isHidden = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                target: self,
                                                                action: #selector(self.save))
        }
    }
    
    /// Change the time of the activity
    /// - Parameter date: the date selected by the user
    func dateChanged(date: Date) {
        if currentActivity == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentActivity = Activity(context: context)
            currentActivity!.author = currentUser
        }
        currentActivity!.time = date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        timeLabel.text = formatter.string(from: date)
    }
    
    /// Store and update the info in the Core Data
    @objc func save() {
//        print("Save tapped!")
        if currentActivity == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentActivity = Activity(context: context)
            currentActivity!.author = currentUser
        }
        
        currentActivity!.title = titleTextField.text!
        currentActivity!.location = location.text!
        currentActivity!.intro = descriptionTextField.text
        currentActivity!.language = languageTextField.text
        currentActivity!.category = categoryTextField.text
        appDelegate.saveContext()
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(self)
//        navigationController?.popViewController(animated: true)
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
