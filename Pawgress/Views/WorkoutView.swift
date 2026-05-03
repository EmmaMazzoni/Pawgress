//
//  WorkoutView.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/12/26.
//

import SwiftUI
import SwiftData

struct WorkoutView: View {
    @EnvironmentObject var progressionManager: ProgressionManager
    @StateObject var healthManager = HealthKitManager()
    
    enum TopTab{
        case log
        case pr
    }
    @State private var selectedTab: TopTab = .log
    
    @StateObject private var viewModel: WorkoutViewModel
    @ObservedObject var petViewModel: PetViewModel
    
    
    init(context: ModelContext, petViewModel: PetViewModel) {
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(context: context))
        self.petViewModel = petViewModel
    }
    
    var body: some View {
        ZStack{
            Color("Cream")
                .ignoresSafeArea()
            ScrollView(){
                VStack(spacing: 5){
                    //MARK: - Page tabs Log and PR Tracker
                    HStack{
                        Button(action:{
                            withAnimation{
                                selectedTab = .log
                            }
                        }){
                            Text("LOG")
                                .font(.custom("Mega Champs", size: 40))
                                .foregroundStyle(selectedTab == .log ? Color("DarkBlue") : Color("DarkBlue").opacity(0.6))
                                .lineSpacing(-10)
                        }
                        Spacer()
                        Button(action:{
                            withAnimation{
                                selectedTab = .pr
                            }
                        }){
                            Text("PR TRACKER")
                                .font(.custom("Mega Champs", size: 40))
                                .foregroundStyle(selectedTab == .pr ? Color("DarkBlue") : Color("DarkBlue").opacity(0.6))
                                .lineSpacing(-10)
                        }
                    }
                    .padding(0)
                    
                    if selectedTab == .log{
                        WorkoutLogView(viewModel: viewModel, petViewModel: petViewModel, progressionManager: progressionManager)
                    } else{
                        PRTrackerView(viewModel: viewModel)
                    }
                    
                }
                .padding(30)
            }
        }
        .onAppear{
            healthManager.requestAuthorization{ success in
                if success{
                    viewModel.syncWithHealthKit(manager: healthManager, progression: progressionManager)
                }
            }
        }
    }
}


//MARK: - WorkoutLogView tab 1
struct WorkoutLogView: View{
    
    @ObservedObject var viewModel: WorkoutViewModel
    @ObservedObject var petViewModel: PetViewModel
    
    var progressionManager: ProgressionManager
    
    @State private var showAddWorkout = false
    @State private var selectedWorkout: Workout?
    @State private var selectedExercise: Exercise?
    @State private var selectedRestDay: RestDay?
    
    var body: some View{
        //MARK: - Week selector
        HStack(spacing: 6){
            
            let weekDays = viewModel.currentWeekDays()
            
            //first day (sunday)
            Button{
                viewModel.selectedDay(weekDays[0])
            } label:{
                ZStack{
                    RoundedCorner(radius: 15, corners: [.bottomLeft, .topLeft])
                        .fill(Color("DarkBlue"))
                    Text("S")
                        .font(.custom("Mega Champs", size: 45))
                        .foregroundStyle(
                            Calendar.current.isDate(weekDays[0], inSameDayAs: viewModel.selectedDate) ? Color("LightBlue") : Color("Cream")
                        )
                        .offset(y: 6)
                        .lineSpacing(-10)
                }
            }
            
            ForEach(1..<6, id: \.self){ index in
                let day = weekDays[index]
                let letters = ["M","T","W","R","F"]
                
                Button{
                    viewModel.selectedDay(day)
                } label:{
                    ZStack{
                        Rectangle()
                            .fill(Color("DarkBlue"))
                        Text(letters[index-1])
                            .font(.custom("Mega Champs", size: 45))
                            .foregroundStyle(
                                Calendar.current.isDate(day, inSameDayAs: viewModel.selectedDate) ? Color("LightBlue") : Color("Cream")
                            )
                            .offset(y: 6)
                            .lineSpacing(-10)
                    }
                }
            }
            
            //last day (saturday)
            Button{
                viewModel.selectedDay(weekDays[6])
            } label: {
                ZStack{
                    RoundedCorner(radius: 15, corners: [.bottomRight, .topRight])
                        .fill(Color("DarkBlue"))
                    Text("U")
                        .font(.custom("Mega Champs", size: 45))
                        .foregroundStyle(
                            Calendar.current.isDate(weekDays[6], inSameDayAs: viewModel.selectedDate) ? Color("LightBlue") : Color("Cream")
                        )
                        .offset(y: 6)
                        .lineSpacing(-10)
                }
            }
            
        }
        .frame(width: 340, height: 61)
        .padding(.bottom, 30)
        
        //MARK: - Workout cards
        ForEach(viewModel.selectedDayWorkouts, id: \.id) { workout in
            WorkoutCard(workout: workout, onEdit: { selected in
                self.selectedWorkout = selected
            }, onEditExercise: { exercise in
                self.selectedExercise = exercise
            })
            .padding(10)
        }
        
        //MARK: - standalone exercises
        if !viewModel.standAloneExercises.isEmpty{
            ForEach(viewModel.standAloneExercises, id: \.id){ exercise in
                ExerciseCard(exercise: exercise){selected in
                    self.selectedExercise = selected
                }
                    .padding(10)
            }
        }
        
        //MARK: - rest day?
        ForEach(viewModel.selectedDayRest, id: \.id){ workout in
            RestCard(restDay: workout) { selected in
                self.selectedRestDay = selected
            }
            .padding(10)
        }
                
        Button{
            showAddWorkout = true
        } label: {
            AddButton()
        }
        .sheet(isPresented: $showAddWorkout){
            LogWorkoutSheet(viewModel: viewModel, petViewModel: petViewModel)
        }
        .sheet(item: $selectedWorkout) { workout in
            LogWorkoutSheet(viewModel: viewModel, petViewModel: petViewModel, existingWorkout: workout)
        }
        .sheet(item: $selectedExercise) { exercise in
            LogWorkoutSheet(viewModel: viewModel, petViewModel: petViewModel, existingExercise: exercise)
        }
        .sheet(item: $selectedRestDay) { rest in
            // Replace LogWorkoutSheet with whatever sheet handles RestDay editing/deletion
            LogWorkoutSheet(viewModel: viewModel, petViewModel: petViewModel, existingRest: rest)
        }
        
    }
}

