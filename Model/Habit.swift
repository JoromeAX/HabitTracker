//
//  Habit.swift
//  HabitTracker
//
//  Created by Roman Khancha on 22.10.2024.
//

import Foundation
import SwiftData

@Model
class Habit {
    @Attribute var id: UUID
    @Attribute var name: String
    @Attribute var frequency: Frequency
    @Attribute var progress: Int
    @Attribute var reminderTime: Date?
    @Attribute var createdAt: Date
    @Attribute var lastUpdateDate: Date?
    @Attribute var dailyCheck: [Date: Bool] = [:]
    
    var isUpdatedToday: Bool {
        guard let lastUpdateDate = lastUpdateDate else { return false }
        return Calendar.current.isDateInToday(lastUpdateDate)
    }
    
    init(name: String, frequency: Frequency, reminderTime: Date? = nil, createdAt: Date) {
        self.id = UUID()
        self.name = name
        self.frequency = frequency
        self.reminderTime = reminderTime
        self.createdAt = createdAt
        self.progress = 0
    }
    
    func updateProgress() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastUpdate = lastUpdateDate, Calendar.current.isDate(lastUpdate, inSameDayAs: today) {
            return false
        }
        
        dailyCheck[today] = true
        progress += 1
        lastUpdateDate = today
        return true
    }
}

enum Frequency: Codable, CaseIterable {
    case daily
    case weekly
    case monthly
    case yearly
    
    var displayName: String {
        switch self {
        case .daily:
            return "Every day"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
}
