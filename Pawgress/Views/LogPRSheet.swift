//
//  LogPRSheet.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/20/26.
//
import SwiftUI
import Foundation
import SwiftData

struct LogPRSheet: View {
    
    @ObservedObject var viewModel: WorkoutViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedView = 0
    
    var existingPR: PersonalRecord? = nil
    
    var body: some View {
        ZStack{
            Color("Cream")
                .ignoresSafeArea()
            
            VStack(spacing: 10){
                Text(existingPR == nil ? "LOG PR" : "EDIT PR")
                    .font(.custom("Mega Champs", size: 45))
                    .foregroundStyle(Color("FireOrange"))
                
            // MARK: -  Log info
                ExercisePRInput(viewModel: viewModel, existingPR: existingPR)
                
                Spacer()
            }
            .padding(20)
        }
    }
}

struct ExercisePRInput: View {
    enum ExerciseType{
        case setReps
        case time
    }
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var progressionManager: ProgressionManager
    
    @ObservedObject var viewModel: WorkoutViewModel
    var existingPR: PersonalRecord?
    
    @State private var exerciseName = ""
    @State private var selectedType: ExerciseType = .setReps
    @State private var sets  = ""
    @State private var reps = ""
    @State private var time = ""
    @State private var weight = ""

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
                        
            // submit button
            Button {
                if let pr = existingPR {
                    viewModel.updatePR(
                        pr,
                        name: exerciseName.isEmpty ? nil : exerciseName,
                        sets: Int(sets),
                        reps: Int(reps),
                        time: Double(time),
                        weight: Double(weight),
                    )
                } else {
                        viewModel.addPersonalRecord(
                            manager: progressionManager,
                            name: exerciseName,
                            sets: Int(sets),
                            reps: Int(reps),
                            time: Double(time),
                            weight: Double(weight),
                            date: viewModel.selectedDate
                        )
                }
                
                dismiss()
            } label: {
                Text(existingPR == nil ? "Add Personal Record" : "Update Personal Record")
                    .font(.custom("Arial Rounded MT Bold", size: 25))
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color("FireOrange"))
                    .cornerRadius(25)
            }
            
            // delete button if in edit mode
            if let pr = existingPR {
                Button {
                    viewModel.deletePR(pr)
                    dismiss()
                } label: {
                    Text("Delete Personal Record")
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
            guard let pr = existingPR else {return}
            
            exerciseName = pr.name
            sets = pr.sets.map { String($0) } ?? ""
            reps = pr.reps.map { String($0) } ?? ""
            weight = pr.weight.map { String($0) } ?? ""
            time = pr.time.map { String($0) } ?? ""
            
            if pr.time != nil {
                selectedType = .time
            } else {
                selectedType = .setReps
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Workout.self, Exercise.self, RestDay.self, PersonalRecord.self)
    let context = container.mainContext
    
    return LogPRSheet(viewModel: WorkoutViewModel(context: context))
}