//MARK: - PRTrackerView tab 2
struct PRTrackerView: View{
    @ObservedObject var viewModel: WorkoutViewModel
    
    @State private var showAddPR = false
    @State private var selectedPR: PersonalRecord?


    var body: some View{
        VStack{
            //MARK: - PRCards
            ForEach(viewModel.personalRecords, id: \.id){ pr in
                PRCard(pr: pr){ selected in
                    selectedPR = selected
                }
                .padding(.bottom, 10)
            }
            
            Button{
                showAddPR = true
            } label: {
                AddButton()
            }
        }
        .sheet(isPresented: $showAddPR){
            LogPRSheet(viewModel: viewModel)
        }
        .sheet(item: $selectedPR) { pr in
            LogPRSheet(viewModel: viewModel, existingPR: pr)
        }
    }
}

struct ExerciseCard: View{
    
    let exercise: Exercise
    let onEdit: (Exercise) -> Void

    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color("GradPeach"), Color("GradFireOrange")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            HStack(spacing: 10){
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size:70))
                    .foregroundColor(Color("FireText"))
                VStack(alignment: .leading){
                    Text(exercise.name)
                        .font(.custom("Arial Rounded MT Bold", size: 30))
                        .foregroundStyle(Color("FireText"))
                    if let sets = exercise.sets, let reps = exercise.reps {
                        Text("\(sets)x\(reps)")
                            .font(.custom("Arial Rounded MT Bold", size: 15))
                            .foregroundStyle(Color("FireText"))
                    }

                    if let time = exercise.time {
                        Text("\(time, specifier: "%.2f") min")
                            .foregroundStyle(Color("FireText"))
                            .font(.custom("Arial Rounded MT Bold", size: 15))
                    }
                }
                
                Spacer()
                //TODO: on click should allow you to edit the workout
                VStack{
                    Button{
                        onEdit(exercise)
                    } label: {
                        HStack(spacing: 5){
                            Circle()
                                .frame(width:8, height: 8)
                                .foregroundStyle(Color("Cream"))
                            Circle()
                                .frame(width:8, height: 8)
                                .foregroundStyle(Color("Cream"))
                            Circle()
                                .frame(width:8, height: 8)
                                .foregroundStyle(Color("Cream"))
                            
                        }
                    }
                    Spacer()
                }
            }
            .padding(15)
            
            
            
        }
        .frame(width: 339, height: 127)
    }
}

//MARK: - Workout Card
struct WorkoutCard: View{
    
    let workout: Workout
    let onEdit: (Workout) -> Void
    let onEditExercise: (Exercise) -> Void
    
