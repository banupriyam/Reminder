//
//  ReminderTableViewController.swift
//  Reminder
//
//  Created by Banu on 20/03/21.
//

import UIKit
import UserNotifications
import CoreData

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy hh:mm a"
        let toString = formatter.string(from: self)
        return toString
    }
}


class ReminderTableViewController: UIViewController {
    
    @IBOutlet weak var reminderTableView: UITableView!
    var reminders: [ReminderMessage] = []
    var datePicker: UIDatePicker = UIDatePicker()
    var dateTextField: UITextField?
    //var date: [Date] = []
    //    let toolBar = UIToolbar()
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appdelegate =  UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ReminderMessage")
        reminders = try! managedContext.fetch(fetchRequest) as! [ReminderMessage]
    }
    
    @IBAction func addNewReminderAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Reminder", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Message to be reminded about"
        })
        alertController.addTextField(configurationHandler: {(textField) in
            self.configureDatePickerFor(textField: textField)
        })
        
        let saveAction = UIAlertAction(title: "Save", style: .default){ action in
            
            guard let textField = alertController.textFields?.first,
                  let reminderText = textField.text else {
                return
            }
            self.saveAndConfigureNotification(reminderText: reminderText, date: self.datePicker.date)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present (alertController, animated: true,completion: nil)
        
    }
    

    func configureDatePickerFor(textField: UITextField) {
        textField.placeholder = "Date & Time"
        textField.inputView = self.datePicker
        dateTextField = textField
        datePicker.datePickerMode = .dateAndTime
        datePicker.timeZone = NSTimeZone.local
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        print(sender.date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateTextField?.text = sender.date.toString()
    }


    func saveAndConfigureNotification(reminderText: String, date: Date) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
           return
         }
         
         let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "ReminderMessage",
                                       in: managedContext)!
          
          let message = NSManagedObject(entity: entity, insertInto: managedContext) as! ReminderMessage
        
        message.text = reminderText
        message.date = date
        do {
            try managedContext.save()
            reminders.append(message)
            reminderTableView.reloadData()
          } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
          }
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.subtitle = reminderText
        content.sound = UNNotificationSound.default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let  request = UNNotificationRequest(identifier: date.description, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func updateReminder(reminder: ReminderMessage) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        try? managedContext.save()
        reminderTableView.reloadData()
    }
    
    func deleteReminder(at: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let reminder = reminders[at]
        managedContext.delete(reminder)
        try? managedContext.save()
        reminders.remove(at: at)
        reminderTableView.reloadData()
    }
      
    func editReminder(at: Int) {
        let reminder = reminders[at]
        let alertController = UIAlertController(title: "Reminder", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(textField) in
            textField.text = reminder.text
            textField.placeholder = "Message to be reminded about"
        })
        alertController.addTextField(configurationHandler: {(textField) in
            textField.text = reminder.date?.toString()
            self.configureDatePickerFor(textField: textField)
        })
        
        let saveAction = UIAlertAction(title: "Update", style: .default){ action in
            
            guard let textField = alertController.textFields?.first,
                  let reminderText = textField.text else {
                return
            }
            reminder.text = reminderText
            reminder.date = self.datePicker.date
            self.updateReminder(reminder: reminder)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present (alertController, animated: true,completion: nil)
        
    }
}

extension ReminderTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCellId", for: indexPath)
        let reminder = reminders[indexPath.row]
        cell.textLabel?.text = reminder.text
        cell.detailTextLabel?.text = reminder.date?.toString()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Edit", style: .default , handler:{ (UIAlertAction)in
                self.editReminder(at: indexPath.row)
            }))

            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction)in
                self.deleteReminder(at: indexPath.row)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            }))

            self.present(alertController, animated: true, completion: nil)
    }
}

