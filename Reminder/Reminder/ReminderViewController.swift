//
//  ReminderViewController.swift
//  Reminder
//
//  Created by Banu on 20/03/21.
//

import UIKit
import UserNotifications

class ReminderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound])
                                                { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
    
    }
    }
    @IBAction func reminderButtonAction(_ sender: Any) {
        let content = UNMutableNotificationContent()
        content.title = "Medicine Reminder"
        content.subtitle = "IT's Time to Intake Your Medicine "
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let  request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
}
