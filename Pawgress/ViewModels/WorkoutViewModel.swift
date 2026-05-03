//
//  WorkoutViewModel.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/20/26.
//

import SwiftUI
import SwiftData
import Combine
import HealthKit

@MainActor
class WorkoutViewModel: ObservableObject{
    
    private let context: ModelContext
    
    //MARK: - published data
    @Published var workouts: [Workout]=[]
    @Published var exercises: [Exercise]=[]
    @Published var restDays: [RestDay]=[]
    @Published var personalRecords: [PersonalRecord] = []
    
    //MARK: - UI state (for 7-day selector)
    @Published var selectedDate: Date = Date()
    
    init(context: ModelContext){
        self.context = context
        fetchAll()
    }
    
    //MARK: -  fetch all data
    func fetchAll(){
        do {
            workouts = try context.fetch(FetchDescriptor<Workout>())
            exercises = try context.fetch(FetchDescriptor<Exercise>())
            restDays = try context.fetch(FetchDescriptor<RestDay>())
            personalRecords = try context.fetch(FetchDescriptor<PersonalRecord>())
        } catch {
            print("Fetch error: \(error)")
        }
    }
    
    //MARK: -  add exercise
    func addExercise(
        name: String,
        sets: Int? = nil,
        reps: Int? = nil,
        time: Double? = nil,
        weight: Double? = nil,
        date: Date = Date()
    ){
        let exercise = Exercise(
            name: name,
            sets: sets,
            reps: reps,
            time: time,
            weight: weight,
            date: date
        )
        
        context.insert(exercise)
        try? context.save()
        fetchAll()
    }
    
    //MARK: - add workout
    func addWorkout(manager: ProgressionManager, name: String, duration: Double, date: Date = Date(), exercises: [Exercise] = []){
        
        let workout = Workout(
            name: name,
            duration: duration,
            date: date
        )
                
        // link exercises → workout
        workout.exercises = exercises
                
        for exercise in exercises {
            exercise.workout = workout
            exercise.date = date
        }
                
        context.insert(workout)
        try? context.save()
        
        manager.checkChallenges(type: .workoutCount)
        manager.addXP(amount: 10)
        
        fetchAll()
    }
        
    //MARK: - rest day
    func addRestDay(date: Date = Date()){
        let rest = RestDay(date: date)
        context.insert(rest)
        fetchAll()
    }
    
    //MARK: - personal records
    func addPersonalRecord(
        manager: ProgressionManager,
        name: String,
        sets: Int? = nil,
        reps: Int? = nil,
        time: Double? = nil,
        weight: Double? = nil,
        date: Date = Date()
    ) {
        let pr = PersonalRecord(
            name: name,
            sets: sets,
            reps: reps,
            time: time,
            weight: weight,
            date: date
        )
            
        context.insert(pr)
        
        manager.checkChallenges(type: .prCount)
        manager.addXP(amount: 100)
        
        save()
        
        fetchAll()
    }
    
