//
//  HabitCreateView.swift
//  HabitTracker
//
//  Created by Roman Khancha on 22.10.2024.
//

import SwiftUI

struct HabitCreateView: View {
    @State private var name: String = ""
    @State private var frequency: Frequency = .daily
    @State private var reminderTime: Date = Date()
    @State private var createdAt: Date = Date()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel: HabitViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit name")) {
                    TextField("Enter a name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                
                Section(header: Text("Frequency")) {
                    Picker("Select frequency", selection: $frequency) {
                        ForEach(Frequency.allCases, id: \.self) { frequency in
                            Text(frequency.displayName)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Reminder time")) {
                    DatePicker("Select time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                Button(action: {
                    addHabit()
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.bordered)
            }
            .navigationTitle("New habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func addHabit() {
        viewModel.addHabit(name: name, frequency: frequency, reminderTime: reminderTime, createdAt: createdAt)
        dismiss()
    }
}
