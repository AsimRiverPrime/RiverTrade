//
//  NotificationViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 15/07/2024.
//

import UIKit
import Foundation

class NotificationViewController: BaseViewController {

    @IBOutlet weak var no_notification_view: UIStackView!
    @IBOutlet weak var lbl_title: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var notifications: [NotificationItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        tableView.registerCells([
            NotificationTVCell.self
        ])
        
        tableView.delegate = self
        tableView.dataSource = self

               // Load notifications
        fetchNotifications()
       
       
        if notifications.count == 0 {
            no_notification_view.isHidden = false
            tableView.isHidden = true
        }else{
            no_notification_view.isHidden = true
            tableView.isHidden = false
        }
        // Do any additional setup after loading the view.
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        
    }
    
    func fetchNotifications() {
        notifications = NotificationHandler.shared.getSavedNotifications() // Fetch your notifications
        notifications.sort { !$0.isSeen && $1.isSeen } // Unseen at the top
        tableView.reloadData()
    }
    @IBAction func closeBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            print("Bottom sheet dismissed after cross btn click")
        })
    }
    
    @IBAction func readAllBtnAction(_ sender: Any) {
        print("press read all button")
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let nib = UINib(nibName: "NotificationTVCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NotificationTVCell")
        
        
        let cell = tableView.dequeueReusableCell(with: NotificationTVCell.self, for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        
        let notification = notifications[indexPath.row]

        cell.lbl_title.text = notification.title
        cell.lbl_status?.text = notification.message
        
        
        let time = DateHelper.timeAgo1(from: notification.date)
        
        cell.lbl_date.text = time
        // Highlight unseen notifications
        cell.view_Unseen.backgroundColor = notification.isSeen ? .clear : .systemRed

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]

        // Mark as seen
        NotificationHandler.shared.markNotificationAsSeen(notificationID: notification.id)

        // Reload data
        notifications = NotificationHandler.shared.getSavedNotifications()
        tableView.reloadData()

        // Perform actions based on notification type/status
        print("Notification selected: \(notification.type), Status: \(notification.status)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
            return 85.0
        }
}


