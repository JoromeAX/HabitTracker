//
//  HabitViewModel.swift
//  HabitTracker
//
//  Created by Roman Khancha on 22.10.2024.
//

import SwiftUI
import Foundation
import SwiftData
import Combine
import UserNotifications

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    private var cancellables = Set<AnyCancellable>()
    private var context: ModelContext?
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    func fetchHabits() {
        guard let context = context else { return }
        do {
            let fetchedHabits = try context.fetch(FetchDescriptor<Habit>())
            self.habits = fetchedHabits
        } catch {
            print("Error fetching habits: \(error)")
        }
    }
    
    func addHabit(name: String, frequency: Frequency, reminderTime: Date?, createdAt: Date) {
        let newHabit = Habit(name: name, frequency: frequency, reminderTime: reminderTime, createdAt: createdAt)
        do {
            context?.insert(newHabit)
            try context?.save()
            habits.append(newHabit)
        } catch {
            print("Error saving habit: \(error)")
        }
        
        if let reminderTime = reminderTime {
            scheduleNotification(for: newHabit, at: reminderTime)
        }
    }
    
    func saveHabit(_ habit: Habit) {
        do {
            try context?.save()
        } catch {
            print("Error saving habit: \(error)")
        }
    }
    
    func deleteHabit(at index: Int) {
        let habitToDelete = habits[index]
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habitToDelete.id.uuidString])
        
        do {
            context?.delete(habitToDelete)
            try context?.save()
            print("Delete and save")
            print(habits[index].name)
            habits.remove(at: index)
        } catch {
            print("Error deleting habit: \(error)")
        }
    }
    
    func updateProgress(for habit: Habit) {
        if habit.updateProgress() {
            do {
                try context?.save()
                print("Save")
            } catch {
                print("Error saving progress: \(error)")
            }
        }
    }
    
    func getMonthDays(for date: Date) -> [Date] {
        var days: [Date] = []
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let components = calendar.dateComponents([.year, .month], from: date)
        
        for day in range {
            var dayComponents = components
            dayComponents.day = day
            if let dayDate = calendar.date(from: dayComponents) {
                days.append(dayDate)
            }
        }
        
        return days
    }
    
    func scheduleNotification(for habit: Habit, at reminderTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Don't forget: \(habit.name)"
        content.sound = .default
        
        var trigger: UNCalendarNotificationTrigger?
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        
        switch habit.frequency {
        case .daily:
            trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            
        case .weekly:
            let weeklyTriggerDate = Calendar.current.dateComponents([.weekday, .hour, .minute], from: reminderTime)
            trigger = UNCalendarNotificationTrigger(dateMatching: weeklyTriggerDate, repeats: true)
            
        case .monthly:
            let monthlyTriggerDate = Calendar.current.dateComponents([.day, .hour, .minute], from: reminderTime)
            trigger = UNCalendarNotificationTrigger(dateMatching: monthlyTriggerDate, repeats: true)
            
        case .yearly:
            let yearlyTriggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
            trigger = UNCalendarNotificationTrigger(dateMatching: yearlyTriggerDate, repeats: true)
        }
        
        guard let finalTrigger = trigger else { return }
        
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: finalTrigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
    }
}
