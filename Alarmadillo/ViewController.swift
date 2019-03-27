//
//  ViewController.swift
//  Alarmadillo
//
//  Created by Tanner Quesenberry on 3/26/19.
//  Copyright © 2019 Tanner Quesenberry. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 20)!]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        title = "Alarmadillo"
        
        //Call addGroups with + button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGroup))
        //Sets up back button that says Groups
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Groups", style: .plain, target: nil, action: nil)
        
        groups.append(Group(name: "Enabled Group", playSound: true, enabled: true, alarms: []))
        groups.append(Group(name: "Disabled Group", playSound: true, enabled: false, alarms: []))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    //MARL: - Tableview functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    //To enable deleting of table rows
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        groups.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Group", for: indexPath)
        
        //Assign group name to row
        let group = groups[indexPath.row]
        cell.textLabel?.text = group.name
        
        //If alarm enabled make text black
        if group.enabled {
            cell.textLabel?.textColor = UIColor.black
        }else {
            cell.textLabel?.textColor = UIColor.red
        }
        
        //Display number of alarms in detailTextProperty
        if group.alarms.count == 1 {
            cell.detailTextLabel?.text = "1 alarm"
        }else {
            cell.detailTextLabel?.text = "\(group.alarms.count) alarms"
        }
        
        return cell
    }

    //MARK: - Segue triggers
    
    //User creates a new group
    @objc func addGroup() {
        let newGroup = Group(name: "Name this group", playSound: true, enabled: false, alarms: [])
        groups.append(newGroup)
        
        performSegue(withIdentifier: "EditGroup", sender: newGroup)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let groupToEdit: Group
        
        if sender is Group {
            //we were called from addGroup(); use what it sent us
            groupToEdit = sender as! Group
        }else {
            //called by tableview cell, figure out which group
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            groupToEdit = groups[selectedIndexPath.row]
        }
        
        //unwrap destination from segue
        if let groupViewController = segue.destination as? GroupViewController {
            //give it the group we decided above
            groupViewController.group = groupToEdit
        }
    }
    
}

