//
//  FoodWater.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/17/26.
//
import SwiftData
import Foundation

@Model
class FoodEntry{
    var id: UUID = UUID()
    var date: Date = Date()
    var mealType: String        //breakfast, lunch, or dinner
    var category: String        //protein, veggie, grains, fruits
    
    init(date: Date = Date() , mealType: String, category: String) {
        self.date = date
        self.mealType = mealType
        self.category = category
    }
}

@Model
class HydrationEntry{
    var id: UUID = UUID()
    var date: Date = Date()
    var amountOZ: Double
    
    init(date: Date, amountOZ: Double) {
        self.date = date
        self.amountOZ = amountOZ
    }
}

@Model
class UserSettings{
    var waterGoalOz: Double = 64.0      //default value
    
    init(waterGoalOz: Double) {
        self.waterGoalOz = waterGoalOz
    }
}
