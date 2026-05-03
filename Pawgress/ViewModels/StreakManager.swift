//
//  StreakManager.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/27/26.
//
import SwiftData
import SwiftUI
import Combine

@MainActor
class StreakManager: ObservableObject{
    var modelContext: ModelContext
    
    @Published var currentStreakDisplay: Int = 0
    
    init(modelContext: ModelContext){
        self.modelContext =  modelContext
    }
    
    func refreshStreak(for pet: Pet){
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        
        // prevent double incrementing on the same day
        if let lastDate = pet.lastActiveDate, calendar.isDateInToday(lastDate){
            return
        }
        
        // check for activity (workout, rest, exercise, food, or water)
        if hasAnyActivity(on: todayStart){
            let yesterday = calendar.date(byAdding: .day,value: -1, to: todayStart)!
            
            if hasAnyActivity(on: yesterday){
                pet.currentStreak += 1
            } else{
                pet.currentStreak = 1 // reset to 1
            }
            pet.lastActiveDate = Date()
        } else {
            enforceStreakExpiry(pet: pet)
        }
    }
    
    private func enforceStreakExpiry(pet: Pet){
        let calendar = Calendar.current
        guard let lastDate = pet.lastActiveDate else {return}
        
        let yesterday = calendar.date(byAdding: .day,value: -1, to: Date())!
        
        // if the last activity was before yesterday, streak is gone
        if lastDate < yesterday {
            pet.currentStreak = 0
        }
    }
    
    private func hasAnyActivity(on date: Date) -> Bool {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        
        // swiftdat predicates for models
        let workoutFetch = FetchDescriptor<Workout>(predicate: #Predicate{$0.date >= start && $0.date < end})
        let exerciseFetch = FetchDescriptor<Exercise>(predicate: #Predicate{$0.date >= start && $0.date < end})
        let restFetch = FetchDescriptor<RestDay>(predicate: #Predicate{$0.date >= start && $0.date < end})
        let foodFetch = FetchDescriptor<FoodEntry>(predicate: #Predicate{$0.date >= start && $0.date < end})
        let waterFetch = FetchDescriptor<HydrationEntry>(predicate: #Predicate{$0.date >= start && $0.date < end})
        
        // check if any of these return a count > 0
        let counts = [
            (try? modelContext.fetchCount(workoutFetch)) ?? 0,
            (try? modelContext.fetchCount(exerciseFetch)) ?? 0,
            (try? modelContext.fetchCount(restFetch)) ?? 0,
            (try? modelContext.fetchCount(foodFetch)) ?? 0,
            (try? modelContext.fetchCount(waterFetch)) ?? 0
        ]
        
        return counts.contains {$0 > 0}
    }
}
