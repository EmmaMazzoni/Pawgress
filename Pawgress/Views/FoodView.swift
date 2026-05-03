//
//  FoodView.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/12/26.
//
import SwiftUI
import SwiftData
import Combine

//MARK: - Overall View
struct FoodView: View {
    @StateObject private var vm = FoodWaterViewModel()
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var petViewModel: PetViewModel
    
    @EnvironmentObject var progressionManager: ProgressionManager

    @State private var showFood: Bool = true
    
    //fetch data
    @Query private var foodEntries: [FoodEntry]
    @Query private var hydrationEntries: [HydrationEntry]
    @Query private var settings: [UserSettings]
    
    
    var body: some View {
        ZStack{
            Color("Cream")
                .ignoresSafeArea()
            VStack{
                //MARK: - week buttons
                HStack(spacing: 6){
                    
                    
                    let weekDays = vm.currentWeekDays()
                    
                    //first day (sunday)
                    Button{
                        vm.selectDay(weekDays[0])
                    } label:{
                        ZStack{
                            RoundedCorner(radius: 15, corners: [.bottomLeft, .topLeft])
                                .fill(Color("DarkBlue"))
                            Text("S")
                                .font(.custom("Mega Champs", size: 45))
                                .foregroundStyle(
                                    Calendar.current.isDate(weekDays[0], inSameDayAs: vm.selectedDate) ? Color("LightBlue") : Color("Cream")
                                )
                                .offset(y: 6)
                                .lineSpacing(-10)
                        }
                    }
                    
                    ForEach(1..<6, id: \.self){ index in
                        let day = weekDays[index]
                        let letters = ["M","T","W","R","F"]
                        
                        Button{
                            vm.selectDay(day)
                        } label:{
                            ZStack{
                                Rectangle()
                                    .fill(Color("DarkBlue"))
                                Text(letters[index-1])
                                    .font(.custom("Mega Champs", size: 45))
                                    .foregroundStyle(
                                        Calendar.current.isDate(day, inSameDayAs: vm.selectedDate) ? Color("LightBlue") : Color("Cream")
                                    )
                                    .offset(y: 6)
                                    .lineSpacing(-10)
                            }
                        }
                    }
                    
                    //last day (saturday)
                    Button{
                        vm.selectDay(weekDays[6])
                    } label: {
                        ZStack{
                            RoundedCorner(radius: 15, corners: [.bottomRight, .topRight])
                                .fill(Color("DarkBlue"))
                            Text("U")
                                .font(.custom("Mega Champs", size: 45))
                                .foregroundStyle(
                                    Calendar.current.isDate(weekDays[6], inSameDayAs: vm.selectedDate) ? Color("LightBlue") : Color("Cream")
                                )
                                .offset(y: 6)
                                .lineSpacing(-10)
                        }
                    }
                    
                }
                .frame(width: 340, height: 61)
                .padding(.bottom, 30)
      
                
                
                //MARK: - Food and Water switch
                if showFood {
                    FoodLog(showFood: $showFood,vm: vm, petViewModel: petViewModel, foodEntries: foodEntries)
                } else {
                    WaterLog(showFood: $showFood, vm: vm, petViewModel: petViewModel, hydrationEntries: hydrationEntries, settings: settings.first)
                }
            }
            .padding(20)
        }
    }
}

//MARK: - FoodLog
struct FoodLog: View{
    
    @Binding var showFood: Bool
    @ObservedObject var vm: FoodWaterViewModel
    @ObservedObject var petViewModel: PetViewModel
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var progressionManager: ProgressionManager
    
    var foodEntries: [FoodEntry]
    
    var body: some View{

        VStack{
            //MARK: Food switch
            HStack(spacing: 25){
                Image(systemName: "arrowtriangle.left.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color("LightBlue"))
                    .onTapGesture {
                        showFood = false   // switch to water
                    }
                Text("Food")
                    .font(.custom("Mega Champs", size: 45))
                    .foregroundStyle(Color("DarkBlue"))
                    .offset(y: 6)
                
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color("LightBlue"))
                    .onTapGesture {
                        showFood = false   // switch to water
                    }
            }
            .padding(-1)
            
            //MARK: -Circle food groups
            ZStack{
                //veggies group
                foodQuad(group: "Veggies", color: "DarkBlue", rotation: 270, xOffset: 80, yOffset: -70)
                
                //protein group
                foodQuad(group: "Protein", color: "RegOrange", rotation: 180, xOffset: -80, yOffset: -70)
                
                foodQuad(group: "Grains", color: "FireOrange", rotation: 90, xOffset: -80, yOffset: 70)
                
                foodQuad(group: "Fruit", color: "LightBlue", rotation: 0, xOffset: 80, yOffset: 70)
                
            }
            .frame(width: 360, height: 360)

            
            //MARK:  meals
            mealSelector
            
            Spacer()
        }
        .padding(20)
    }
    
