//
//  LogWorkoutSheet.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/20/26.
//

import SwiftUI
import SwiftData
import Foundation

struct LogWorkoutSheet: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @ObservedObject var petViewModel: PetViewModel
    
    @EnvironmentObject var progressionManager: ProgressionManager
    
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedView = 0
    
    var existingWorkout: Workout?
    var existingExercise: Exercise?
    var existingRest: RestDay?
    
    var body: some View {
        ZStack{
            Color("Cream")
                .ignoresSafeArea()
            
            //MARK: - Choose what you are logging
            VStack(spacing: 10){
                Text(existingWorkout == nil && existingExercise == nil ? "LOG" : "EDIT")
                    .font(.custom("Mega Champs", size: 45))
                    .foregroundStyle(Color("FireOrange"))
                Picker("View", selection: $selectedView) {
                    Text("Exercise")
                        .tag(0)
                    Text("Workout")
                        .tag(1)
                    Text("Rest Day")
                        .tag(2)
                }
                .pickerStyle(.segmented)
                
                if selectedView == 0 {
                    ExerciseInput(viewModel: viewModel, petViewModel: petViewModel, existingExercise: existingExercise)
                } else if selectedView == 1 {
                    WorkoutInput(viewModel: viewModel, petViewModel: petViewModel, existingWorkout: existingWorkout)
                } else{
                    RestInput(viewModel: viewModel, petViewModel: petViewModel, existingRest: existingRest)
                }
                
                Spacer()
            }
            .padding(20)
            .onAppear {
                // If we are editing an existing workout,
                // you can force the tab to 1 (or 0)
                if existingWorkout != nil {
                    selectedView = 1
                } else if (existingRest != nil){
                    selectedView = 2
                }
            }
        }
    }
}

//MARK: - Exercise Input
struct ExerciseInput: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @ObservedObject var petViewModel: PetViewModel

    enum ExerciseType{
        case setReps
        case time
    }
    
    var existingExercise: Exercise?
    
    @State private var exerciseName = ""
    @State private var selectedType: ExerciseType = .setReps
    @State private var sets  = ""
    @State private var reps = ""
    @State private var time = ""
    @State private var weight = ""
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 10){
            //exercise name
            HStack(alignment: .firstTextBaseline){
                Text("Name: ")
                    .font(.custom("Mega Champs", size: 30))
                    .foregroundStyle(Color("DarkBlue"))
                    .lineSpacing(-10)
                TextField("Enter workout name", text: $exerciseName)
                    .font(.custom("Arial Rounded MT Bold", size: 20))
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("LightBlue").opacity(0.7))
                    )
            }
            
            //type picker
            Picker("Type", selection: $selectedType) {
                
                Text("Sets/Reps")
                    .tag(ExerciseType.setReps)
                
                Text("Time")
                    .tag(ExerciseType.time)
            }
            .pickerStyle(.segmented)
            
            //conditional input on sets or time
            if selectedType == .setReps {
                    HStack{
                        TextField("Sets", text: $sets)
                            .keyboardType(.numberPad)
                            .font(.custom("Arial Rounded MT Bold", size: 20))
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("LightBlue").opacity(0.7))
                            )
                                
                        TextField("Reps", text: $reps)
                            .keyboardType(.numberPad)
                            .font(.custom("Arial Rounded MT Bold", size: 20))
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("LightBlue").opacity(0.7))
                            )
                    }
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                            
            } else {
                HStack(alignment: .firstTextBaseline) {
                        Text("Minutes:")
                            .font(.custom("Mega Champs", size: 30))
                            .foregroundStyle(Color("DarkBlue"))
                            .lineSpacing(-10)
                        TextField("Enter time", text: $time)
                            .keyboardType(.numberPad)
                            .font(.custom("Arial Rounded MT Bold", size: 20))
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("LightBlue").opacity(0.7))
                            )
                    }
                    .padding(8)
                    .cornerRadius(10)
            }
            
            // Optional Weight
            HStack(alignment: .firstTextBaseline) {
                Text("Weight:")
                    .font(.custom("Mega Champs", size: 30))
                    .foregroundStyle(Color("DarkBlue"))
                    .lineSpacing(-10)
                TextField("lbs", text: $weight)
                    .keyboardType(.decimalPad)
                    .font(.custom("Arial Rounded MT Bold", size: 20))
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("LightBlue").opacity(0.7))
                    )
            }
            .padding(8)
            .background(.ultraThinMaterial)
            .cornerRadius(10)
                        
            // submit button (no logic yet)
            Button {
                viewModel.addExercise(
                    name: exerciseName,
                    sets: Int(sets),
                    reps: Int(reps),
                    time: Double(time),
                    weight: Double(weight),
                    date: viewModel.selectedDate
                )
                
                //refresh streak
                petViewModel.checkAndRefreshStreak()
                
                dismiss()
            } label: {
                Text(existingExercise == nil ? "Add Exercise" : "Exit Exercise")
                    .font(.custom("Arial Rounded MT Bold", size: 25))
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color("FireOrange"))
                    .cornerRadius(25)
            }
            
            // delete button if in edit mode
            if let exercise = existingExercise{
                Button {
                    viewModel.deleteExercise(exercise)
                    dismiss()
                } label: {
                    Text("Delete Exercise")
                        .font(.custom("Arial Rounded MT Bold", size: 25))
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(25)
                }
            }  
        }
        .onAppear {
            if let exercise = existingExercise {
                exerciseName = exercise.name
                        
                // Determine type based on whether time or reps exists
                if let t = exercise.time, t > 0 {
                    selectedType = .time
                    time = String(t)
                } else {
                    selectedType = .setReps
                    sets = exercise.sets != nil ? String(exercise.sets!) : ""
                    reps = exercise.reps != nil ? String(exercise.reps!) : ""
                }
                        
                if let w = exercise.weight {
                    weight = String(w)
                }
            }
        }
    }
}

