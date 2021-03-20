//
//  ReminderTableViewController.swift
//  Reminder
//
//  Created by Banu on 20/03/21.
//

import UIKit
import UserNotifications

class ReminderTableViewController: UIViewController {
    
    @IBOutlet weak var reminderTableView: UITableView!
    var texts: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = " My Reminder"
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound])
        { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
  
            
        }
    }
    @IBAction func reminderTableViewAction(_ sender: Any) {
        let alert = UIAlertController(title: "Reminder", message: "Enter Your Text Here", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default){ action in
            
            guard let textField = alert.textFields?.first,
                  let textToSave = textField.text else {
                return
            }
            self.texts.append(textToSave)
            self.reminderTableView.reloadData()
            self.showNotification(notificationContent: textToSave)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present (alert, animated: true)
        
    }
    
    func showNotification(notificationContent: String) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.subtitle = notificationContent
        content.sound = UNNotificationSound.default
//        let currentDate = Date()
        let nextTriggerDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextTriggerDate)

//        var components = DateComponents()
//        components.second = 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let  request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

extension ReminderTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "ReminderCellId",
                                          for: indexPath)
        cell.textLabel?.text = texts[indexPath.row]
        return cell
    }
    
}

