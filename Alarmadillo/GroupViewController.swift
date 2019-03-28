//
//  GroupViewController.swift
//  Alarmadillo
//
//  Created by Tanner Quesenberry on 3/26/19.
//  Copyright © 2019 Tanner Quesenberry. All rights reserved.
//

import UIKit

class GroupViewController: UITableViewController, UITextFieldDelegate {
    
    var group: Group!
    let playSoundTag = 1001
    let enabledTag = 1002

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlarm))
        title = group.name
    }
    
    //Update to reflect any changes made in AlarmViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.tag == playSoundTag {
            group.playSound = sender.isOn
        }else {
            group.enabled = sender.isOn
        }
        
        save()
    }
    
    //MARK: - Tableview methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return group.alarms.count
        }
    }
    
    //Section headers
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //return if in first section
        if section == 0 { return nil }
        
        //have at least 1 alarm
        if group.alarms.count > 0 { return "Alarms" }
        
        //no alarms return nothing
        return nil
    }
    
    //User can only delete rows from section 2
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    //When user deletes a row, remove it from active group alarms and table
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        group.alarms.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        save()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            //Pass hard work to different method if in first section
            return createGroupCell(for: indexPath, in: tableView)
        }else {
            //If here means we're an alarm, pull out RightDetail cell for display
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetail", for: indexPath)
            
            //pull out correct alarm from alarms array
            let alarm = group.alarms[indexPath.row]
            
            //use alarm to configure cell, drawing on DateFormatters localized date parsing
            cell.textLabel?.text = alarm.name
            cell.detailTextLabel?.text = DateFormatter.localizedString(from: alarm.time, dateStyle: .none, timeStyle: .short)
            
            return cell
        }
    }
    
    
    func createGroupCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            //this is first cell, editing name of the group
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditableText", for: indexPath)
            //look for textfield inside cell
            if let cellTextField = cell.viewWithTag(1) as? UITextField {
                // then give it group name
                cellTextField.text = group.name
            }
            
            return cell
        
        case 1:
            // this is the play sound cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Switch", for: indexPath)
            
            //look for label and switch
            if let cellLabel = cell.viewWithTag(1) as? UILabel, let cellSwitch = cell.viewWithTag(2) as? UISwitch {
                //Configure cell with correct settings
                cellLabel.text = "Play Sound"
                cellSwitch.isOn = group.playSound
                
                //set switch up with playsoundTag tag so we know which one was changed later on
                cellSwitch.tag = playSoundTag
            }
            
            return cell
            
        default:
            // if we're anything else, we must be "enabled" switch
            let cell = tableView.dequeueReusableCell(withIdentifier: "Switch", for: indexPath)
            
            if let cellLabel = cell.viewWithTag(1) as? UILabel, let cellSwitch = cell.viewWithTag(2) as? UISwitch {
                //Configure cell with correct settings
                cellLabel.text = "Enabled"
                cellSwitch.isOn = group.enabled
                cellSwitch.tag = enabledTag
            }
            
            return cell
        }
    }
    
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.preservesSuperviewLayoutMargins = true
//        cell.contentView.preservesSuperviewLayoutMargins = true
//    }
    
    
    //MARK: - TextField Delegates
    
    //Update name when user finished typing
    func textFieldDidEndEditing(_ textField: UITextField) {
        group.name = textField.text!
        title = group.name
        
        save()
    }
    
    //Want keyboard to go away when user taps "Done"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - Segue triggers
    
    @objc func addAlarm() {
        let newAlarm = Alarm(name: "Name this alarm", caption: "Add an optional description", time: Date(), image: "")
        group.alarms.append(newAlarm)
        
        performSegue(withIdentifier: "EditAlarm", sender: newAlarm)
        
        save()
    }
    
    //Pass slected Alarm onto AlarmViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let alarmToEdit: Alarm
        
        if sender is Alarm {
            alarmToEdit = sender as! Alarm
        }else {
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            alarmToEdit = group.alarms[selectedIndexPath.row]
        }
        
        if let alarmViewController = segue.destination as? AlarmViewController {
            alarmViewController.alarm = alarmToEdit
        }
    }
    
    
    //MARK: - Saving
    
    //Means "post the command 'save' to the rest of the app", and any part that wants to be notified
    @objc func save() {
        NotificationCenter.default.post(name: NSNotification.Name("save"), object: nil)
    }
    
}