//MARK: - workout input
struct WorkoutInput: View {
    
    @ObservedObject var viewModel: WorkoutViewModel
    @ObservedObject var petViewModel: PetViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var progressionManager: ProgressionManager
    
    var existingWorkout: Workout?

    
    @State private var workoutName = ""
    @State private var workoutTime = ""
    
    //fake data for now
    var availableExercises: [Exercise]{
        viewModel.standAloneExercises
    }
    
    @State private var selectedExercises: Set<Exercise.ID> = []
    
    var body: some View {
        VStack(spacing: 10){
            //MARK: - exercise name
            HStack(alignment: .firstTextBaseline){
                Text("Name: ")
                    .font(.custom("Mega Champs", size: 30))
                    .foregroundStyle(Color("DarkBlue"))
                    .lineSpacing(-10)
                TextField("Enter workout name", text: $workoutName)
                    .font(.custom("Arial Rounded MT Bold", size: 20))
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("LightBlue").opacity(0.7))
                    )
            }
            
            //MARK: -time
            HStack(alignment: .firstTextBaseline){
                Text("TIME: ")
                    .font(.custom("Mega Champs", size: 30))
                    .foregroundStyle(Color("DarkBlue"))
                    .lineSpacing(-10)
                TextField("In minutes", text: $workoutTime)
                    .keyboardType(.numberPad)
                    .font(.custom("Arial Rounded MT Bold", size: 20))
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("LightBlue").opacity(0.7))
                    )
            }
            
            //MARK: - exercise selection
            VStack(alignment: .leading, spacing: 8) {
                            
                Text("Exercises:")
                    .font(.custom("Mega Champs", size: 30))
                    .foregroundStyle(Color("DarkBlue"))
                            
                VStack(spacing: 8) {
                    ForEach(availableExercises, id: \.self) { exercise in
                        HStack {
                                        
                            // fake radio/checkbox
                            Image(systemName: selectedExercises.contains(exercise.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(Color("DarkBlue"))
                                        
                            Text(exercise.name)
                                .font(.custom("Arial Rounded MT Bold", size: 18))
                                .foregroundColor(Color("DarkBlue"))
                                        
                            Spacer()
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color("LightBlue").opacity(0.4))
                            )
                        .onTapGesture {
                            toggleExercise(exercise)
                        }
                    }
                }
            }
            
            // MARK: - Submit Button
            Button {
                let selected = viewModel.exercises.filter{
                    selectedExercises.contains($0.id)
                }
                
                if let workout = existingWorkout {
                    viewModel.updateWorkout(
                    workout,
                    name: workoutName,
                    duration: Double(workoutTime) ?? 0,
                    exercises: selected
                    )
                } else {
                        viewModel.addWorkout(
                            manager: progressionManager,
                            name: workoutName,
                            duration: Double(workoutTime) ?? 0,
                            date: viewModel.selectedDate,
                            exercises: selected
                        )
                    
                    //refresh streak
                    petViewModel.checkAndRefreshStreak()
                }
                
                dismiss()
            } label: {
                Text(existingWorkout == nil ? "Add Workout" : "Edit Workout")
                    .font(.custom("Arial Rounded MT Bold", size: 25))
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color("FireOrange"))
                    .cornerRadius(25)
            }
            .padding(.top, 10)
            
            // delete button if in edit mode
            if let workout = existingWorkout{
                Button {
                    viewModel.deleteWorkout(workout, manager: progressionManager)
                    dismiss()
                } label: {
                    Text("Delete Workout")
                        .font(.custom("Arial Rounded MT Bold", size: 25))
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(25)
                }
            }
        }
        .onAppear{
            guard let workout =  existingWorkout else {return}
            
            workoutName = workout.name
            workoutTime = String(workout.duration)
            selectedExercises = Set(workout.exercises.map { $0.id })
        }
    }
    
    // MARK: - Toggle logic
    private func toggleExercise(_ exercise: Exercise) {
        if selectedExercises.contains(exercise.id) {
            selectedExercises.remove(exercise.id)
        } else {
            selectedExercises.insert(exercise.id)
        }
    }
}

