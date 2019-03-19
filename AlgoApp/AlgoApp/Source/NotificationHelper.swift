//
//  Scheduler.swift
//  AlgoApp
//
//  Created by Huong Do on 3/17/19.
//  Copyright © 2019 Huong Do. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import UserNotifications

final class NotificationHelper: NSObject {
    
    static let shared = NotificationHelper()
    let center = UNUserNotificationCenter.current()
    
    private static let openProblemActionId = "com.ichigo.AlgoApp.reminders.problem"
    private static let reminderCategoryId = "com.ichigo.AlgoApp.reminders"
    
    private static let reminderIdKey = "reminderId"
    
    override init() {
        super.init()
        setupNotificationSettings()
    }
    
    func setupNotificationSettings() {
        
        let openProblemAction = UNNotificationAction(
            identifier: NotificationHelper.openProblemActionId,
            title: "Solve Problem",
            options: .foreground
        )
        
        let reminderCategory = UNNotificationCategory(
            identifier: NotificationHelper.reminderCategoryId,
            actions: [openProblemAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        center.setNotificationCategories([reminderCategory])
        center.delegate = self
    }
    
    func updateScheduledNotifications(for reminder: ReminderDetail) {
        cancelAllScheduledNotifications(for: reminder) { [weak self] in
            guard reminder.enabled else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "Time to practice coding again!"
            content.body = "A coding problem is waiting for you to solve 👩‍💻"
            content.categoryIdentifier = NotificationHelper.reminderCategoryId
            content.userInfo[NotificationHelper.reminderIdKey] = reminder.id
            
            let calendar = Calendar.current
            let minuteComponent = calendar.component(.minute, from: reminder.date)
            let hourComponent = calendar.component(.hour, from: reminder.date)
            
            var dateComponents = DateComponents()
            dateComponents.calendar = calendar
            dateComponents.hour = hourComponent
            dateComponents.minute = minuteComponent
            
            if reminder.repeatDays.isEmpty {
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                self?.center.add(request, withCompletionHandler: nil)
            } else {
                for weekday in reminder.repeatDays {
                    dateComponents.weekday = weekday
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    self?.center.add(request, withCompletionHandler: nil)
                }
            }
        }
    }
    
    func cancelAllScheduledNotifications(for reminder: ReminderDetail,
                                         completionHandler: @escaping (() -> Void)) {
        
        center.getPendingNotificationRequests { [weak self] requests in
            var foundRequestIds: [String] = []
            for request in requests {
                guard let reminderId = request.content.userInfo[NotificationHelper.reminderIdKey] as? String,
                    reminderId == reminder.id else { continue }
                foundRequestIds.append(request.identifier)
            }
            
            self?.center.removePendingNotificationRequests(withIdentifiers: foundRequestIds)
            completionHandler()
        }
    }
}

extension NotificationHelper: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
        
        if let reminderId = response.notification.request.content.userInfo[NotificationHelper.reminderIdKey] as? String,
            let questionId = Reminder.randomQuestionId(for: reminderId),
            let window = UIApplication.shared.keyWindow,
            let tabbarController = window.rootViewController as? UITabBarController,
            let navigationController = tabbarController.viewControllers?.first as? UINavigationController {
            
            if let presentedController = navigationController.topViewController?.presentedViewController {
                presentedController.dismiss(animated: false, completion: nil)
            }
            
            navigationController.popToRootViewController(animated: false)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
            viewController.viewModel = DetailViewModel(questionId: questionId)
            navigationController.pushViewController(viewController, animated: true)
            
            tabbarController.selectedIndex = 0
            
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }
}

extension Reactive where Base: UNUserNotificationCenter {
    
    public func requestAuthorization(options: UNAuthorizationOptions = []) -> Single<Bool> {
        return Single.create(subscribe: { (event) -> Disposable in
            self.base.requestAuthorization(options: options) { (success: Bool, error: Error?) in
                if let error = error {
                    event(.error(error))
                } else {
                    event(.success(success))
                }
            }
            return Disposables.create()
        })
    }
}