    //MARK: - filtering system
    // exercises not included in a workout group
    var standAloneExercises: [Exercise]{
        exercises.filter{
            $0.workout == nil &&
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    //exercises inside workouts
    var groupedExercises: [Exercise]{
        exercises.filter {$0.workout != nil}
    }
    
    //workouts for selected days
    func workouts(for date: Date)->[Workout]{
        workouts.filter{
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    //restday for selected day
    func restDays(for date: Date) -> [RestDay] {
        restDays.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    //current selected days workouts
    var selectedDayWorkouts: [Workout]{
        workouts(for: selectedDate)
    }
    
    //current selected day rest days
    var selectedDayRest: [RestDay]{
        restDays(for: selectedDate)
    }
    
    //week logic
    func currentWeekDays()->[Date]{
        let calendar = Calendar.current
        let startOfWeek =  calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return (0..<7).compactMap{
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }
    
    //update day
    func selectedDay(_ date: Date){
        selectedDate = date
    }
    
    //MARK: - edit functions
    func updateExercise(
        _ exercise: Exercise,
        name: String? = nil,
        sets: Int? = nil,
        reps: Int? = nil,
        time: Double? = nil,
        weight: Double? = nil
    ){
        if let name = name {exercise.name = name}
        if let sets = sets {exercise.sets = sets}
        if let reps = reps {exercise.reps = reps}
        if let time = time {exercise.time = time}
        if let weight = weight {exercise.weight = weight}
        
        save()
        fetchAll()
    }
    
    func updateWorkout(
        _ workout: Workout,
        name: String? = nil,
        duration: Double? = nil,
        exercises: [Exercise]? = nil
    ){
        if let name = name {workout.name = name}
        if let duration = duration {workout.duration = duration}
        
        if let exercises = exercises {
            workout.exercises = exercises
            for exercise in exercises {
                exercise.workout = workout
            }
        }
        
        save()
        fetchAll()
    }
    
    func updatePR(
        _ pr: PersonalRecord,
        name: String? = nil,
        sets: Int? = nil,
        reps: Int? = nil,
        time: Double? = nil,
        weight: Double? = nil
    ){
        if let name = name {pr.name = name}
        if let sets = sets {pr.sets = sets}
        if let reps = reps {pr.reps = reps}
        if let time = time {pr.time = time}
        if let weight = weight {pr.weight = weight}
        
        save()
        fetchAll()
    }
    
    //MARK: -  delete functions
    
    //when you delete a workout it does not delete all the individual exrcises
    func deleteWorkout(_ workout: Workout, manager: ProgressionManager) {
        workout.exercises.forEach { $0.workout = nil }
        context.delete(workout)
        
        manager.addXP(amount: -10) // Revoke Workout XP
        manager.checkChallenges(type: .workoutCount, increment: -1)
        
        save()
        fetchAll()
    }
    
    func deleteExercise(_ exercise: Exercise){
        context.delete(exercise)
        save()
        fetchAll()
    }
    
    // when you delete a PR the XP is not removed due to PRs being something consistently updated
    func deletePR(_ pr: PersonalRecord){
        context.delete(pr)
        save()
        fetchAll()
    }
    
    func deleteRestDay(_ restDay: RestDay){
        context.delete(restDay)
        save()
        fetchAll()
    }
    
    //MARK: - save
    private func save(){
        do{
            try context.save()
        } catch{
            print("Save Error: \(error)")
        }
    }
    
    //MARK: - Healthkit integration
    func syncWithHealthKit(manager: HealthKitManager, progression: ProgressionManager) {
        // Look back 7 days for sync
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        manager.fetchRecentWorkouts(since: startDate) { hkWorkouts in
            Task { @MainActor in
                for hkWorkout in hkWorkouts {
                    // check if this workout already exists in SwiftData to avoid duplicates
                    // we compare date and duration as a unique identifier
                    let isDuplicate = self.workouts.contains {
                        $0.date == hkWorkout.startDate && $0.duration == (hkWorkout.duration / 60.0)
                    }
                    
                    if !isDuplicate {
                        let name = self.formatWorkoutName(hkWorkout.workoutActivityType)
                        let durationInMinutes = hkWorkout.duration / 60.0
                        
                        // call existing addWorkout logic
                        self.addWorkout(
                            manager: progression,
                            name: name,
                            duration: durationInMinutes,
                            date: hkWorkout.startDate,
                            exercises: []
                        )
                    }
                }
            }
        }
    }
    
    private func formatWorkoutName(_ type: HKWorkoutActivityType) -> String {
        //helper func to turn something like .traditionalStrengthTraining into "Strength Training"
        switch type{
        case .traditionalStrengthTraining: return "Strength Training"
            case .functionalStrengthTraining: return "Functional Training"
            case .running: return "Run"
            case .walking: return "Walk"
            case .cycling: return "Cycle"
            case .yoga: return "Yoga"
            default: return "Apple Watch Workout"
        }
    }
}
