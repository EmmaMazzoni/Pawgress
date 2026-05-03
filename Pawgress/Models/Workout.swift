//
//  Workout.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/17/26.
//
import SwiftData
import Foundation

@Model
class Workout{
    var name: String
    var duration: Double
    var date: Date
    
    @Relationship(deleteRule: .cascade)
    var exercises: [Exercise] = []
    
    init(name: String, duration: Double, date: Date) {
        self.name = name
        self.duration = duration
        self.date = date
    }
}

@Model
class Exercise{
    var name: String
    var sets: Int?
    var reps: Int?
    var time: Double?
    var weight: Double?
    var date: Date
    
    var workout: Workout?
    
    init(name: String, sets: Int? = nil, reps: Int? = nil, time: Double? = nil, weight: Double? = nil, date: Date) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.time = time
        self.weight = weight
        self.date = date
    }

}

@Model
class RestDay {
    var date: Date
    
    init(date: Date) {
        self.date = date
    }
}

@Model
class PersonalRecord{
    var name: String
    var sets: Int?
    var reps: Int?
    var time: Double?
    var weight: Double?
    var date: Date
    
    init(name: String, sets: Int? = nil, reps: Int? = nil, time: Double? = nil, weight: Double? = nil, date: Date){
        self.name = name
        self.sets = sets
        self.reps = reps
        self.time = time
        self.weight = weight
        self.date = date
    }
}
