//
//  ContentView.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/10/26.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @State private var selectedTab = 4
    @Environment(\.modelContext) private var context
    
    @StateObject private var petViewModel: PetViewModel
    @EnvironmentObject var progressionManager: ProgressionManager
    
    init(modelContext: ModelContext) {
        // links the PetViewModel to your SwiftData context
        let vm = PetViewModel(modelContext: modelContext)
        _petViewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack{

            VStack(spacing: 0) {
                
                // CONTENT
                TabView(selection: $selectedTab) {
                    WorkoutView(context: context, petViewModel: petViewModel)
                        .tag(0)
                    FoodView(petViewModel: petViewModel)
                        .tag(1)
                    PetEditView(modelContext: context)
                        .tag(2)
                    FeedView()
                        .tag(3)
                    HomeView(modelContext: context, petViewModel: petViewModel)
                        .tag(4)
                }
                .onAppear {
                    UITabBar.appearance().isHidden = true
                }
                .scrollContentBackground(.hidden)

                // CUSTOM TAB BAR
                HStack(spacing: 15) {
                    Spacer()
                    Button {
                        selectedTab = 0
                    } label: {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(Color("Cream"))
                    }
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color("Cream"))
                        .frame(width: 3, height: 50)
                    
                    Button {
                        selectedTab = 1
                    } label: {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(Color("Cream"))
                    }
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color("Cream"))
                        .frame(width: 3, height: 50)
                    
                    Button {
                        selectedTab = 2
                    } label: {
                        Image("Vector")
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                    }
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color("Cream"))
                        .frame(width: 3, height: 50)
                    
                    Button {
                        selectedTab = 3
                    } label: {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(Color("Cream"))
                    }
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color("Cream"))
                        .frame(width: 3, height: 50)
                    
                    Button {
                        selectedTab = 4
                    } label: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(Color("Cream"))
                    }
                    
                    Spacer()
                }
                .frame(height: 45)
                .padding(.top, 13)
                .padding(.bottom, 30)
                .background(Color("DarkBlue"))
                .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
            }
            .ignoresSafeArea()
            
            // a dimming overlay behind popups
            if petViewModel.showLevelUp || (petViewModel.showChallengeComplete && petViewModel.lastCompletedChallenge != nil) {
                Color.black.opacity(0.4)
                        .ignoresSafeArea()
            }
            
            // popup overlays
            if petViewModel.showLevelUp{
                LevelUpPopUpView(level: petViewModel.currentLevel){
                    petViewModel.showLevelUp = false
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            if let challenge = petViewModel.lastCompletedChallenge, petViewModel.showChallengeComplete {
                ChallengePopUpView(challenge: challenge){
                    petViewModel.showChallengeComplete = false
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .ignoresSafeArea()
        .animation(.spring(), value: petViewModel.showLevelUp)
        .animation(.spring(), value: petViewModel.showChallengeComplete)
        .onAppear{
            setupProgressionListeners()
        }
        
    }
    private func setupProgressionListeners() {
            progressionManager.onLevelUp = { newLevel in
                print("onLevelUp fired: \(newLevel)")
                if newLevel > petViewModel.currentLevel {
                    petViewModel.currentLevel = newLevel
                    petViewModel.showLevelUp = true
                } else {
                    petViewModel.currentLevel = newLevel
                }
            }
            
            progressionManager.onChallengeComplete = { challenge in
                print("onChallengeComplete fired: \(challenge.title)")
                petViewModel.lastCompletedChallenge = challenge
                petViewModel.showChallengeComplete = true
            }
    }
    
}

//#Preview {
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: Pet.self, Workout.self, configurations: config)
//        
//        return MainView(modelContext: container.mainContext)
//            .modelContainer(container)
//    } catch {
//        return Text("Failed to create preview: \(error.localizedDescription)")
//    }
//}
