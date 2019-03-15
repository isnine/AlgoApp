//
//  ReminderDetailViewModel.swift
//  AlgoApp
//
//  Created by Huong Do on 3/10/19.
//  Copyright © 2019 Huong Do. All rights reserved.
//

import Foundation
import RealmSwift

final class ReminderDetailViewModel {
    let reminder: ReminderDetail?
    
    private let realm = try! Realm()
    
    init(reminder: ReminderDetail?) {
        self.reminder = reminder
    }
    
    func saveReminder(date: Date, repeatDays: [Int], filter: QuestionFilter?) {
        let reminder = Reminder()
        if let id = self.reminder?.id {
            reminder.id = id
        }
        reminder.date = correctSecondComponent(date: date)
        reminder.repeatDays.append(objectsIn: repeatDays)
        if let filter = filter {
            reminder.filter = FilterObject(with: filter)
        }
        
        try! realm.write {
            realm.add(reminder, update: true)
        }
    }
    
    func deleteReminder() {
        guard let detail = reminder,
            let model = realm.object(ofType: Reminder.self, forPrimaryKey: detail.id) else { return }
        try! realm.write {
            realm.delete(model)
        }
    }
    
    private func correctSecondComponent(date: Date, calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)) -> Date {
        let second = calendar.component(.second, from: date)
        let updatedDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.second,
                                                        value: -second,
                                                        to: date,
                                                        options:.matchStrictly)!
        return updatedDate
    }
}
