//
//  DateViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/4.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit

protocol DateControllerDelegate: class {
    func dateChanged(date: Date)
}

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
    
    @objc func saveTime(){
        self.delegate?.dateChanged(date: picker.date)
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