    //MARK: functions
    // food circles
    func foodQuad(group: String, color: String, rotation: Double, xOffset: CGFloat, yOffset: CGFloat) -> some View{
        let isChecked = vm.isGroupChecked(meal: vm.selectedMeal, group: group, for: vm.selectedDate, from: foodEntries)
        
        return ZStack{
            QuarterCircle()
                .fill(Color(color))
                .stroke(Color("Cream"), lineWidth: 6)
                .rotationEffect(.degrees(rotation))
                .onTapGesture {
                    //toggle
                    vm.toggleFoodGroup(context: modelContext, manager: progressionManager, meal: vm.selectedMeal, group: group, date: vm.selectedDate, entries: foodEntries)
                    
                    // check for streak refresh
                    petViewModel.checkAndRefreshStreak()
                    
                    //save toggle
                    vm.objectWillChange.send()
                }
            HStack{
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundStyle(Color("Cream"))
                Text(group)
                    .font(.custom("Mega Champs", size: 30))
                    .foregroundStyle(Color("Cream"))
                    .offset(y: 6)
            }
            .offset(x: xOffset, y: yOffset)
        }
    }
    //MARK: - meal selector buttons
    var mealSelector: some View{
        HStack(spacing: 30){
            ForEach(["breakfast","lunch","dinner"], id: \.self){meal in
                Button{
                    vm.selectedMeal = meal
                } label: {
                    Text(meal)
                        .font(.custom("Arial Rounded MT Bold", size: 23))
                        .foregroundStyle(vm.selectedMeal == meal ? Color("DarkBlue") : Color("DarkBlue").opacity(0.5))
                        .offset(y: 6)
                }
            }
        }
        .padding(.top, 20)
    }
}

//MARK: - WaterLog
struct WaterLog: View {
    
    @Binding var showFood: Bool
    @ObservedObject var vm: FoodWaterViewModel
    @ObservedObject var petViewModel: PetViewModel
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var progressionManager: ProgressionManager
    
    //data
    var hydrationEntries: [HydrationEntry]
    var settings: UserSettings?
    
    //alert for goal entry
    @State private var showingGoalAlert = false
    @State private var newGoalText = ""
    
    //state for log
    @State private var showingLogAlert = false
    @State private var waterAmountTxt = ""
    
    var body: some View {
        VStack{
            HStack(spacing: 20){
                Image(systemName: "arrowtriangle.left.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color("LightBlue"))
                    .onTapGesture {
                        showFood = true   // switch to water
                    }
                
                Text("Water")
                    .font(.custom("Mega Champs", size: 45))
                    .foregroundStyle(Color("DarkBlue"))
                    .offset(y: 6)
                
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color("LightBlue"))
                    .onTapGesture {
                        showFood = true   // switch to water
                    }
            }
            .padding(-1)
            
            // water shape, on tap allows for hydration entry
            VStack{
                //top 75-100%
                Trapezoid(topWidth: 205, bottomWidth: 190)
                    .fill(colorForLevel(4))
                    .frame(width: 160, height: 80)
                
                //middle top 50%-75%
                Trapezoid(topWidth: 190, bottomWidth: 175)
                    .fill(colorForLevel(3))
                    .frame(width: 160, height: 80)
                
                // middle bottom 25%-50%
                Trapezoid(topWidth: 175, bottomWidth: 160)
                    .fill(colorForLevel(2))
                    .frame(width: 160, height: 80)
                
                // bottom  0%-25%
                Trapezoid(topWidth: 160, bottomWidth: 145)
                    .fill(colorForLevel(1))
                    .frame(width: 160, height: 80)
            }
            .onTapGesture {
                showingLogAlert = true
            }
            HStack{
                Text("Goal: \(Int(settings?.waterGoalOz ?? 0)) OZ")
                    .font(.custom("Arial Rounded MT Bold", size: 23))
                    .foregroundStyle(Color("DarkBlue"))
                Button{
                    newGoalText = String(format: "%0.f", settings?.waterGoalOz ?? 0)
                    showingGoalAlert = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color("DarkBlue"))
                }
            }
            .padding(30)
            
            Spacer()
             
        }
        .padding()
        //water goal alert
        .alert("Update Water Goal", isPresented: $showingGoalAlert){
            TextField("Amount in OZ", text: $newGoalText)
                .keyboardType(.decimalPad)
            
            Button("Save"){
                if let newGoal = Double(newGoalText){
                    vm.updateWaterGoal(context: modelContext, newGoal: newGoal, settings: settings)
                }
            }
            Button("Cancel", role: .cancel){}
        } message :{
            Text("Enter your daily water goal in ounces.")
        }
        //water log alert
        .alert("Log Water", isPresented: $showingLogAlert){
            TextField("Ounces", text: $waterAmountTxt)
                .keyboardType(.decimalPad)
            
            Button("Add"){
                if let amount = Double(waterAmountTxt){
                    vm.addWater(context: modelContext, manager: progressionManager, amount: amount, date: vm.selectedDate)
                    
                    //refresh streak
                    petViewModel.checkAndRefreshStreak()
                    
                    waterAmountTxt = ""
                }
            }
            Button("Cancel", role: .cancel){}
        } message: {
            Text("How many ounces of water did you drink?")
        }
    }
    
    //MARK: - helper functions
    private var fillPercentage: Double{
        let goal = settings?.waterGoalOz ?? 40.0
        let current = vm.totalWater(for: vm.selectedDate, from: hydrationEntries)
        return goal > 0 ? (current/goal): 0
        
    }
    
    func colorForLevel(_ level: Int) -> Color {
        let threshold = Double(level) * 0.25
        return fillPercentage >= threshold ? Color("LightBlue") : Color("DarkBlue")
    }
}



#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FoodEntry.self, HydrationEntry.self, UserSettings.self, configurations: config)
    
    // Pass the mainContext to both Managers/ViewModels
    let petVM = PetViewModel(modelContext: container.mainContext)
    let progression = ProgressionManager(context: container.mainContext)
    
    FoodView(petViewModel: petVM)
        .modelContainer(container)
        .environmentObject(progression)
}
