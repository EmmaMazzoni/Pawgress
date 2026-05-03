//
//  DataSeeder.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/24/26.
//
import SwiftData
import Foundation

// Auto load in the challenge data, not editable by users
@MainActor
struct DataSeeder{
    
    static func seedChallenge(context: ModelContext){
        // only seed if challenges do not yet exist
        let descriptor = FetchDescriptor<Challenge>()
        guard let existing = try? context.fetch(descriptor), existing.isEmpty else {return}
        
        //define accessories
        //defaults
        //hats
        let hat_1 = Accessory(name: "hat_1", isUnlocked: true)
        let hat_2 = Accessory(name: "hat_2", isUnlocked: true)
        
        //collars
        let collar_1 = Accessory(name: "collar_1", isUnlocked: true)
        let collar_2 = Accessory(name: "collar_2", isUnlocked: true)
        let collar_3 = Accessory(name: "collar_3", isUnlocked: true)
        
        //back
        let back_1 = Accessory(name: "back_1", isUnlocked: true)
        let back_3 = Accessory(name: "back_3", isUnlocked: true)
        
        let defaultAccessories = [
            hat_1, hat_2,
            collar_1, collar_2, collar_3,
            back_1,back_3
        ]
        
        //unloackable
        let back_2 = Accessory(name: "back_2", isUnlocked: false)
        let hat_3 = Accessory(name: "hat_3", isUnlocked: false)
        
        //define badges
        let workoutBadge = Badge(name: "First Workout", imageName: "workout_badge")
        let foodBadge = Badge(name: "First Food", imageName: "food_badge")
        let aprilBadge = Badge(name:"April Challenge", imageName: "april_badge")
        
        //define challenges
        let challenges = [
            Challenge(
                title: "First Workout",
                descriptionText: "Log your first workout",
                type: .workoutCount,
                goal: 1,
                xpReward: 100,
                badge: workoutBadge,
                accessoryReward: back_2
            ),
            Challenge(
                title: "First Food",
                descriptionText: "Log your first food",
                type: .foodLog,
                goal: 1,
                xpReward: 100,
                badge: foodBadge
            ),
            Challenge(
                title: "April Challenge",
                descriptionText: "Log 3 PRs this month",
                type: .prCount,
                goal: 3,
                xpReward: 1000,
                badge: aprilBadge,
                accessoryReward: hat_3
            )
        ]
        
        for challenge in challenges{
            context.insert(challenge)
        }
        
        for accessory in defaultAccessories {
            context.insert(accessory)
        }
        
        do{
            try context.save()
        } catch {
            print("Failed to seed challenges: \(error)")
        }
        
    }
}
