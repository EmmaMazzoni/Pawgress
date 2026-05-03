//
//  ProgressionManager.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/24/26.
//
import SwiftUI
import SwiftData
import Combine

@MainActor
class ProgressionManager: ObservableObject{
    private var context: ModelContext
    
    //call backs to trigger UI popups
    var onLevelUp: ((Int) -> Void)?
    var onChallengeComplete: ((Challenge) -> Void)?
    
    init(context: ModelContext){
        self.context = context
    }
    
    //MARK: - Core XP Logic
    func addXP(amount: Int){
        let descriptor = FetchDescriptor<Pet>()
        guard let pet = try? context.fetch(descriptor).first else { return }
        
        pet.xp += amount
            
        // check if you can level up, each level is 1000 XP
        while pet.xp >= 1000{
            pet.xp-=1000
            pet.level+=1
            //trigger pop up
            print("Calling onLevelUp with level \(pet.level)")
            onLevelUp?(pet.level)
        }
            
        //level down logic (whe deleting exercises and food groups)
        while pet.xp < 0 {
            if pet.level > 1{
                pet.level -= 1
                pet.xp += 1000
            } else {
                pet.xp = 0
                break
            }
        }
    }
    
    //MARK: - Challenge logic
    func checkChallenges(type: ChallengeType, increment: Int = 1) {
        let descriptor = FetchDescriptor<Challenge>(
            predicate: #Predicate<Challenge> { $0.isCompleted == false }
        )
        
        do {
            let allActive = try context.fetch(descriptor)
            
            // 2. Filter for the specific type in standard Swift (avoiding Predicate issues)
            let relevantChallenges = allActive.filter { $0.type == type }
            
            for challenge in relevantChallenges {
                challenge.progress += increment
                
                if challenge.progress >= challenge.goal {
                    completeChallenge(challenge)
                }
            }
            
        } catch {
            print("Fetch or save failed: \(error)")
        }
    }
    
    private func completeChallenge(_ challenge: Challenge){
        challenge.isCompleted = true
        challenge.badge?.dateEarned = Date()
        
        //trigger the popup
        onChallengeComplete?(challenge)
        
        // grant the challenge xp to the pet
        addXP(amount: challenge.xpReward)
        
        if let accessory =  challenge.accessoryReward{
            accessory.isUnlocked = true
        }
    }
}