//MARK: - Rest day input
struct RestInput: View {
    
    @ObservedObject var viewModel: WorkoutViewModel
    @ObservedObject var petViewModel: PetViewModel
    @Environment(\.dismiss) private var dismiss
    
    var existingRest: RestDay?

    var body: some View {
        VStack {
            if let restDay = existingRest {
            // DELETE MODE
                Text("You logged this day as a rest day.")
                    .font(.custom("Arial Rounded MT Bold", size: 18))
                    .foregroundColor(Color("DarkBlue"))
                    .padding(.bottom, 10)

                Button {
                    viewModel.deleteRestDay(restDay)
                    
                    //refresh streak
                    petViewModel.checkAndRefreshStreak()
                    
                    dismiss()
                } label: {
                    Text("Delete Rest Day")
                        .font(.custom("Arial Rounded MT Bold", size: 25))
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(25)
                }
            } else {
                // LOG MODE
                Button {
                    viewModel.addRestDay(date: viewModel.selectedDate)
                    dismiss()
                } label: {
                    Text("Log Rest Day")
                        .font(.custom("Arial Rounded MT Bold", size: 25))
                        .foregroundColor(Color("DarkBlue"))
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color("LightBlue"))
                        .cornerRadius(25)
                }
            }
        }
        .padding(.top, 10)
        
    }
}

//#Preview {
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        // Include all models used by ViewModels
//        let container = try ModelContainer(
//            for: Workout.self, Exercise.self, RestDay.self, Pet.self,
//            configurations: config
//        )
//
//        let context = container.mainContext
//        
//        // 1. Initialize ViewModels and Managers
//        let workoutVM = WorkoutViewModel(context: context)
//        let petVM = PetViewModel(modelContext: context)
//        let progression = ProgressionManager(context: context)
//
//        // 2. Return the sheet with all required arguments
//        return LogWorkoutSheet(viewModel: workoutVM, petViewModel: petVM)
//            .modelContainer(container)
//            .environmentObject(progression)
//
//    } catch {
//        return Text("Preview failed: \(error.localizedDescription)")
//    }
//}
