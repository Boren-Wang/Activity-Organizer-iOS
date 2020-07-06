//  Name: Boren Wang
//  SBU ID: 111385010
//
//  DateViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/4.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit

/// The protocol is used to pass date infomation between views
protocol DateControllerDelegate: class {
    func dateChanged(date: Date)
}

/// This class is the the date view
class DateViewController: UIViewController {

    weak var delegate: DateControllerDelegate?
    @IBOutlet weak var picker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let saveButton: UIBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save,
                            target: self,
                            action: #selector(saveTime))
        self.navigationItem.rightBarButtonItem = saveButton
        self.title = "Pick Time"
    }
    
    /// Call the delegate's function to update the time
    @objc func saveTime(){
        self.delegate?.dateChanged(date: picker.date)
        self.navigationController?.popViewController(animated: true)
    }
}
