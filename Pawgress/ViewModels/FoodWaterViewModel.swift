//
//  FoodWaterViewModel.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/22/26.
//
import SwiftData
import SwiftUI
import Foundation
import Combine

@MainActor
class FoodWaterViewModel: ObservableObject {
    @Published var selectedMeal: String = "breakfast"
    @Published var selectedDate: Date = Date()
    
    //MARK: - Water Logging
    func totalWater(for date: Date, from entries: [HydrationEntry]) -> Double{
        entries.filter({Calendar.current.isDate($0.date, inSameDayAs: date)})
            .reduce(0) {$0 + $1.amountOZ}
    }
    
    func updateWaterGoal(context: ModelContext, newGoal: Double, settings: UserSettings?){
        if let settings = settings{
            settings.waterGoalOz = newGoal
        } else {
            let newSettings = UserSettings(waterGoalOz: newGoal)
            context.insert(newSettings)
        }
    }
    
    func addWater(context: ModelContext, manager: ProgressionManager, amount: Double, date: Date){
        let newHydration = HydrationEntry(date: date, amountOZ: amount)
        context.insert(newHydration)
        
        do{
            try context.save()
        } catch{
            print("Failed to save water: \(error)")
        }
        manager.checkChallenges(type: .hydration, increment: Int(amount))
        manager.addXP(amount: 5)
    }
    
    //MARK: - food logic
    func isGroupChecked(meal: String, group: String, for date: Date, from entries: [FoodEntry])->Bool{
        entries.contains{
            $0.mealType == meal &&
            $0.category == group &&
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    func toggleFoodGroup(context: ModelContext, manager: ProgressionManager, meal: String, group: String, date: Date, entries: [FoodEntry]){
        
        if let existingIndex = entries.firstIndex(where: {
            $0.mealType == meal && $0.category == group && Calendar.current.isDate($0.date, inSameDayAs: date)
        }){
            context.delete(entries[existingIndex])
            
            manager.addXP(amount: -10)
            manager.checkChallenges(type: .foodLog, increment: -1)
        } else {
            let newEntry = FoodEntry(date: date, mealType: meal, category: group)
            context.insert(newEntry)
            manager.checkChallenges(type: .foodLog, increment: 1)
            manager.addXP(amount: 10)
        }
 
        do {
            try context.save()
            //print("Save successful")
        } catch {
            print("Save failed: \(error)")
        }
    }
    
    //MARK: - week logic
    func currentWeekDays() -> [Date] {
        let calendar = Calendar.current
        // find the start of the week (Sunday)
        let today = calendar.startOfDay(for: Date())
        let dayOfWeek = calendar.component(.weekday, from: today)
        
        // subtract days to get back to Sunday (1)
        guard let sunday = calendar.date(byAdding: .day, value: 1 - dayOfWeek, to: today) else {
            return (0..<7).map { _ in Date() }
        }
        
        // generate all 7 days
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: sunday) }
    }

    func selectDay(_ day: Date) {
        selectedDate = day
    }
}
