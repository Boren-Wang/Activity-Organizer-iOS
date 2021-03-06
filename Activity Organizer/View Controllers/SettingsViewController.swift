//  Name: Boren Wang
//  SBU ID: 111385010
//
//  SettingsViewController.swift
//  Activity Organizer
//
//  Created by Boren Wang on 2020/7/1.
//  Copyright © 2020 Boren Wang. All rights reserved.
//

import UIKit

import UIKit

/// This is the class for settings view
class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pckSortField: UIPickerView!
    @IBOutlet weak var swAscending: UISwitch!
    
    let sortOrderItems: Array<String> = ["title", "time", "location"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pckSortField.dataSource = self
        pckSortField.delegate = self
    }
    
    
    /// Load the settings from UserDefaults and Set the picker & switch
    /// - Parameter animated: specify if you want the animation
    override func viewWillAppear(_ animated: Bool) {
        let settings = UserDefaults.standard
        swAscending.setOn(settings.bool(forKey: Constants.sortDirectionAscending), animated: false)
        let sortField = settings.string(forKey: Constants.sortField)
        var i = 0
        for field in sortOrderItems {
            if field == sortField {
                pckSortField.selectRow(i, inComponent: 0, animated: false)
            }
            i += 1
        }
        pckSortField.reloadAllComponents()
    }
    
    // MARK: - Event Handlers
    
    /// Change the sorting settings and Store the new settings
    /// - Parameter sender: the switch
    @IBAction func sortDirectionChanged(_ sender: Any) {
        let settings = UserDefaults.standard
        settings.set(swAscending.isOn, forKey: Constants.sortDirectionAscending)
        settings.synchronize()
    }
    
    // MARK: - UIPickerViewDelegate Methods
    
    
    /// Specify the number of columns for the picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // # of columns
    }
    
    /// Specify the number of rows for the picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortOrderItems.count // # of rows
    }
    
    /// Sets the value for each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortOrderItems[row] // sets the value for each row
    }
    
    /// Change the sorting settings and Store the new settings
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let sortField = sortOrderItems[row]
        let settings = UserDefaults.standard
        settings.set(sortField, forKey: Constants.sortField)
        settings.synchronize()
    }
}
