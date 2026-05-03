//
//  PawgressApp.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/10/26.
//

import SwiftUI
import SwiftData

@main
struct PawgressApp: App {
    @StateObject private var progressionManager: ProgressionManager
    @Environment(\.scenePhase) var scenePhase
    
    init(){
        let darkBlue = UIColor(Color("DarkBlue"))
        let lightBlue = UIColor(Color("LightBlue"))
        let cream = UIColor(Color("Cream"))
        let customFont = UIFont(name: "Arial Rounded MT BOLD", size: 20)!

               
        // selected segment background
        UISegmentedControl.appearance().selectedSegmentTintColor = darkBlue
               
        // selected text
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: cream, .font: customFont],
            for: .selected
        )
               
        // unselected text
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: darkBlue, .font: customFont],
            for: .normal
        )
               
        //background of entire segmented control
        UISegmentedControl.appearance().backgroundColor = lightBlue.withAlphaComponent(0.3)
        
        let container = sharedModelContainer // local reference to avoid closure issues
        _progressionManager = StateObject(wrappedValue: ProgressionManager(context: container.mainContext))
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Pet.self,
            Accessory.self,
            Challenge.self,
            Workout.self,
            Exercise.self,
            RestDay.self,
            PersonalRecord.self,
            FoodEntry.self,
            HydrationEntry.self,
            UserSettings.self
        ])
        
        //point to the app group URL
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.edu.psu.ejm6249.Pawgress")!
        let storeURL = groupURL.appendingPathComponent("Pawgress.sqlite")
        let modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainView(modelContext: sharedModelContainer.mainContext)
                .environmentObject(progressionManager)
                .onAppear{
                    DataSeeder.seedChallenge(context: sharedModelContainer.mainContext)
                    if let pet = try? sharedModelContainer.mainContext.fetch(FetchDescriptor<Pet>()).first {
                            WidgetDataWriter.write(pet: pet)
                    }
                }
                .onChange(of: scenePhase){_, newPhase in
                    if newPhase == .background{
                        if let pet = try? sharedModelContainer.mainContext.fetch(FetchDescriptor<Pet>()).first{
                            WidgetDataWriter.write(pet: pet)
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
