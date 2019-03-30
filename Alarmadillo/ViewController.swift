//
//  ViewController.swift
//  Alarmadillo
//
//  Created by Tanner Quesenberry on 3/26/19.
//  Copyright © 2019 Tanner Quesenberry. All rights reserved.
//

import UIKit
import UserNotifications //Make sure to put in Appdelegate too

class ViewController: UITableViewController, UNUserNotificationCenterDelegate {

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
        
        //Save notification that gets posted from Alarm and Group View Controllers
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: Notification.Name("save"), object: nil)
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load()
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
        
        save()
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
        
        save()
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
    
    
    //MARK: - Saving/Loading
    
    @objc func save() {
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
            let data = try NSKeyedArchiver.archivedData(withRootObject: groups, requiringSecureCoding: false)
            try data.write(to: path)
        } catch {
            print("Failed to save")
        }
        
        updateNotifications()
    }
    
    func load() {
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
            let data = try Data(contentsOf: path)
            groups = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Group] ?? [Group]()
        } catch {
            print("Failed to load")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Notifications
    
    func updateNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { [unowned self] (granted, error) in
            if granted {
                self.createNotifications()
            }
        }
    }
    
    //Removes currently scheduled notifications, then checks all groups/alarms to schedule
    func createNotifications(){
        let center = UNUserNotificationCenter.current()
        
        //Remove any pending notifications
        center.removeAllPendingNotificationRequests()
        
        for group in groups {
            //ignore disabled groups
            guard group.enabled == true else { continue }
            
            for alarm in group.alarms {
                //Create notification request from each alarm
                let notification = createNotificationRequest(group: group, alarm: alarm)
                
                //schedule notification for delivery
                center.add(notification) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            }
        }
    }
    
    
    //Creates actual notification with title, sound, time
    func createNotificationRequest(group: Group, alarm: Alarm) -> UNNotificationRequest {
        //create content for notification
        let content = UNMutableNotificationContent()
        
        //assign user name and caption
        content.title = alarm.name
        content.body = alarm.caption
        
        //give id we can attach to custom buttons later on
        content.categoryIdentifier = "alarm"
        
        //attach group and alarm id for this alarm
        content.userInfo = ["group": group.id, "alarm": alarm.id]
        
        //attach sound if requested
        if group.playSound {
            content.sound = UNNotificationSound.default
        }
        
        //use createNotificationAttachments to attach a picture to alert
        content.attachments = createNotificationAttachments(alarm: alarm)
        
        //get calendar ready to pull date components
        let cal = Calendar.current
        
        //pull out hour and minute components for this alarm
        var dateComponents = DateComponents()
        dateComponents.hour = cal.component(.hour, from: alarm.time)
        dateComponents.minute = cal.component(.minute, from: alarm.time)
        
        //create trigger matching components, set to repeat
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        //To quickly test changes use this trigger
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        //combine the content and the trigger to create a notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        //pass object back to createNotifications for scheduling
        return request
    }
    
    
    //Adds user image to notification if available
    //Note: When attaching an image to a Notification, it gets moved into a separate location
    //      so that it can be guaranteed to exist when shown.
    func createNotificationAttachments(alarm: Alarm) -> [UNNotificationAttachment] {
        //Return if no image to attach
        guard alarm.image.count > 0 else { return [] }
        
        let fm = FileManager.default
        
        do {
            //get full path to alarm image
            let imageURL = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            
            //create temporary filename and copy image over
            let copyURL = Helper.getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).jpg")
            try fm.copyItem(at: imageURL, to: copyURL)
            
            //Create an attachment from temp file, give random id
            let attachment = try UNNotificationAttachment(identifier: UUID().uuidString, url: copyURL)
            
            //return back to createNotificationRequest()
            return [attachment]
        } catch {
            print("Failed to attach alarm image: \(error)")
            return []
        }
    }
    
    
    //MARK: - Notifaction Delegate Methods
    
    //Only show message while app is running, no sound
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}