    @State private var isExpanded = false
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color("GradPeach"), Color("GradFireOrange")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            HStack(spacing: 10){
                Image(systemName: "figure.highintensity.intervaltraining")
                    .font(.system(size:70))
                    .foregroundColor(Color("FireText"))
                VStack(alignment: .leading){
                    Text(workout.name)
                        .font(.custom("Arial Rounded MT Bold", size: 30))
                        .foregroundStyle(Color("FireText"))
                    Text("\(workout.duration.formatted(.number.precision(.fractionLength(0...2)))) min")
                        .font(.custom("Arial Rounded MT Bold", size: 25))
                        .foregroundStyle(Color("FireText"))
                    
                }
                
                Spacer()
                
                // Edit workout buttons
                VStack{
                    Button{
                        onEdit(workout)
                    } label: {
                        HStack(spacing: 5){
                            Circle()
                                .frame(width:8, height: 8)
                                .foregroundStyle(Color("Cream"))
                            Circle()
                                .frame(width:8, height: 8)
                                .foregroundStyle(Color("Cream"))
                            Circle()
                                .frame(width:8, height: 8)
                                .foregroundStyle(Color("Cream"))
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color("Cream"))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
            }
            .padding(15)
        }
        .frame(width: 339, height: 127)
        .onTapGesture {
            withAnimation(.easeInOut){
                isExpanded.toggle()
            }
        }
        
        // Expanded content
        if isExpanded {
            VStack(spacing: 10) {
                ForEach(workout.exercises, id: \.id) { exercise in
                    ExerciseCard(exercise: exercise) { selected in
                            onEditExercise(selected) // Use the callback here
                    }
                }
            }
            .padding(.top, 5)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}

//MARK: -  PR card
struct PRCard: View{
    
    let pr: PersonalRecord
    let onEdit: (PersonalRecord) -> Void
    
    var body: some View{
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color("GradPeach"), Color("GradFireOrange")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    HStack(spacing: 10){
                        Image(systemName: "figure.highintensity.intervaltraining")
                            .font(.system(size:70))
                            .foregroundColor(Color("FireText"))
                        VStack(alignment: .leading){
                            Text(pr.name)
                                .font(.custom("Arial Rounded MT Bold", size: 25))
                                .foregroundStyle(Color("FireText"))
                            
                            // sets x rep
                            if let weight = pr.weight {
                                Text("\(weight.formatted(.number.precision(.fractionLength(0...1)))) lbs")
                                    .font(.custom("Arial Rounded MT Bold", size: 20))
                                    .foregroundStyle(Color("FireText"))
                            }
                            // just time
                            if let time = pr.time {
                                Text("\(time.formatted(.number.precision(.fractionLength(0...2)))) min")
                                    .foregroundStyle(Color("FireText"))
                                    .font(.custom("Arial Rounded MT Bold", size: 20))
                            }
                            Text(pr.date.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year()))
                                .font(.custom("Arial Rounded MT Bold", size: 25))
                                .foregroundStyle(Color("FireText"))
                        }
                        
                        Spacer()
                        
                        // edit/delete button
                        Button{
                            onEdit(pr)
                        } label: {
                            VStack{
                                HStack(spacing: 5){
                                    Circle()
                                        .frame(width:8, height: 8)
                                        .foregroundStyle(Color("Cream"))
                                    Circle()
                                        .frame(width:8, height: 8)
                                        .foregroundStyle(Color("Cream"))
                                    Circle()
                                        .frame(width:8, height: 8)
                                        .foregroundStyle(Color("Cream"))
                                    
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                    
                    
                    
                }
                .frame(width: 339, height: 127)
        
        
    }
}


struct RestCard: View{
    let restDay: RestDay // Assuming your model is named RestDay
    let onEdit: (RestDay) -> Void
        
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color("LightBlue"), Color("GradBlue")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            HStack(spacing: 10){
                Image(systemName: "bed.double.fill")
                    .font(.system(size:70))
                    .foregroundColor(Color("DarkBlue"))
                VStack(alignment: .leading){
                    Text("Rest Day")
                        .font(.custom("Arial Rounded MT Bold", size: 30))
                        .foregroundStyle(Color("DarkBlue"))
                }
                
                Spacer()
                //TODO: on click should allow you to edit the workout
                VStack{
                    Button{
                        onEdit(restDay)
                    } label: {
                        HStack(spacing: 5){
                            Circle()
                                .frame(width:8, height: 8)
                                .foregroundStyle(Color("Cream"))
                            Circle()
                                .frame(width:8, height: 8)
                                .foregroundStyle(Color("Cream"))
                            Circle()
                                .frame(width:8, height: 8)
                                .foregroundStyle(Color("Cream"))
                            
                        }
                    }
                    Spacer()
                }
            }
            .padding(15)
            
            
            
        }
        .frame(width: 339, height: 127)
        .padding(.bottom, 10)
    }
}
//TODO: should take in PR or Workout and add based on that
struct AddButton: View{
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color("GradPeach"), Color("GradFireOrange")],
                        startPoint: .top,
                        endPoint: .bottom
                    ).opacity(0.6)
                )
            Image(systemName: "plus")
                .font(.system(size:80))
                .foregroundColor(Color("Cream"))
        }
        .frame(width: 339, height: 127)
    }
}

//#Preview {
//    let previewView: AnyView = {
//        let container: ModelContainer
//        
//        do {
//            let config = ModelConfiguration(isStoredInMemoryOnly: true)
//            container = try ModelContainer(
//                for: Workout.self,
//                     Exercise.self,
//                     RestDay.self,
//                     PersonalRecord.self,
//                configurations: config
//            )
//            
//            let context = container.mainContext
//            
//            // Pass the context into PetViewModel here
//            let mockPetViewModel = PetViewModel(modelContext: context)
//            
//            return AnyView(
//                WorkoutView(context: context, petViewModel: mockPetViewModel)
//                    .modelContainer(container)
//            )
//        } catch {
//            return AnyView(Text("Failed to load preview: \(error.localizedDescription)"))
//        }
//    }()
//
//    previewView
//}
